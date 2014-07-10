; *** Initial part

include	NDISdef.inc
include	vt86c10a.inc
include	devpac.inc
include	misc.inc
include	OEMHelp.inc
include	DrvRes.inc
include	HWRes.inc

cfgKeyDesc	struc
NextKey		dw	?
KeyStrPtr	dw	?
KeyStrLen	dw	?
KeyProc		dw	?
cfgKeyDesc	ends

cwRCRD		record  cwMXFS:1 = 0,
		cwLAT:1 = 0,
		cwMWW:1 = 0,
		cwMRW:1 = 0,
		cwMRL:1 = 0,
		cwMRM:1 = 0,
		cwPLTMR:1 = 0,
		cwDAPOL:1 = 0,
		cwRXARB:1 = 0,
		cwTXARB:1 = 0,
		cwMXDMA:1 = 0,
		cwRXEAR:1 = 0,
		cwTXEAR:1 = 0,
		cwRXQ:1 = 0,
		cwTXQ:1 = 0,
		cwUnk:1 = 0


cr	equ	0dh
lf	equ	0ah

extern	Dos16Open : far16
extern	Dos16Close : far16
extern	Dos16DevIOCtl : far16
extern	Dos16PutMessage : far16

.386

_DATA	segment	public word use16 'DATA'

public	DS_Lin, HeapEnd		; << for debug info >>
DS_Lin		dd	?
HeapEnd		dw	offset HeapStart
HeapStart:

handle_Protman	dw	?
name_Protman	db	'PROTMAN$',0
TmpDrvName	db	'VFET1A$',0,0

name_OEMHLP	db	'OEMHLP$',0
handle_OEMHLP	dw	?
P_OEMHLP	db	10 dup (?)
D_OEMHLP	db	6 dup (?)


PMparm		PMBlock	<>


cfgKeyWarn	cwRCRD	<>

DrvKeyword1	cfgKeyDesc  < offset DrvKeyword2, offset strKeyword1, \
		 lenKeyword1, offset sci_SLOT >
DrvKeyword2	cfgKeyDesc  < offset DrvKeyword3, offset strKeyword2, \
		 lenKeyword2, offset sci_TXQUEUE >
DrvKeyword3	cfgKeyDesc  < offset DrvKeyword4, offset strKeyword3, \
		 lenKeyword3, offset sci_RXQUEUE >
DrvKeyword4	cfgKeyDesc  < offset DrvKeyword5, offset strKeyword4, \
		 lenKeyword4, offset sci_TXEARLY >
DrvKeyword5	cfgKeyDesc  < offset DrvKeyword6, offset strKeyword5, \
		 lenKeyword5, offset sci_RXEARLY >
DrvKeyword6	cfgKeyDesc  < offset DrvKeyword7, offset strKeyword6, \
		 lenKeyword6, offset sci_MXDMA >
DrvKeyword7	cfgKeyDesc  < offset DrvKeyword8, offset strKeyword7, \
		 lenKeyword7, offset sci_TXARB >
DrvKeyword8	cfgKeyDesc  < offset DrvKeyword9, offset strKeyword8, \
		 lenKeyword8, offset sci_RXARB >
DrvKeyword9	cfgKeyDesc  < offset DrvKeyword10, offset strKeyword9, \
		 lenKeyword9, offset sci_DAPOL >
DrvKeyword10	cfgKeyDesc  < offset DrvKeyword11, offset strKeyword10, \
		 lenKeyword10, offset sci_POLTMR >
DrvKeyword11	cfgKeyDesc  < offset DrvKeyword12, offset strKeyword11, \
		 lenKeyword11, offset sci_MRL >
DrvKeyword12	cfgKeyDesc  < offset DrvKeyword13, offset strKeyword12, \
		 lenKeyword12, offset sci_MRW >
DrvKeyword13	cfgKeyDesc  < offset DrvKeyword14, offset strKeyword13, \
		 lenKeyword13, offset sci_MWW >
DrvKeyword14	cfgKeyDesc  < offset DrvKeyword15, offset strKeyword14, \
		 lenKeyword14, offset sci_LAT >
DrvKeyword15	cfgKeyDesc  < offset DrvKeyword16, offset strKeyword15, \
		 lenKeyword11, offset sci_MRM >
DrvKeyword16	cfgKeyDesc  < offset DrvKeyword17, offset strKeyword16, \
		 lenKeyword16, offset sci_MXFS >
DrvKeyword17	cfgKeyDesc  < offset DrvKeyword18, offset strKeyword17, \
		 lenKeyword17, offset sci_NETADR >
DrvKeyword18	cfgKeyDesc  < offset DrvKeyword19, offset strKeyword18, \
		 lenKeyword18, offset sci_OPBND >
DrvKeyword19	cfgKeyDesc  < 0, offset strKeyword19, \
		 lenKeyword19, offset sci_IRQ15O >


Key_DRIVERNAME	db	'DRIVERNAME',0,0
strKeyword1	db	'SLOT',0
lenKeyword1	equ	$ - offset strKeyword1
strKeyword2	db	'TXQUEUE',0
lenKeyword2	equ	$ - offset strKeyword2
strKeyword3	db	'RXQUEUE',0
lenKeyword3	equ	$ - offset strKeyword3
strKeyword4	db	'TXEARLY',0
lenKeyword4	equ	$ - offset strKeyword4
strKeyword5	db	'RXEARLY',0
lenKeyword5	equ	$ - offset strKeyword5
strKeyword6	db	'MXDMA',0
lenKeyword6	equ	$ - offset strKeyword6
strKeyword7	db	'TXARB',0
lenKeyword7	equ	$ - offset strKeyword7
strKeyword8	db	'RXARB',0
lenKeyword8	equ	$ - offset strKeyword8
strKeyword9	db	'DAPOLL',0
lenKeyword9	equ	$ - offset strKeyword9
strKeyword10	db	'POLLTMR',0
lenKeyword10	equ	$ - offset strKeyword10
strKeyword11	db	'PCIMRL',0
lenKeyword11	equ	$ - offset strKeyword11
strKeyword12	db	'PCIMRW',0
lenKeyword12	equ	$ - offset strKeyword12
strKeyword13	db	'PCIMWW',0
lenKeyword13	equ	$ - offset strKeyword13
strKeyword14	db	'PCILAT',0
lenKeyword14	equ	$ - offset strKeyword14
strKeyword15	db	'PCIMRM',0
lenKeyword15	equ	$ - offset strKeyword15
strKeyword16	db	'MAXFRAME',0
lenKeyword16	equ	$ - offset strKeyword16
strKeyword17	db	'NETADDRESS',0
lenKeyword17	equ	$ - offset strKeyword17
strKeyword18	db	'OPENBIND',0
lenKeyword18	equ	$ - offset strKeyword18
strKeyword19	db	'IRQ15OVR',0
lenKeyword19	equ	$ - offset strKeyword19


msg_OSEnvFail	db	'?! Invalid System Information?!',cr,lf,0
msg_ManyInst	db	'Too many module was installed.',cr,lf,0
msg_NoProtman	db	'Protocol manager open failure.',cr,lf,0
msg_ProtIOCtl	db	'Protocol manager IOCtl failure.',cr,lf,0
msg_ProtLevel	db	'Invalid protocol manager level.',cr,lf,0
msg_NoModule	db	'Module not found in PROTOCOL.INI',cr,lf,0
msg_InvSLOT	db	'Invalid SLOT keyword.',cr,lf,0
msg_InvTXQUEUE	db	'Invalid TXQUEUE keyword.',cr,lf,0
msg_InvRXQUEUE	db	'Invalid RXQUEUE keyword.',cr,lf,0
msg_NoOEMHLP	db	'OEMHLP$ PCI access failure.',cr,lf,0
msg_NoHardware	db	'Device not found.',cr,lf,0
msg_InvIOaddr	db	'I/O Base address detection failure.',cr,lf,0
msg_InvMEMaddr	db	'Memory Base address detection failure.',cr,lf,0
msg_InvIRQlevel	db	'IRQ detection failure.',cr,lf,0
msg_PMFail	db	'Power Management Capabitily access failure.',cr,lf,0
msg_PMStop	db	'info: Set Power Management status to D0 and/or clear PMESTS.',cr,lf,0
msg_ChkCmdFail	db	'warning: PCI Command register check failure.',cr,lf,0
msg_ModifyCmd	db	'info: Set Bus Master and/or Memory bits in PCI Command Register.',cr,lf,0
msg_SetMemFail	db	'Memory Base address registration to GDT failure.',cr,lf,0
msg_CtxFail	db	'Context Hook handle allocation failure.',cr,lf,0
msg_NoMem	db	'Memory block allocation failure.',cr,lf,0
msg_RegFail	db	'Module registration to protocol manager failure.',cr,lf,0
Credit		db	cr,lf,' VIA VT86C100A Rhine Another OS/2 NDIS MAC Driver '
		db	'ver.1.04 (2005-12-17)',cr,lf,0
Copyright	db	0	; Write copyright message here if you want.

Heap		db	( 42*sizeof(TD) \
			+ 42*(sizeof(RD) +4) \
			+ 4096 ) dup (?)

_DATA	ends

_TEXT	segment	public word use16 'CODE'
	assume	ds:_DATA

public	Strategy
Strategy	proc	far
;	int	3		; << debug >>
	mov	al,es:[bx]._RPH.Cmd
	cmp	al,CMDOpen
	jz	short loc_OC
	cmp	al,CMDClose
	jnz	short loc_1
loc_OC:
	mov	es:[bx]._RPH.Status,100h
	retf
loc_E:
	mov	es:[bx]._RPH.Status,8103h
	retf
loc_1:
	cmp	al,CMDInit
	jnz	short loc_E
	push	es
	push	bx
	call	_DrvInit
	pop	bx
	pop	es
	retf
Strategy	endp

_DrvInit		proc	near
	push	bp
	mov	bp,sp
	les	bx,[bp+4]
	mov	eax,es:[bx]._RPINIT.DevHlpEP
	mov	[DevHelp],eax
	push	offset Credit
	call	_PutMessage
	push	offset Copyright
	call	_PutMessage
;	add	sp,2*2
	pop	ax
	pop	cx

	call	_SetDrvEnv
	or	ax,ax
	jnz	short loc_rnm
	push	offset msg_OSEnvFail
	call	_PutMessage
;	add	sp,2
	pop	ax
	jmp	near ptr loc_err1

loc_rnm:
	call	_ResolveName
	or	ax,ax
	jnz	short loc_protop
	push	offset msg_ManyInst
	call	_PutMessage
;	add	sp,2
	pop	ax
	jmp	near ptr loc_err1
loc_protop:
	call	_OpenProtman
	or	ax,ax
	jnz	short loc_protcfg
	push	offset msg_NoProtman
	call	_PutMessage
;	add	sp,2
	pop	ax
	jmp	near ptr loc_err1
loc_protcfg:
	call	_ScanConfigImage
	or	ax,ax
	jz	near ptr loc_err2

	mov	al,cfgSLOT
	mov	ah,0
	push	ax
	call	_FindHardware
;	add	sp,2
	pop	cx
	or	ax,ax
	jz	short loc_err2

	call	_SetMemToGDT
	or	ax,ax
	jnz	short loc_memb
	push	offset msg_SetMemFail
	call	_PutMessage
;	add	sp,2
	pop	ax
	jmp	short loc_err2

loc_memb:
	call	_AllocMemBlock
	or	ax,ax
	jnz	short loc_ctx
	push	offset msg_NoMem
	call	_PutMessage
;	add	sp,2
	pop	ax
	jmp	short loc_err3

loc_ctx:
	call	_AllocCtxHook
	or	ax,ax
	jnz	short loc_protreg
	push	offset msg_CtxFail
	call	_PutMessage
;	add	sp,2
	pop	ax
	jmp	short loc_err4

loc_protreg:
	call	_RegisterModule
	or	ax,ax
	jnz	short loc_OK
	push	offset msg_RegFail
	call	_PutMessage
;	add	sp,2
	pop	ax
	jmp	short loc_err4
loc_OK:
	call	_CloseProtman
	call	_InitQueue
	les	bx,[bp+4]
	mov	ax,[HeapEnd]
	mov	es:[bx]._RPINITOUT.CodeEnd,offset _DrvInit
	mov	es:[bx]._RPINITOUT.DataEnd,ax
	mov	es:[bx]._RPH.Status,100h
	leave
	retn

loc_err4:
	call	_ReleaseMemBlock
loc_err3:
	call	_FreeMemFromGDT
loc_err2:
	call	_CloseProtman
loc_err1:
	les	bx,[bp+4]
	mov	es:[bx]._RPINITOUT.CodeEnd,0
	mov	es:[bx]._RPINITOUT.DataEnd,0
	mov	es:[bx]._RPH.Status,8115h	; quiet init fail
	leave
	retn
	
_DrvInit	endp


_FindHardware	proc	near
	call	_OpenOEMPCI
	or	ax,ax
	jnz	short loc_0
	push	offset msg_NoOEMHLP
	call	_PutMessage
	add	sp,2
	xor	ax,ax
	retn

loc_0:
	enter	6,0
FH_s	equ	bp+4	; SLOT
FH_ci	equ	bp-6	; class index
FH_di	equ	bp-5	; device index
FH_bdf	equ	bp-4	; BusDevFunc
FH_cb	equ	bp-2	; capability pointer

	push	si
	push	di
	mov	word ptr [FH_ci],0
	mov	si,offset P_OEMHLP
	mov	di,offset D_OEMHLP
loc_1:
	mov	al,[FH_ci]
	mov	[si].P_PCI_FindClass.Subfunction,PCI_FindClass
	mov	[si].P_PCI_FindClass.ClassCode,020000h	; Ethernet
	mov	[si].P_PCI_FindClass.Index,al
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e1
	mov	ax,word ptr [di].D_PCI_FindClass.Bus
	mov	[FH_bdf],ax

	mov	[si].P_PCI_ReadConfigSpace.Subfunction,PCI_ReadConfigSpace
	mov	word ptr [si].P_PCI_ReadConfigSpace.Bus,ax
	mov	[si].P_PCI_ReadConfigSpace.ConfigRegister,0
	mov	[si].P_PCI_ReadConfigSpace.RegSize,4
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e1
	mov	eax,[di].D_PCI_ReadConfigSpace.Data
	cmp	eax,30431106h		; VT86C100A
	jnz	short loc_3

	push	word ptr [FH_bdf]
	call	QueryChipRev		; < 40h
	pop	cx	; stack adjust
	cmp	al,40h
	jnc	short loc_3

loc_2:
	mov	[ChipRev],al
	mov	al,[FH_di]
	cmp	al,[FH_s]
	jz	short loc_found
	inc	byte ptr [FH_di]
loc_3:
	inc	byte ptr [FH_ci]
	jmp	short loc_1

loc_e1:
	push	offset msg_NoHardware
loc_ex:
	call	_PutMessage
	add	sp,2
	call	_CloseOEMPCI
	xor	ax,ax
	pop	di
	pop	si
	leave
	retn

loc_e2:
	push	offset msg_InvIOaddr
	jmp	short loc_ex

loc_found:
			; --- get IOaddr
	mov	ax,[FH_bdf]
	mov	[si].P_PCI_ReadConfigSpace.Subfunction,PCI_ReadConfigSpace
	mov	word ptr [si].P_PCI_ReadConfigSpace.Bus,ax
	mov	[si].P_PCI_ReadConfigSpace.ConfigRegister,10h	; IO
	mov	[si].P_PCI_ReadConfigSpace.RegSize,4
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e2
	cmp	word ptr [di].D_PCI_ReadConfigSpace.Data[2],0
	jnz	short loc_e2
	mov	ax,word ptr [di].D_PCI_ReadConfigSpace.Data
	test	al,1		; IO indicator
	jz	short loc_e2
	test	al,7eh		; bit 1..6  check alignment
	jnz	short loc_e2
	and	ax,-80h		; 0..7f
	jz	short loc_e2
	mov	IOaddr,ax

			; --- get MEMaddr
	mov	dx,[FH_bdf]
	mov	[si].P_PCI_ReadConfigSpace.Subfunction,PCI_ReadConfigSpace
	mov	word ptr [si].P_PCI_ReadConfigSpace.Bus,dx
	mov	[si].P_PCI_ReadConfigSpace.ConfigRegister,14h	; MEM
	mov	[si].P_PCI_ReadConfigSpace.RegSize,4
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e3
	mov	eax,[di].D_PCI_ReadConfigSpace.Data
	test	al,1		; memory indicator
	jnz	short loc_e3
	and	eax,-80h	; 128bytes
	jz	short loc_e3
	mov	MEMaddr,eax

			; --- get IRQlevel
loc_irq:
	mov	dx,[FH_bdf]
	mov	[si].P_PCI_ReadConfigSpace.Subfunction,PCI_ReadConfigSpace
	mov	word ptr [si].P_PCI_ReadConfigSpace.Bus,dx
	mov	[si].P_PCI_ReadConfigSpace.ConfigRegister,3Ch	; IRQ
	mov	[si].P_PCI_ReadConfigSpace.RegSize,1
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e4
	mov	al,byte ptr [di].D_PCI_ReadConfigSpace.Data
	test	drvflags,mask df_i15o
	jnz	short loc_i1
	test	al,-10h
	jnz	short loc_e4
loc_i1:
	mov	IRQlevel,al

	push	word ptr [FH_bdf]
	call	StopPowerManage
	call	GetCacheLine
	call	ChkCmdReg
	pop	ax

	call	_CloseOEMPCI
	mov	ax,1
	pop	di
	pop	si
	leave
	retn

loc_e3:
	push	offset msg_InvMEMaddr
	jmp	near ptr loc_ex
loc_e4:
	push	offset msg_InvIRQlevel
	jmp	near ptr loc_ex

QueryChipRev	proc	near
	push	bp
	mov	bp,sp
QCR_bdf	equ	bp+4	; BusDevFunc

	mov	ax,[QCR_bdf]
	mov	[si].P_PCI_ReadConfigSpace.Subfunction,PCI_ReadConfigSpace
	mov	word ptr [si].P_PCI_ReadConfigSpace.Bus,ax
	mov	[si].P_PCI_ReadConfigSpace.ConfigRegister,8	; revision
	mov	[si].P_PCI_ReadConfigSpace.RegSize,1
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_err
	mov	al,byte ptr [di].D_PCI_ReadConfigSpace.Data
	leave
	retn
loc_err:
	or	ax,-1
	leave
	retn
QueryChipRev	endp

StopPowerManage	proc	near
	enter	2,0
SPM_bdf	equ	bp+4	; BusDevFunc
SPM_cb	equ	bp-2	; capability

			; --- Capability bit in status register
	mov	dx,[SPM_bdf]
	mov	[si].P_PCI_ReadConfigSpace.Subfunction,PCI_ReadConfigSpace
	mov	word ptr [si].P_PCI_ReadConfigSpace.Bus,dx
	mov	[si].P_PCI_ReadConfigSpace.ConfigRegister,4	; cmd/sts
	mov	[si].P_PCI_ReadConfigSpace.RegSize,4
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e5
	mov	ax,word ptr [di].D_PCI_ReadConfigSpace.Data[2]
	bt	ax,4		; capability bit
	jnc	short loc_pmex

loc_pm0:
			; --- Capabitily pointer
	mov	dx,[SPM_bdf]
	mov	[si].P_PCI_ReadConfigSpace.Subfunction,PCI_ReadConfigSpace
	mov	word ptr [si].P_PCI_ReadConfigSpace.Bus,dx
	mov	[si].P_PCI_ReadConfigSpace.ConfigRegister,34h	; cap. ptr.
	mov	[si].P_PCI_ReadConfigSpace.RegSize,1
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e5
	mov	al,byte ptr [di].D_PCI_ReadConfigSpace.Data
loc_pm1:
	cmp	al,40h
	jc	short loc_pmex
	mov	[SPM_cb],al

			; --- Power Management Capability?
	mov	dx,[SPM_bdf]
	mov	[si].P_PCI_ReadConfigSpace.Subfunction,PCI_ReadConfigSpace
	mov	word ptr [si].P_PCI_ReadConfigSpace.Bus,dx
	mov	[si].P_PCI_ReadConfigSpace.ConfigRegister,al	; capabilities
	mov	[si].P_PCI_ReadConfigSpace.RegSize,4
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e5
	mov	ax,word ptr [di].D_PCI_ReadConfigSpace.Data
	cmp	al,1		; Power Management
	mov	al,ah		; next ptr
	jnz	short loc_pm1

			; --- check Power Management status
	mov	al,[SPM_cb]
	mov	dx,[SPM_bdf]
	add	al,4
	mov	[si].P_PCI_ReadConfigSpace.Subfunction,PCI_ReadConfigSpace
	mov	word ptr [si].P_PCI_ReadConfigSpace.Bus,dx
	mov	[si].P_PCI_ReadConfigSpace.ConfigRegister,al	; PM ctr/sts
	mov	[si].P_PCI_ReadConfigSpace.RegSize,4
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e5
	mov	eax,dword ptr [di].D_PCI_ReadConfigSpace.Data
;	test	ax,8103h	; PMESTS, PMEEN, PSTATE
	test	ax,8003h	; PMESTS, PSTATE
	jnz	short loc_pm2
loc_pmex:
	leave
	retn

loc_e5:
	push	offset msg_PMFail
	call	_PutMessage
	jmp	short loc_pmex


loc_pm2:
			; stop Power Management
;	and	ax,not 0103h	; D0 state, clear PMEEN
	and	al,not 3h	; D0 state
	or	ah,80h		; clear PMESTS
	mov	cl,[SPM_cb]
	mov	dx,[SPM_bdf]
	add	cl,4
	mov	[si].P_PCI_WriteConfigSpace.Subfunction,PCI_WriteConfigSpace
	mov	word ptr [si].P_PCI_WriteConfigSpace.Bus,dx
	mov	[si].P_PCI_WriteConfigSpace.ConfigRegister,cl	; PM ctr/sts
	mov	[si].P_PCI_WriteConfigSpace.RegSize,4
	mov	dword ptr [si].P_PCI_WriteConfigSpace.Data,eax
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e5

	push	offset msg_PMStop
	call	_PutMessage

	leave
	retn
StopPowerManage	endp

GetCacheLine	proc	near
	push	bp
	mov	bp,sp

GCL_bdf	equ	bp+4

	mov	dx,[GCL_bdf]
	mov	[si].P_PCI_ReadConfigSpace.Subfunction,PCI_ReadConfigSpace
	mov	word ptr [si].P_PCI_ReadConfigSpace.Bus,dx
	mov	[si].P_PCI_ReadConfigSpace.ConfigRegister,0ch	; CLS/LT
	mov	[si].P_PCI_ReadConfigSpace.RegSize,2
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_err
	mov	ax,word ptr [di].D_PCI_ReadConfigSpace.Data
	mov	[Latency],ah
	mov	ah,0
	bsr	cx,ax
	jz	short loc_ok	; 0 -> OK
	bsf	ax,ax
	cmp	ax,cx
	jnz	short loc_bad	; bad alignment, use 0.
	sub	al,2
	jna	short loc_bad	; size < 8 dword
	cmp	al,3
	ja	short loc_bad	; size > 32 dword
loc_ok:
	mov	[CacheLine],al
loc_err:
	pop	bp
	retn

loc_bad:
	mov	dx,[GCL_bdf]
	mov	[si].P_PCI_WriteConfigSpace.Subfunction,PCI_WriteConfigSpace
	mov	word ptr [si].P_PCI_WriteConfigSpace.Bus,dx
	mov	[si].P_PCI_WriteConfigSpace.ConfigRegister,0ch	; CLS
	mov	[si].P_PCI_WriteConfigSpace.RegSize,1
	mov	byte ptr [si].P_PCI_WriteConfigSpace.Data,0
	call	IOCtlOEMPCI
	xor	ax,ax
	jmp	short loc_ok
GetCacheLine	endp

ChkCmdReg	proc	near
CCR_bdf	equ	bp+4	; BusDevFunc
	push	bp
	mov	bp,sp

			; --- clear status
	mov	dx,[CCR_bdf]
	or	ax,-1			; -1: clear PCI status register
	mov	[si].P_PCI_WriteConfigSpace.Subfunction,PCI_WriteConfigSpace
	mov	word ptr [si].P_PCI_WriteConfigSpace.Bus,dx
	mov	[si].P_PCI_WriteConfigSpace.ConfigRegister,6	; sts
	mov	[si].P_PCI_WriteConfigSpace.RegSize,2
	mov	word ptr [si].P_PCI_WriteConfigSpace.Data,ax
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e6

			; --- read command
	mov	ax,[CCR_bdf]
	mov	[si].P_PCI_ReadConfigSpace.Subfunction,PCI_ReadConfigSpace
	mov	word ptr [si].P_PCI_ReadConfigSpace.Bus,ax
	mov	[si].P_PCI_ReadConfigSpace.ConfigRegister,4	; cmd
	mov	[si].P_PCI_ReadConfigSpace.RegSize,2
	call	IOCtlOEMPCI		; read PCI command register
	or	ax,ax
	jnz	short loc_e6

	mov	ax,word ptr [di].D_PCI_ReadConfigSpace.Data
	and	al,4 or 2		; bus master / memory
	cmp	al,4 or 2
	jz	short loc_1

			; --- write command. set Bus Master/memory bits
	mov	ax,word ptr [di].D_PCI_ReadConfigSpace.Data
	mov	dx,[CCR_bdf]
	or	al,4 or 2
	mov	[si].P_PCI_WriteConfigSpace.Subfunction,PCI_WriteConfigSpace
	mov	word ptr [si].P_PCI_WriteConfigSpace.Bus,dx
	mov	[si].P_PCI_WriteConfigSpace.ConfigRegister,4	; cmd
	mov	[si].P_PCI_WriteConfigSpace.RegSize,2
	mov	word ptr [si].P_PCI_WriteConfigSpace.Data,ax
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e6

	push	offset msg_ModifyCmd
	call	_PutMessage
;	pop	ax
loc_1:
	leave
	retn
loc_e6:
	push	offset msg_ChkCmdFail
	call	_PutMessage
;	pop	ax
	leave
	retn
ChkCmdReg	endp


IOCtlOEMPCI	proc	near
	push	si
	push	di

	push	ds
	push	di
	push	ds
	push	si
	push	OEMHLP_PCI
	push	IOCTL_OEMHLP
	push	[handle_OEMHLP]
	call	Dos16DevIOCtl

	neg	ax
	pop	di
	pop	si
	setc	ah
	mov	al,[di]
	retn
IOCtlOEMPCI	endp

_OpenOEMPCI	proc	near
	push	cx
	mov	ax,sp
	push	si
	push	di

	push	ds
	push	offset name_OEMHLP	; file name
	push	ds
	push	offset handle_OEMHLP	; file handle
	push	ss
	push	ax		; action taken
	push	0
	push	0		; File size
	push	0		; File attribute
	push	1		; Open flag (Open if exist)
	push	42h		; Open Mode
	push	0
	push	0		; reserve (NULL)
	call	Dos16Open
	or	ax,ax
	jnz	short loc_e1
	
	mov	si,offset P_OEMHLP
	mov	di,offset D_OEMHLP
	mov	[si].P_PCI_QueryBIOS.Subfunction,PCI_QueryBIOS
	call	IOCtlOEMPCI
	or	ax,ax
	jnz	short loc_e2
	mov	ax,1
loc_ex:
	pop	di
	pop	si
	pop	cx
	retn
loc_e2:
	call	_CloseOEMPCI
loc_e1:
	xor	ax,ax
	jmp	short loc_ex
_OpenOEMPCI	endp

_CloseOEMPCI	proc	near
	push	[handle_OEMHLP]
	call	Dos16Close
	retn
_CloseOEMPCI	endp

_FindHardware	endp

_SetMemToGDT	proc	near
	push	si
	push	di
	mov	ax,ds
	mov	es,ax
	mov	di,offset MEMSel
	mov	cx,1
	mov	dl,DevHlp_AllocGDTSelector
	call	dword ptr [DevHelp]
	jc	short loc_e1
	mov	bx,word ptr [MEMaddr]
	mov	ax,word ptr [MEMaddr][2]
	mov	cx,80h		; 128bytes
	mov	si,[MEMSel]
	mov	dl,DevHlp_PhysToGDTSelector
	call	dword ptr [DevHelp]
	jc	short loc_e2
	mov	ax,1
	pop	di
	pop	si
	retn

public	_FreeMemFromGDT
_FreeMemFromGDT::
	push	si
	push	di
loc_e2:
	mov	ax,[MEMSel]
	mov	dl,DevHlp_FreeGDTSelector
	call	dword ptr [DevHelp]
loc_e1:
	xor	ax,ax
	pop	di
	pop	si
	retn
_SetMemToGDT	endp


_ResolveName	proc	near
	enter	6,0
	push	si
	push	di
	xor	bx,bx
	mov	si,offset TmpDrvName
loc_1:
	cmp	byte ptr [bx+si],'$'
	jz	short loc_2
	inc	bx
	cmp	bx,8
	jb	short loc_1
loc_e:
	xor	ax,ax		; invalid name
	jmp	near ptr loc_err
loc_2:
	test	bx,bx
	jz	short loc_e
	mov	[bp-2],bx
	mov	byte ptr [bx+si+1],0
loc_3:
	lea	di,[bp-4]
	lea	bx,[bp-6]
	push	ds
	push	si		; name
	push	ss
	push	bx		; handle
	push	ss
	push	di		; action
	push	0
	push	0		; file size
	push	0		; attribute
	push	1		; Open flag
	push	42h		; Open mode
	push	0		; reserve
	push	0
	call	Dos16Open
	or	ax,ax
	jnz	short loc_5	; this name is not used. OK.

	push	word ptr [bp-6]
	call	Dos16Close
	mov	bx,[bp-2]
	cmp	bx,7		; already max length
	jnb	short loc_e
	mov	si,offset TmpDrvName
	cmp	byte ptr [bx+si],'$'
	jz	short loc_4	; first modification
	cmp	byte ptr [bx+si],'9'
	jz	short loc_e	; last modification. failure.
	inc	byte ptr [bx+si]
	jmp	short loc_3
loc_4:
	mov	word ptr [bx+si],'$1'
	mov	byte ptr [bx+si+2],0
	jmp	short loc_3

loc_5:
	mov	cx,8
	mov	si,offset TmpDrvName
	mov	di,offset DrvName
	push	ds
	pop	es
	cld
loc_6:
	lodsb
	cmp	al,0
	jz	short loc_7
	stosb
	dec	cx
	jnz	short loc_6
loc_7:
	jcxz	short loc_8
	mov	al,' '
	rep	stosb

loc_8:
	mov	ax,1
loc_err:
	pop	di
	pop	si
	leave
	retn
_ResolveName	endp


_OpenProtman	proc	near
	enter	2,0
	mov	ax,sp
	push	ds
	push	offset name_Protman	; file name
	push	ds
	push	offset handle_Protman	; file handle
	push	ss
	push	ax		; action taken
	push	0
	push	0		; File size
	push	0		; File attribute
	push	1		; Open flag (Open if exist)
	push	42h		; Open Mode
	push	0
	push	0		; reserve (NULL)
	call	Dos16Open
	mov	dx,ax
	neg	ax
	sbb	ax,ax
	inc	ax
	leave
	retn
_OpenProtman	endp

_CloseProtman	proc	near
	mov	ax,[handle_Protman]
	push	ax
	call	Dos16Close
	retn
_CloseProtman	endp

_RegisterModule	proc	near
	mov	cx,cs
	mov	ax,ds
	and	cl,-8

	mov	CommonChar.moduleDS,ax
	mov	word ptr CommonChar.cctsrd[2],cx
	mov	word ptr CommonChar.cctssc[2],ax
	mov	word ptr CommonChar.cctsss[2],ax
	mov	word ptr CommonChar.cctupd[2],ax
	mov	word ptr MacChar.mcal[2],ax
	mov	word ptr MacChar.mctAdapterDesc[2],ax
	mov	word ptr UpDisp.updpbp[2],ax
	mov	word ptr UpDisp.request[2],cx
	mov	word ptr UpDisp.txchain[2],cx
	mov	word ptr UpDisp.rxdata[2],cx
	mov	word ptr UpDisp.rxrelease[2],cx
	mov	word ptr UpDisp.indon[2],cx
	mov	word ptr UpDisp.indoff[2],cx

	mov	al,IRQlevel
	mov	ah,0
	mov	MacChar.mctIRQ,ax
	mov	al,cfgTXQUEUE
	mov	dx,cfgMAXFRAMESIZE
	mov	MacChar.mcttqd,ax
	mov	MacChar.mfs,dx
	mov	MacChar.tbs,dx
	mov	MacChar.rbs,dx
	mul	dx
	mov	word ptr MacChar.ttbc,ax
	mov	word ptr MacChar.ttbc[2],dx
	mov	al,cfgRXQUEUE
	mov	ah,0
	mov	dx,1536		; rx fragment size
	mul	dx
	mov	word ptr MacChar.trbc,ax
	mov	word ptr MacChar.trbc[2],dx
	mov	MacChar.linkspeed,100000000

	xor	ax,ax
	mov	PMparm.PMCode,RegisterModule	; opcode 2
	mov	word ptr PMparm.PMPtr1,offset CommonChar
	mov	word ptr PMparm.PMPtr1[2],ds
	mov	word ptr PMparm.PMPtr2,ax
	mov	word ptr PMparm.PMPtr2[2],ax
	mov	PMparm.PMWord,ax

	push	ax
	push	ax
	push	ds
	push	offset PMparm
	push	ProtManCode
	push	LanManCat
	push	[handle_Protman]
	call	Dos16DevIOCtl

	neg	ax
	sbb	ax,ax
	inc	ax
	retn
_RegisterModule	endp


_ScanConfigImage	proc	near
	mov	[PMparm.PMCode],GetProtManInfo	; opcode 1
	push	0
	push	0		; data (NULL)
	push	ds
	push	offset PMparm	; parameter
	push	ProtManCode	; function 58h
	push	LanManCat	; category 81h
	push	word ptr [handle_Protman]
	call	Dos16DevIOCtl
	or	ax,ax
	mov	dx,offset msg_ProtIOCtl
	jnz	short loc_e1
	cmp	[PMparm.PMWord],ProtManLevel	; level 1
	jz	short loc_0
	mov	dx,offset msg_ProtLevel
loc_e1:
	push	dx
	call	_PutMessage
	pop	dx
	xor	ax,ax
	retn


loc_0:
	push	bp
	push	si
	push	di
	push	gs
	cld
			; --- scan driver name ---
			; es:bx = module,  es:bp = keyword
	lgs	bx,[PMparm.PMPtr1]
loc_Module:
	mov	ax,gs
	mov	es,ax
	lea	bp,[bx].ModuleConfig.Keyword1

loc_NameKey:
	mov	si,offset Key_DRIVERNAME	; 'DRIVERNAME'
	mov	cx,12/4
	lea	di,[bp].KeywordEntry.Keyword
	repz	cmpsd
	jnz	short loc_NextNameKey
	lea	di,[bp].KeywordEntry.cmiParam1
	cmp	es:[di].cmiParam.ParamType,1	; type is string?
	jnz	short loc_NextModule
	mov	cx,es:[di].cmiParam.ParamLen
	mov	si,offset TmpDrvName
	lea	di,[di].cmiParam.Param
	repz	cmpsb
	jz	short loc_found_drv

loc_NextModule:
	cmp	gs:[bx].ModuleConfig.NextModule,0
	jz	short loc_NoModule
	lgs	bx,gs:[bx].ModuleConfig.NextModule
	jmp	short loc_Module

loc_NextNameKey:
	cmp	es:[bp].KeywordEntry.NextKeyword,0
	jz	short loc_NextModule
	les	bp,es:[bp].KeywordEntry.NextKeyword
	jmp	short loc_NameKey


loc_found_drv:
	mov	di,offset CommonChar.cctname
	lea	si,[bx].ModuleConfig.ModuleName
	mov	cx,16/4
	push	es
	push	ds
	pop	es
			; set ModuleName in common char. table
	rep	movsd	es:[di],gs:[si]
	pop	es

loc_KeyM:
	cmp	es:[bp].KeywordEntry.NextKeyword,0
	jz	short loc_KeyEnd
	les	bp,es:[bp].KeywordEntry.NextKeyword

	mov	bx,offset DrvKeyword1
loc_KeyD:
	lea	di,[bp].KeywordEntry.Keyword
	mov	si,[bx].cfgKeyDesc.KeyStrPtr
	mov	cx,[bx].cfgKeyDesc.KeyStrLen
	repz	cmpsb
	jnz	short loc_KeyD1
	call	word ptr [bx].cfgKeyDesc.KeyProc
	jnc	short loc_KeyM
	jmp	short loc_BadKey

loc_KeyD1:
	mov	bx,[bx].cfgKeyDesc.NextKey
	or	bx,bx
	jnz	short loc_KeyD
	jmp	short loc_UnknownKey

loc_UnknownKey:
	or	cfgKeyWarn,mask cwUnk	; Warning: Unknown
	jmp	short loc_KeyM

loc_NoModule:
	mov	dx,offset msg_NoModule
loc_BadKey:
	push	dx
	call	_PutMessage
	add	sp,2
	xor	ax,ax
	jmp	short loc_scmExit

loc_KeyEnd:
	mov	ax,1
loc_scmExit:
	pop	gs
	pop	di
	pop	si
	pop	bp
	retn

; --- Keyword check ---  es:bp = KeywordEntry
sci_SLOT	proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,0
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,8
	jnc	short loc_ce
	mov	cfgSLOT,al
	clc
	ret
loc_ce:
	mov	dx,offset msg_InvSLOT
	stc
	retn
sci_SLOT	endp

sci_TXQUEUE	proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,0
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	mov	ah,3
	cmp	al,ah
	jb	short loc_w
	mov	ah,41
	cmp	al,ah
	ja	short loc_w
loc_ex:
	mov	cfgTXQUEUE,al
	clc
	retn
loc_w:
	mov	al,ah
	or	cfgKeyWarn,mask cwTXQ	; Warning: out of range.
	jmp	short loc_ex
loc_ce:
	mov	dx,offset msg_InvTXQUEUE
	stc
	retn
sci_TXQUEUE	endp

sci_RXQUEUE	proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,0
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	mov	ah,3
	cmp	al,ah
	jb	short loc_w
	mov	ah,41
	cmp	al,ah
	ja	short loc_w
loc_ex:
	mov	cfgRXQUEUE,al
	clc
	retn
loc_w:
	mov	al,ah
	or	cfgKeyWarn,mask cwRXQ	; Warning: out of range.
	jmp	short loc_ex
loc_ce:
	mov	dx,offset msg_InvRXQUEUE
	stc
	retn
sci_RXQUEUE	endp

sci_TXEARLY	proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,0
	jnz	short loc_ce
	mov	ax,word ptr es:[bp].KeywordEntry.cmiParam1.Param
	mov	cl,7

	test	ax,ax
	jz	short loc_0
	dec	cx
	cmp	ax,1024
	jz	short loc_0
	dec	cx
	cmp	ax,768
	jz	short loc_0
	dec	cx
	cmp	ax,512
	jz	short loc_0
	dec	cx
	cmp	ax,256
	jz	short loc_0
	dec	cx
	cmp	ax,128
	jz	short loc_0
	dec	cx
	cmp	ax,32
	jz	short loc_0
	dec	cx
	cmp	ax,64
	jnz	short loc_w
loc_0:
	shl	cl,5
	mov	cfgTxDRTH,cl
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwTXEAR	; Warning: Invalid TxDRTH
	jmp	short loc_ex
sci_TXEARLY	endp

sci_RXEARLY	proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,0
	jnz	short loc_ce
	mov	ax,word ptr es:[bp].KeywordEntry.cmiParam1.Param

	xor	cx,cx
	cmp	ax,64
	jz	short loc_0
	inc	cx
	cmp	ax,32
	jz	short loc_0
	inc	cx
	cmp	ax,128
	jz	short loc_0
	inc	cx
	cmp	ax,256
	jz	short loc_0
	inc	cx
	cmp	ax,512
	jz	short loc_0
	inc	cx
	cmp	ax,768
	jz	short loc_0
	inc	cx
	cmp	ax,1024
	jz	short loc_0
	inc	cx
	or	ax,ax
	jnz	short loc_w
loc_0:
	shl	cl,5
	mov	cfgRxDRTH,cl
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwRXEAR	; Warning: Invalid RxDRTH
	jmp	short loc_ex
sci_RXEARLY	endp

sci_MXDMA	proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,0
	jnz	short loc_ce
	mov	ax,word ptr es:[bp].KeywordEntry.cmiParam1.Param
	mov	dl,6
	bsf	cx,ax
	jz	short loc_0	; 0 unlimited
	bsr	dx,ax		; [5..10]<-[32..1024]
	cmp	cx,dx
	jnz	short loc_w
	sub	dl,5		; [0..5]
	jc	short loc_w
	cmp	dl,5
	ja	short loc_w
loc_0:
	mov	cfgBCR0,dl
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwMXDMA	; Warning: Invalid MXDMA.
	jmp	short loc_ex
sci_MXDMA	endp

sci_TXARB		proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,1
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,'Y'
	setz	ah		; 'Y'->1  'N'->0
	jz	short loc_y
	cmp	al,'N'
	jnz	short loc_w
loc_n:
loc_y:
	shl	ah,4
	and	cfgCFGB,not TxARBIT
	or	cfgCFGB,ah
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwTXARB	; Warning: Invalid TxARB
	jmp	short loc_ex
sci_TXARB		endp

sci_RXARB		proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,1
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,'Y'
	setz	ah		; 'Y'->1  'N'->0
	jz	short loc_y
	cmp	al,'N'
	jnz	short loc_w
loc_n:
loc_y:
	shl	ah,3
	and	cfgCFGB,not RxARBIT
	or	cfgCFGB,ah
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwRXARB	; Warning: Invalid RxARB
	jmp	short loc_ex
sci_RXARB		endp

sci_DAPOL		proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,1
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,'Y'
	setnz	ah		; 'Y'->0  'N'->1
	jz	short loc_y
	cmp	al,'N'
	jnz	short loc_w
loc_n:
loc_y:
	shl	ah,3
	mov	cfgDAPOLL,ah
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwDAPOL	; Warning: Invalid DAPOLL
	jmp	short loc_ex
sci_DAPOL		endp

sci_POLTMR	proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,0
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,7
	ja	short loc_w
loc_0:
	and	cfgBCR1,not POT
	or	cfgBCR1,al
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwPLTMR	; Warning: Invalid POLLTMR.
	jmp	short loc_ex
sci_POLTMR	endp

sci_MRM		proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,1
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,'Y'
	setz	ah		; 'Y'->1  'N'->0
	jz	short loc_y
	cmp	al,'N'
	jnz	short loc_w
loc_n:
loc_y:
	shl	ah,5
	and	cfgCFGB,not MRMEN
	or	cfgCFGB,ah
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwMRM	; Warning: Invalid PCIMRM
	jmp	short loc_ex
sci_MRM		endp

sci_MRL		proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,1
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,'Y'
	setz	ah		; 'Y'->1  'N'->0
	jz	short loc_y
	cmp	al,'N'
	jnz	short loc_w
loc_n:
loc_y:
	shl	ah,5
	and	cfgCFGD,not MRLEN
	or	cfgCFGD,ah
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwMRL	; Warning: Invalid PCIMRL
	jmp	short loc_ex
sci_MRL		endp

sci_MRW		proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,1
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,'Y'
	setz	ah		; 'Y'->1  'N'->0
	jz	short loc_y
	cmp	al,'N'
	jnz	short loc_w
loc_n:
loc_y:
	shl	ah,2
	and	cfgCFGB,not MRWAIT
	or	cfgCFGB,ah
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwMRW	; Warning: Invalid PCIMRW
	jmp	short loc_ex
sci_MRW		endp

sci_MWW		proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,1
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,'Y'
	setz	ah		; 'Y'->1  'N'->0
	jz	short loc_y
	cmp	al,'N'
	jnz	short loc_w
loc_n:
loc_y:
	shl	ah,1
	and	cfgCFGB,not MWWAIT
	or	cfgCFGB,ah
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwMWW	; Warning: Invalid PCIMWW
	jmp	short loc_ex
sci_MWW		endp

sci_LAT		proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,1
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,'Y'
	setz	ah		; 'Y'->1  'N'->0
	jz	short loc_y
	cmp	al,'N'
	jnz	short loc_w
loc_n:
loc_y:
	and	cfgCFGB,not MRWAIT
	or	cfgCFGB,ah
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwLAT	; Warning: Invalid PCILAT
	jmp	short loc_ex
sci_LAT		endp

sci_MXFS	proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,0
	jnz	short loc_ce
IF 0	; do nothing
	mov	ax,word ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	ax,9014
	ja	short loc_w
	cmp	ax,1514
	jb	short loc_w

	mov	cfgMAXFRAMESIZE,ax
ENDIF
loc_ex:
	clc
	retn
loc_ce:
loc_w:
	or	cfgKeyWarn,mask cwMXFS	; Warning: Invalid frame size.
	jmp	short loc_ex
sci_MXFS	endp

sci_NETADR	proc	near
	push	si
	push	di
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,1	; string
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamLen,12
	jc	short loc_ce
	xor	si,si
	xor	di,di
loc_0:
	mov	al,byte ptr es:[bp+si].KeywordEntry.cmiParam1.Param
	sub	al,'0'
	jc	short loc_w
	cmp	al,9
	jna	short loc_1
	and	al,1fh
	sub	al,'A'-'0'-10
	cmp	al,0fh
	ja	short loc_w
loc_1:
	shl	ax,4+8
	mov	al,byte ptr es:[bp+si+1].KeywordEntry.cmiParam1.Param
	sub	al,'0'
	jc	short loc_w
	cmp	al,9
	jna	short loc_2
	and	al,1fh
	sub	al,'A'-'0'-10
	cmp	al,0fh
	ja	short loc_w
loc_2:
	or	al,ah
	mov	MacChar.mctcsa[di],al
	add	si,2
	inc	di
	cmp	si,2*6
	jc	short loc_0

	test	byte ptr MacChar.mctcsa,1
	jnz	short loc_w	; multicast/broadcast
loc_ex:
	pop	di
	pop	si
	clc
	retn
loc_ce:
loc_w:
	xor	ax,ax
	mov	word ptr MacChar.mctcsa,ax
	mov	word ptr MacChar.mctcsa[2],ax
	mov	word ptr MacChar.mctcsa[4],ax
;	or	cfgKeyWarn,mask cwNETADR	; Warning: Invalid address.
	jmp	short loc_ex
sci_NETADR	endp

sci_OPBND		proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,1
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,'Y'
	setz	ah		; 'Y'->1  'N'->0
	jz	short loc_y
	cmp	al,'N'
	jnz	short loc_w
loc_n:
loc_y:
	mov	al,0
	xchg	al,ah
	shl	ax,df_opbnd
	and	drvflags,not (mask df_opbnd)
	or	drvflags,ax
loc_ex:
	clc
	retn
loc_ce:
loc_w:
;	or	cfgKeyWarn,mask cwOPBND	; Warning: Invalid open_bind
	jmp	short loc_ex
sci_OPBND		endp

sci_IRQ15O	proc	near
	cmp	es:[bp].KeywordEntry.NumParams,1
	jnz	short loc_ce
	cmp	es:[bp].KeywordEntry.cmiParam1.ParamType,1
	jnz	short loc_ce
	mov	al,byte ptr es:[bp].KeywordEntry.cmiParam1.Param
	cmp	al,'Y'
	setz	ah		; 'Y'->1  'N'->0
	jz	short loc_y
	cmp	al,'N'
	jnz	short loc_w
loc_n:
loc_y:
	mov	al,0
	xchg	al,ah
	shl	ax,df_i15o
	and	[drvflags],not (mask df_i15o)
	or	[drvflags],ax
loc_ex:
	clc
	retn
loc_ce:
loc_w:
;	or	cfgKeyWarn,mask cwI15O ; Warning: Invalid IRQ15OVR.
	jmp	short loc_ex
sci_IRQ15O	endp

_ScanConfigImage	endp


_AllocMemBlock	proc	near
	enter	10,0
	push	esi
	push	edi

	mov	al,cfgRXQUEUE
	mov	ah,0
	mov	cl,cfgTXQUEUE
	mov	ch,0
	inc	ax		; for rx terminator
	inc	cx		; for tx terminator
	mov	dx,1536		; fragment 1.5Kbytes
	add	ax,cx
	mul	dx
	mov	[bp-4],ax
	mov	[bp-2],dx	; memory block size

	mov	cx,42*1536	; 63Kbytes check
	div	cx
	neg	dx
	adc	ax,1		; request GDT selector count
				; +1 for TxCopySel
	mov	[BufferSelCnt],ax

	push	ds		; allocate GDT selector
	pop	es
	mov	di,offset TxCopySel
	mov	cx,ax
	mov	dl,DevHlp_AllocGDTSelector
	call	dword ptr [DevHelp]
	jc	near ptr loc_e1		; Too long distance(T_T)

IF 0
	xor	esi,esi		; Get Linear address for VMAlloc param
	mov	ax,ds
	mov	si,offset BufferPhys
	mov	dl,DevHlp_VirtToLin
	call	dword ptr [DevHelp]
	jc	short loc_e2

	mov	edi,eax
ELSE
		; We can simplify when we use LX format... 
	mov	edi,offset flat:BufferPhys
ENDIF
	mov	ecx,[bp-4]
	mov	eax,VMDHA_FIXED or VMDHA_CONTIG or VMDHA_USEHIGHMEM
	mov	dl,DevHlp_VMAlloc
	call	dword ptr [DevHelp]
	jnc	short loc_0
		; VMAlloc fails if EARLYMEMINIT=TRUE is specified.
		; Return code is 0x57, invalid_parameter.
		; On this condition, remove VMDHA_USEHIGHMEM and retry.
		; System/Driver space(very high) is allocated.
	mov	eax,VMDHA_FIXED or VMDHA_CONTIG
	call	dword ptr [DevHelp]
	jc	short loc_e2
loc_0:
	mov	[BufferLin],eax
	mov	[bp-8],eax
	xor	di,di
	mov	[bp-10],di
loc_1:
	mov	ecx,42*1536
	cmp	ecx,[bp-4]
	jc	short loc_2
	mov	ecx,[bp-4]
loc_2:
	sub	[bp-4],ecx	; remain block size
	mov	ebx,[bp-8]	; linear address
	add	[bp-8],ecx
	mov	di,[bp-10]
	mov	ax,[BufferSel][di]	; selector
	add	word ptr [bp-10],2
	mov	dl,DevHlp_LinToGDTSelector
	call	dword ptr [DevHelp]
	jc	short loc_e3

	cmp	dword ptr [bp-4],0
	jnz	short loc_1

	mov	ax,1
	pop	edi
	pop	esi
	leave
	retn

public	_ReleaseMemBlock
_ReleaseMemBlock::
	push	bp
	mov	bp,sp
	push	esi
	push	edi
loc_e3:
	mov	eax,[BufferLin]
	mov	dl,DevHlp_VMFree
	call	dword ptr [DevHelp]
loc_e2:
	dec	[BufferSelCnt]
	jl	short loc_e1
	mov	bx,[BufferSelCnt]
	add	bx,bx
	mov	ax,[TxCopySel][bx]	; free selector
	mov	dl,DevHlp_FreeGDTSelector
	call	dword ptr [DevHelp]
	jmp	short loc_e2
loc_e1:
	xor	ax,ax
	pop	edi
	pop	esi
	leave
	retn
_AllocMemBlock	endp


_InitQueue	proc	near
	enter	10,0
	push	di
	mov	eax,[BufferPhys]
	mov	[bp-10],eax		; buffer physical address
	xor	ax,ax
	mov	[bp-6],ax		; selector index
	mov	[bp-4],ax		; buffer virtual address

				; --- allocate TD
	mov	al,[cfgTXQUEUE]
	inc	ax			; +1 for terminator
	mov	[bp-2],ax		; loop count
loc_T0:
;	push	16
	push	32
	push	sizeof(TD)
	call	_AllocHeap
	push	ds
	push	ax
	call	_VirtToPhys
	pop	bx
	add	sp,3*2
	mov	ecx,[bp-10]
	mov	edx,1536
	mov	[bx].TD.phys,eax
	mov	[bx].TD.buf,ecx
	add	dword ptr [bp-10],edx	; next physical address
	mov	di,[bp-6]		; selector index
	mov	ax,[bp-4]		; virtual address offset
	mov	cx,[BufferSel][di]	; virtaul address selector
	mov	word ptr [bx].TD.vbuf,ax
	mov	word ptr [bx].TD.vbuf[2],cx
	add	ax,dx			; next offset
	cmp	ax,42*1536		; check 63KB boundary
	jb	short loc_T1
	xor	ax,ax
	add	word ptr [bp-6],2	; next selector
loc_T1:
	mov	[bp-4],ax

	cmp	[TxHead],0
	jnz	short loc_T2
	mov	[TxHead],bx
	jmp	short loc_T3
loc_T2:
	mov	di,[TxFreeHead]
	mov	eax,[bx].TD.phys
	mov	[di].TD.lnk,eax
	mov	[di].TD.vlnk,bx
loc_T3:
	mov	[TxFreeHead],bx
	dec	word ptr [bp-2]
	jnz	short loc_T0

	mov	di,[TxHead]		; ring. chain tail to haed
	mov	eax,[di].TD.phys
	mov	[bx].TD.lnk,eax
	mov	[bx].TD.vlnk,di
	mov	[TxFreeHead],di

				; --- allocate RD
	mov	al,[cfgRXQUEUE]
	mov	ah,0
	inc	ax			; +1 for terminator
	mov	[bp-2],ax		; loop count
loc_R0:
;	push	16
	push	32
	push	sizeof(RD)
	call	_AllocHeap
	push	ds
	push	ax
	call	_VirtToPhys
	pop	bx
	add	sp,3*2
	mov	ecx,[bp-10]		; buffer physical address
	mov	edx,1536		; buffer size
	mov	[bx].RD.phys,eax
	mov	[bx].RD.buf,ecx
	add	dword ptr [bp-10],edx	; next physical address
	mov	word ptr [bx].RD.sts,RxCHN
	mov	word ptr [bx].RD.sts[2],highword(OWN)
	mov	word ptr [bx].RD.ctl,dx
	mov	di,[bp-6]		; selector index
	mov	ax,[bp-4]		; virtual address offset
	mov	cx,[BufferSel][di]	; virtaul address selector
	mov	word ptr [bx].RD.vbuf,ax
	mov	word ptr [bx].RD.vbuf[2],cx
	add	ax,dx			; next offset
	cmp	ax,42*1536		; check 63KB boundary
	jb	short loc_R1
	xor	ax,ax
	add	word ptr [bp-6],2	; next selector
loc_R1:
	mov	[bp-4],ax

	cmp	[RxHead],0
	jnz	short loc_R2
	mov	[RxHead],bx
	jmp	short loc_R3
loc_R2:
	mov	di,[RxTail]
	mov	eax,[bx].RD.phys
	mov	[di].RD.lnk,eax
	mov	[di].RD.vlnk,bx
loc_R3:
	mov	[RxTail],bx
	dec	word ptr [bp-2]
	jnz	short loc_R0

	mov	word ptr [bx].RD.sts[2],0	; clear OWN, Terminate

	mov	ax,1
	pop	di
	leave
	retn


; pheap AllocHeap( ushort size, ushort align);
_AllocHeap	proc	near
	push	bp
	mov	bp,sp
	push	cx
	push	dx
	mov	cx,[bp+4]	; size
	mov	bp,[bp+6]	; alignment
	bsf	ax,bp
	jz	short loc_ok	; no alignment
	bsr	dx,bp
	sub	ax,dx
	jnz	short loc_e	; alignment error
	cmp	cx,4096
	ja	short loc_e	; > page size
	mov	ax,[HeapEnd]
	mov	dx,bp
	add	ax,word ptr [DS_Lin]
	dec	dx
	and	ax,dx
	jz	short loc_1	; alignment ok
	sub	ax,bp
	sub	[HeapEnd],ax	; alignment adjust
loc_1:
	mov	ax,[HeapEnd]
	mov	dx,cx
	add	ax,word ptr [DS_Lin]
	dec	dx
	mov	bp,ax
	add	ax,dx
	xor	ax,bp
	test	ax,-1000h	; in a page
	jz	short loc_ok
	and	bp,0fffh
	sub	bp,1000h
	sub	[HeapEnd],bp	; page top
loc_ok:
	mov	ax,[HeapEnd]
	add	[HeapEnd],cx

	push	cx
	push	ds
	push	ax
	call	_ClearMemBlock
	pop	ax
	add	sp,4
	clc
loc_ex:
	pop	dx
	pop	cx
	pop	bp
	retn
loc_e:
	xor	ax,ax
	stc
	jmp	short loc_ex
_AllocHeap	endp

_ClearMemBlock	proc	near
	push	bp
	mov	bp,sp
	push	eax
	push	cx
	push	dx
	push	di
	push	es

	cld
	les	di,[bp+4]
	mov	cx,[bp+8]
	mov	dx,cx
	xor	eax,eax
	shr	cx,2
	and	dx,3
	rep	stosd
	mov	cx,dx
	rep	stosb

	pop	es
	pop	di
	pop	dx
	pop	cx
	pop	eax
	pop	bp
	retn
_ClearMemBlock	endp
_InitQueue	endp

_AllocCtxHook	proc	near
	mov	eax,offset CtxEntry
	or	ebx,-1
	mov	dl,DevHlp_AllocateCtxHook
	call	dword ptr [DevHelp]
	jc	short loc_e
	mov	[CtxHandle],eax
	mov	ax,1
	retn
loc_e:
	xor	ax,ax
	retn
_AllocCtxHook	endp

_SetDrvEnv	proc	near
	push	esi
	xor	cx,cx
	mov	al,DHGETDOSV_SYSINFOSEG
	mov	dl,DevHlp_GetDOSVar
	call	dword ptr [DevHelp]
	jc	short loc_e
	mov	es,ax
	mov	ax,es:[bx]
	mov	[SysSel],ax

IF 0
	xor	esi,esi
	mov	ax,ds
	mov	dl,DevHlp_VirtToLin
	call	dword ptr [DevHelp]
	jc	short loc_e
	mov	[DS_Lin],eax
ELSE
	mov	[DS_Lin],offset flat:DrvNextPtr
ENDIF
	mov	ax,1
loc_ex:
	pop	esi
	retn
loc_e:
	xor	ax,ax
	jmp	short loc_ex
_SetDrvEnv	endp

_PutMessage	proc	near
	mov	bx,sp
	xor	ax,ax
	mov	bx,ss:[bx+2]
	mov	cx,256
	mov	dx,bx
loc_1:
	cmp	al,[bx]
	jz	short loc_3
	inc	bx
	dec	cx
	jnz	short loc_1
loc_2:
	retn
loc_3:
	sub	bx,dx
	jz	short loc_2
	push	1	; file handle (STDOUT)
	push	bx	; message length
	push	ds
	push	dx	; message buffer
	call	Dos16PutMessage
	retn
_PutMessage	endp

_TEXT	ends
end
