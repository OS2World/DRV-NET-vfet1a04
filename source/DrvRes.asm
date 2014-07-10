; *** Resident part: HW independent 

include	NDISdef.inc
include	devpac.inc
include	misc.inc
include	HWRes.inc

extern	Strategy : near16

.386


_DATA	segment	public word use16 'DATA'

public	DrvNextPtr, DrvName
DrvNextPtr	dd	-1
DrvFlags	dw	8880h	; CHR, OPN, LV1
		dw	offset Strategy
		dw	0
DrvName		db	'UNRSLVD$'
		db	8 dup (0)
DrvCapbl	dd	0	; Capability bit

public	SysSel, DevHelp, CtxHandle
SysSel		dw	?	; Selector of Global Info. Seg.
DevHelp		dd	?	; DevHelp Entry point
CtxHandle	dd	?	; Context Hook Handle

public	CommonChar, MacChar, MacStatus, UpDisp
public	MCSTList
CommonChar	cct	< sizeof(cct), 2, 0, 0, DrvMajVer, DrvMinVer, \
			< ,0,0,1>, 16 dup (0), 1, 1, 0, 1, \
			?, seg _DATA, \
			offset SysReq, \
			offset MacChar, \
			offset MacStatus, \
			offset UpDisp, \
			0,>

MacChar		mct	< sizeof(mct), 'DIX+802.3', 6, \
			16 dup(0), 16 dup(0), 0, \
			offset MCSTList, \
			0, \
			< , 0, 0, 1, 0, 1, \
			1, 1, 0, 1, \
			0, 0, 0, 1, \
			1, 0, 1, 1 >, \
			?, \
			?, ?, \
			?, ?, \
			3 dup(0), 0, offset AdapterDesc, \
			?, ?, 8 >

MacStatus	mst	< sizeof(mst), 0, \
			< ,0, 0, 0, 7 >, \
			< ,0, 0, 0, 0 >, \
			0, 0, \
			0, 0, 0, 0, 0, 0, \
			, \
			0, 0, 0, 0, 0, \
			, \
			0, 0 >

UpDisp		updp	< offset CommonChar, \
			offset GenReq, \
			offset TxChain, \
			offset RxData, \
			offset RxRelease, \
			offset IndOn, \
			offset IndOff >


MCSTList	multicastlist	< 32, 0, 16 dup (0) >
		db	(16*31) dup (0)

public	LowDisp, ProtDS
LowDisp		lowdp	<>
ProtDS		dw	?

align	2

grDisp		dw	offset grInitDiag	; x1 
		dw	offset grReadError	; x2
		dw	offset grStationAdr	; o3
		dw	offset grOpen		; o4
		dw	offset grClose		; o5
		dw	offset grReset		; o6
		dw	offset grPktFlt		; o7
		dw	offset grAddMc		; o8
		dw	offset grDelMc		; o9
		dw	offset grUpStat		; o10
		dw	offset grClrStat	; o11
		dw	offset grIntReq		; o12
		dw	offset grSetFunc	; x13
		dw	offset grSetLooka	; o14

public	drvflags, Indication
drvflags	driver_flags <>
Indication	dw	0

public	semInt, semTx, semRx, semFlt, semMii, semStat, semInd
semInt		db	0, 0	; interrupt
semTx		db	0, 0	; Tx
semRx		db	0, 0	; Rx
semFlt		db	0, 0	; packet filter
semMii		db	0, 0	; MII
semInd		db	0, 0	; indication
semStat		db	0, 0	; statistics

_DATA	ends


_TEXT	segment	public word use16 'CODE'
	assume	ds:_DATA

TxChain		proc	far
		; +6:MACDS, +8:TxBufDescr  +12:ReqHandle  +14:ProtID
	push	bp
	mov	bp,sp
	push	si
	push	di
	push	ds
	push	gs
	mov	ds,[bp+6]
	bt	word ptr [MacStatus.sstMACstatus],msopen
	jnc	short loc_if
	bt	drvflags,df_rstreq	; Reset is requested
	jc	short loc_if
	les	si,[bp+8]
	mov	ax,es:[si].TxFrameDesc.TxImmedLen
	cmp	ax,64
	ja	short loc_ip	; Too long immediate data
	dec	ax
	setge	bl
	jl	short loc_1	; No Immediate data
	test	word ptr es:[si].TxFrameDesc.TxImmedPtr[2],-8
	jz	short loc_ip	; Null selector
loc_1:
	mov	cx,es:[si].TxFrameDesc.TxDataCount
	cmp	cx,8
	ja	short loc_ip	; Too many buffer descriptor
	or	cx,cx
	setnz	bh
	jz	short loc_5	; No buffer descriptor
	lea	si,[si].TxFrameDesc.TxBufDesc1
loc_2:
	mov	ax,es:[si].TxBufDesc.TxDataLen
	or	ax,ax
	jz	short loc_ip	; length 0
	cmp	es:[si].TxBufDesc.TxPtrType,1
	jnc	short loc_3	; Virtual address
	cmp	es:[si].TxBufDesc.TxDataPtr,0
	jnz	short loc_4
	jmp	short loc_ip	; Null pointer

loc_if:
	mov	ax,INVALID_FUNCTION
	jmp	short loc_ex
loc_ip:
	mov	ax,INVALID_PARAMETER
	jmp	short loc_ex

loc_3:
	cmp	es:[si].TxBufDesc.TxPtrType,2
	ja	short loc_ip	; bad type
	dec	ax
	mov	dx,word ptr es:[si].TxBufDesc.TxDataPtr[2]
	add	ax,word ptr es:[si].TxBufDesc.TxDataPtr
	jc	short loc_ip	; offset wraparound
	test	dx,-8
	jz	short loc_ip	; Null selector
	test	dx,4
	jnz	short loc_ip	; LDT selector (context sensitive)
loc_4:
	add	si,sizeof(TxBufDesc)
	dec	cx
	jnz	short loc_2
loc_5:
	or	bx,bx
	jz	short loc_ip	; Neither immediate nor buffer

	mov	gs,[MEMSel]
	mov	ax,[bp+8]
	mov	dx,[bp+10]
	mov	cx,[bp+12]
	mov	bx,[bp+14]
	push	bx
	push	cx
	push	dx
	push	ax
	call	_hwTxChain
	add	sp,4*2
loc_ex:
	pop	gs
	pop	ds
	pop	di
	pop	si
	pop	bp
	retf	5*2
TxChain		endp

RxRelease	proc	far
	push	bp
	mov	bp,sp
	push	ds
	push	gs
	mov	ds,[bp+6]		; MACDS
	mov	gs,[MEMSel]
	push	word ptr [bp+8]		; ReqHandle
	call	_hwRxRelease
	pop	bp
	mov	ax,SUCCESS
	pop	gs
	pop	ds
	pop	bp
	retf	4
RxRelease	endp

IndOn		proc	far
	cli
	push	bp
	mov	bp,sp
	push	ds
	push	gs
	mov	ds,[bp+6]
	mov	gs,[MEMSel]
	call	_IndicationON
	mov	ax,SUCCESS
	pop	gs
	pop	ds
	pop	bp
	retf	2
IndOn		endp

IndOff		proc	far
	cli
	push	bp
	mov	bp,sp
	push	ds
	push	gs
	mov	ds,[bp+6]
	mov	gs,[MEMSel]
	call	_IndicationOFF
	mov	ax,SUCCESS
	pop	gs
	pop	ds
	pop	bp
	retf	2
IndOff		endp

public	_IndicationON, _IndicationOFF, _IndicationChkOFF
_IndicationON	proc	near
	push	offset semInd
	call	_EnterCrit
	inc	word ptr [Indication]
	jnz	short loc_1
	call	_hwEnableRxInd
loc_1:
	call	_LeaveCrit
	add	sp,2
	retn
_IndicationON	endp

_IndicationOFF	proc	near
	push	offset semInd
	call	_EnterCrit
	sub	word ptr [Indication],1
	jnc	short loc_1
	call	_hwDisableRxInd
loc_1:
	call	_LeaveCrit
	add	sp,2
	retn
_IndicationOFF	endp

_IndicationChkOFF	proc	near
	push	offset semInd
	call	_EnterCrit
	xor	ax,ax
	cmp	word ptr [Indication],ax
	jnz	short loc_1	; indication is OFF state.
	dec	word ptr [Indication]
	call	_hwDisableRxInd
	mov	ax,1
loc_1:
	call	_LeaveCrit
	add	sp,2
	retn
_IndicationChkOFF	endp

RxData		proc	far	; TransferData (Not Supported)
	mov	ax,INVALID_FUNCTION
	retf	6*2
RxData		endp

; --- Interrupt handle entry ---
IntHandle	proc	far
	cli
	mov	al,1
	xchg	al,[semInt]
	or	al,al
	jnz	short loc_stc
	push	gs
	mov	gs,[MEMSel]
	call	_hwCheckInt
	or	ax,ax
	jnz	short loc_in
	xchg	al,[semInt]
	pop	gs
loc_stc:
	stc
	retf

loc_in:
	call	_hwDisableInt
	mov	al,IRQlevel
	mov	dl,DevHlp_EOI
	call	dword ptr [DevHelp]
	sti
	cld
	call	_hwServiceInt
lock	btr	drvflags,df_idcp
	jnc	short loc_1
	mov	ax,CommonChar.moduleID
	mov	cx,ProtDS
	push	ax
	push	cx
	call	dword ptr [LowDisp.indiccomplete]
	mov	gs,[MEMSel]
loc_1:
	test	drvflags,mask df_intreq or mask df_rstreq
	jnz	short loc_3
loc_2:
	cli
	call	_hwEnableInt
	mov	al,0
	xchg	al,[semInt]
	pop	gs
	clc
	retf
loc_3:
	bt	drvflags,df_intreq
	jnc	short loc_4
	call	IntRequest
loc_4:
	bt	drvflags,df_rstreq
	jnc	short loc_2
	call	ResetRequest
	jmp	short loc_2

IntRequest	proc	near
	enter	2,0
	call	_IndicationChkOFF
	or	ax,ax
	jz	short loc_ir2
	mov	ax,CommonChar.moduleID
	mov	cx,ProtDS
	mov	bx,sp
	mov	byte ptr [bp-2],-1
	push	ax
	push	cx

	push	ax
	push	0
	push	ss
	push	bx
	push	siOpInterrupt
	push	cx
	call	dword ptr [LowDisp.stindic]
	mov	gs,[MEMSel]
	cmp	byte ptr [bp-2],-1
	jnz	short loc_ir1
	call	_IndicationON
loc_ir1:
lock	and	drvflags, not mask df_intreq
	call	dword ptr [LowDisp.indiccomplete]
	mov	gs,[MEMSel]
loc_ir2:
	leave
	retn
IntRequest	endp

ResetRequest	proc	near
	enter	2,0
	call	_IndicationChkOFF
	or	ax,ax
	jz	short loc_rr3
	mov	ax,CommonChar.moduleID
	mov	cx,ProtDS
	mov	bx,sp
	mov	byte ptr [bp-2],-1

	push	ax
	push	cx

	push	ax
	push	0
	push	ss
	push	bx
	push	siOpEndReset
	push	cx

	push	ax
	push	0
	push	ss
	push	bx
	push	siOpStartReset
	push	cx
	call	dword ptr [LowDisp.stindic]
	mov	gs,[MEMSel]
	cmp	byte ptr [bp-2],-1
	jz	short loc_rr1
	call	_IndicationOFF
loc_rr1:
	call	dword ptr [LowDisp.stindic]
	mov	gs,[MEMSel]
	cmp	byte ptr [bp-2],-1
	jnz	short loc_rr2
	call	_IndicationON
loc_rr2:
lock	and	drvflags,not mask df_rstreq
	call	dword ptr [LowDisp.indiccomplete]
	mov	gs,[MEMSel]
loc_rr3:
	leave
	retn
ResetRequest	endp

IntHandle	endp

; --- Timer Handle ---
TimerHandle	proc	far
	push	eax
	push	ecx
	push	edx
	push	ebx
	push	ds
	mov	ax,DGROUP
	mov	ds,ax
	mov	ebx,[CtxHandle]
	or	ecx,-1
	mov	dl,DevHlp_ArmCtxHook
	call	dword ptr [DevHelp]
	pop	ds
	pop	ebx
	pop	edx
	pop	ecx
	pop	eax
	retf
TimerHandle	endp

; --- Context Hook entry ---
CtxEntry	proc	far
	pushf
	pushad
	mov	ax,DGROUP
	push	ds
	push	es
	mov	ds,ax
	mov	es,ax
	bt	word ptr [MacStatus.sstMACstatus],msopen
	jnc	short loc_1
	sti
	push	gs
	mov	gs,[MEMSel]
	call	_hwPollLink
	pop	gs
loc_1:
	pop	es
	pop	ds
	popad
	popf
	retf
CtxEntry	endp

; --- General Request ---
GenReq		proc	far
	push	bp
	mov	bp,sp
	push	si
	push	di
	push	ds
	push	gs
	mov	ds,[bp].grParam.MACDS
	mov	bx,[bp].grParam.Opcode
	mov	gs,[MEMSel]
	mov	ax,INVALID_FUNCTION
	cmp	bx,grOpSetLooka
	ja	short loc_ex
	dec	bx
	jl	short loc_ex
	shl	bx,1
	call	word ptr grDisp[bx]
loc_ex:
	pop	gs
	pop	ds
	pop	di
	pop	si
	pop	bp
	retf	(sizeof(grParam) -6)


grInitDiag	proc	near	; x1 InitiateDiagnostics
	mov	ax,NOT_SUPPORTED
	retn
grInitDiag	endp

grReadError	proc	near	; x2 ReadErrorLog
	mov	ax,NOT_SUPPORTED
	retn
grReadError	endp

grStationAdr	proc	near	; o3 SetStationAddress
	test	word ptr [MacStatus.sstMACstatus],mask msopen
	jnz	short loc_e1	; already open - fail
	push	offset semFlt
	call	_EnterCrit
	les	si,[bp].grParam.Param2
	mov	di,offset MacChar.mctcsa
	mov	ax,es:[si]
	mov	cx,es:[si+2]
	mov	dx,es:[si+4]
	mov	[di],ax
	mov	[di+2],cx
	mov	[di+4],dx
	call	_LeaveCrit
	add	sp,2
	call	_hwSetMACaddr
	mov	ax,SUCCESS
	retn
loc_e1:
	mov	ax,GENERAL_FAILURE
	retn
grStationAdr	endp

grOpen		proc	near	; o4 OpenAdapter
	test	word ptr [MacStatus.sstMACstatus],mask msopen
	jnz	short loc_e1
	call	_hwOpen
	cmp	ax,SUCCESS
	jnz	short loc_e2
lock	or	word ptr [MacStatus.sstMACstatus],mask msopen

	mov	ax,offset TimerHandle
	mov	bx,144
	mov	dl,DevHlp_TickCount
	call	dword ptr [DevHelp]

	mov	ax,SUCCESS
	retn
loc_e1:
loc_e2:
	mov	ax,INVALID_FUNCTION
	retn
grOpen		endp

grClose		proc	near	; o5 CloseAdapter
lock	btr	word ptr [MacStatus.sstMACstatus],msopen
	jnc	short loc_e1
	push	offset semFlt
	call	_EnterCrit
	mov	MCSTList.curnum,0
	call	_LeaveCrit
	add	sp,2
	call	_hwClose
	mov	ax,offset TimerHandle
	mov	dl,DevHlp_ResetTimer
	call	dword ptr [DevHelp]
	mov	ax,SUCCESS
	retn
loc_e1:
	mov	ax,INVALID_FUNCTION
	retn
grClose		endp


grReset		proc	near	; o6 ResetMAC
lock	bts	[drvflags],df_rstreq
	jc	short loc_ex
	call	_hwIntReq
loc_ex:
	mov	ax,SUCCESS
	retn
grReset		endp

grPktFlt	proc	near	; o7 SetPacketFilter
	test	[bp].grParam.Param1,mask fltreserve or mask fltsrcrt
	jnz	short loc_e1	; invalid parameter
	push	offset semFlt
	call	_EnterCrit
	mov	ax,[bp].grParam.Param1
	mov	MacStatus.sstRxFilter,ax
	call	_LeaveCrit
	add	sp,2
	call	_hwUpdatePktFlt
	mov	ax,SUCCESS
	retn
loc_e1:
	mov	ax,GENERAL_FAILURE
	retn
grPktFlt	endp

grAddMc		proc	near	; o8 AddMulticastAddress
	push	offset semFlt
	call	_EnterCrit
	mov	ax,MCSTList.curnum
	cmp	ax,MCSTList.maxnum
	jnc	short loc_e1		; Too many list
	les	bx,[bp].grParam.Param2
	mov	dx,offset MCSTList.multicastaddr1
	dec	ax
	jl	short loc_2
loc_1:
	mov	cx,3
	mov	si,dx
	mov	di,bx
	add	dx,16
	repz	cmpsw
	jz	short loc_e2		; Same addr found
	dec	ax
	jge	short loc_1
loc_2:
	mov	si,dx
	mov	ax,es:[bx]
	mov	cx,es:[bx+2]
	mov	di,es:[bx+4]
	mov	[si],ax
	mov	[si+2],cx
	mov	[si+4],di
	inc	[MCSTList.curnum]
	call	_LeaveCrit
	add	sp,2
	call	_hwUpdateMulticast
	mov	ax,SUCCESS
	retn
loc_e1:
	mov	ax,OUT_OF_RESOURCE
	jmp	short loc_ex
loc_e2:
	mov	ax,INVALID_PARAMETER
loc_ex:
	call	_LeaveCrit
	add	sp,2
	retn
grAddMc		endp

grDelMc		proc	near	; o9 DeleteMulticastAddress
	push	offset semFlt
	call	_EnterCrit
	mov	ax,MCSTList.curnum
	test	ax,ax
	jz	short loc_e1	; No Entry
	les	bx,[bp].grParam.Param2
	mov	dx,offset MCSTList.multicastaddr1
loc_1:
	mov	cx,3
	mov	si,dx
	mov	di,bx
	add	dx,16
	repz	cmpsw
	jz	short loc_2	; Entry found in table
	dec	ax
	jnz	short loc_1
loc_e1:
	call	_LeaveCrit
	add	sp,2
	mov	ax,INVALID_PARAMETER
	retn
loc_2:
	dec	ax
	jz	short loc_3	; Last entry in table
	mov	si,dx
	shl	ax,2
	lea	di,[si-16]
	mov	cx,ax
	push	ds
	pop	es
	rep	movsd
loc_3:
	dec	[MCSTList.curnum]
	call	_LeaveCrit
	add	sp,2
	call	_hwUpdateMulticast
	mov	ax,SUCCESS
	retn
grDelMc		endp

grUpStat	proc	near	; o10 UpdateStatistics
	call	_hwUpdateStat
	mov	ax,SUCCESS
	retn
grUpStat	endp

grClrStat	proc	near	; o11 ClearStatistics
	push	offset semStat
	call	_EnterCrit
	call	_hwClearStat
	mov	di,offset MacStatus
	xor	eax,eax
	mov	[di].mst.rxframe,eax
	mov	[di].mst.rxframecrc,eax
	mov	[di].mst.rxbyte,eax
	mov	[di].mst.rxframebuf,eax
	mov	[di].mst.rxframemulti,eax
	mov	[di].mst.rxframebroad,eax
	mov	[di].mst.rxframehw,eax
	mov	[di].mst.txframe,eax
	mov	[di].mst.txbyte,eax
	mov	[di].mst.txframemulti,eax
	mov	[di].mst.txframebroad,eax
	mov	[di].mst.txframeto,eax
	mov	[di].mst.txframehw,eax
	mov	es,[SysSel]
	xor	bx,bx
	mov	eax,es:[bx]	; Current Time
	mov	[di].mst.sstclrtime,eax
	call	_LeaveCrit
	add	sp,2

	mov	ax,SUCCESS
	retn
grClrStat	endp

grIntReq	proc	near	; o12 InterruptRequest
lock	bts	[drvflags],df_intreq
	jc	short loc_ex
	call	_hwIntReq
loc_ex:
	mov	ax,SUCCESS
	retn
grIntReq	endp

grSetFunc	proc	near	; x13 SetFunctionAddress
	mov	ax,NOT_SUPPORTED
	retn
grSetFunc	endp

grSetLooka	proc	near	; o14 SetLookahead
	mov	ax,SUCCESS	; don't use ReceiveLookahead
	retn
grSetLooka	endp

GenReq		endp

; --- System Request (Support only Bind) ---
; +6: MacDS  +8:Opcode  +10:Param3  +12:Param2  +16:Param1
SysReq		proc	far
	push	bp
	mov	bp,sp
	push	si
	push	di
	push	ds
	push	gs
	mov	ds,[bp].srParam.TargetDS

	cmp	[bp].srParam.Opcode,srOpBind	; 2:bind
	mov	ax,INVALID_FUNCTION
	jnz	short loc_inv
	bt	word ptr [MacStatus.sstMACstatus],msbound
	jc	short loc_inv

	mov	gs,[MEMSel]
	call	_hwReset
	cmp	ax,SUCCESS
	jnz	short loc_hf

	mov	ax,offset IntHandle
	mov	bl,IRQlevel
	mov	bh,0
	mov	dx,100h or DevHlp_SetIRQ	; shared
	call	dword ptr [DevHelp]
	jnc	short loc_1
	mov	ax,offset IntHandle
	mov	bl,IRQlevel
	mov	bh,0
	mov	dx,DevHlp_SetIRQ		; not shared
	call	dword ptr [DevHelp]
	mov	ax,INTERRUPT_CONFLICT
	jc	short loc_ic
loc_1:
	test	[drvflags],mask df_opbnd
	jz	short loc_2
	call	grOpen
	cmp	ax,SUCCESS
	jnz	short loc_of
loc_2:
	or	word ptr [MacStatus.sstMACstatus],mask msbound
	mov	dx,[bp].srParam.TargetDS
	lds	si,[bp].srParam.Param2
	mov	[si],offset CommonChar
	mov	[si+2],dx
	mov	di,offset LowDisp
	mov	cx,sizeof(lowdp)/4
	lds	si,[bp].srParam.Param1
	mov	ax,[si].cct.moduleDS
	lds	si,[si].cct.cctlod
	mov	es,dx
	mov	es:[ProtDS],ax
	rep	movsd
	mov	ax,SUCCESS
loc_inv:
loc_ic:
loc_ex:
	pop	gs
	pop	ds
	pop	di
	pop	si
	pop	bp
	retf	(sizeof(srParam) -6)
loc_of:
	mov	bl,IRQlevel
	mov	bh,0
	mov	dl,DevHlp_UnSetIRQ
	call	dword ptr [DevHelp]
loc_hf:
	and	word ptr [MacStatus.sstMACstatus],not mask msopcode
	or	word ptr [MacStatus.sstMACstatus],3 ; hardware fault
	mov	ax,HARDWARE_FAILURE
	jmp	short loc_ex
	
SysReq		endp


; --- misc ---
public	_EnterCrit, _LeaveCrit
_EnterCrit	proc	near
	push	bx
	push	ax
	mov	bx,sp
	mov	bx,ss:[bx+6]
loc_0:
	mov	al,1
	test	al,[bx]
	jnz	short loc_0
	pushf
	cli
	xchg	al,[bx]
	test	al,1
	jnz	short loc_1
	pop	ax
	mov	[bx+1],ah
	pop	ax
	pop	bx
	retn
loc_1:
	pop	ax
	test	ah,2
	jz	short loc_0
	sti
	jmp	short loc_0
_EnterCrit	endp

_LeaveCrit	proc	near
	push	bx
	push	ax
	mov	bx,sp
	xor	ax,ax
	mov	bx,ss:[bx+6]
	xchg	ax,[bx]
	test	ah,2
	jz	short $+3
	sti
	pop	ax
	pop	bx
	retn
_LeaveCrit	endp

; ULONG VirtToPhys( VOID far *virtaddr )
public	_VirtToPhys
_VirtToPhys	proc	near
	enter	4,0
	push	bx
	push	si
	push	ds
	mov	eax,[DevHelp]
	mov	[bp-4],eax
	lds	si,[bp+4]
	mov	dl,DevHlp_VirtToPhys
	call	dword ptr [bp-4]
	jc	short loc_e
	mov	dx,ax
	shl	eax,16
	mov	ax,bx
	clc
loc_ex:
	pop	ds
	pop	si
	pop	bx
	leave
	retn
loc_e:
	xor	eax,eax
	sub	dx,dx
	stc
	jmp	short loc_ex
_VirtToPhys	endp

; VOID PhysToGDT( USHORT Sel, ULONG Physaddr, USHORT len)
_PhysToGDT	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	ax
	push	cx
	push	dx
	push	bx
	mov	si,[bp+4]	; selector
	mov	bx,[bp+6]	; low addr
	mov	ax,[bp+8]	; high addr
	mov	cx,[bp+10]	; length
	mov	dl,DevHlp_PhysToGDTSelector
	call	dword ptr [DevHelp]
	pop	bx
	pop	dx
	pop	cx
	pop	ax
	pop	si
	pop	bp
	retn
_PhysToGDT	endp


_Delay1ms	proc	near
	push	bp
	mov	bp,sp
	pusha
	mov	ax,cs
	mov	bx,offset _Delay1ms
	xor	di,di
;	mov	cx,1
;	mov	cx,33		; count 1 is too fast! 33ms?
	mov	cx,[bp+4]
;	mov	dh,1		; Non-Interruptible
	mov	dh,0		; Interruptible
	mov	dl,DevHlp_ProcBlock
	call	dword ptr [DevHelp]
	popa
	pop	bp
	retn
_Delay1ms	endp

_TEXT		ends

DGROUP		group	_DATA
CGROUP		group	_TEXT

end
