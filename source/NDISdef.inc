; ***** NDIS 2.01 Definition *****



; *** Module Function Flags ***
_cctmff		record \
		cctmffres:29 = 0,
		DynamicBind:1,
		LowerBind:1,
		UpperBind:1

; *** common characteristics table ***
cct		struc
cctsize		dw	?	; table length
NDISMaj		db	?	; NDIS Major Version
NDISMin		db	?	; NDIS Minor Version
		dw	?	; reserve
ModuleMaj	db	?	; Module Major Version
ModuleMin	db	?	; Module Minor Version
cctmff		_cctmff <>	; Module Function Flags
cctname		db  16 dup (?)	; Module Name
upl		db	?	; Upper Level
upi		db	?	; Upper Interface
lol		db	?	; Lower Level
loi		db	?	; Lower Interface
moduleID	dw	?	; Module ID
moduleDS	dw	?	; Module DS
cctsrd		dd	?	; System Request Dispatch
cctssc		dd	?	; Service-Specific Characteristics
cctsss		dd	?	; Service-Specific Status
cctupd		dd	?	; Upper Dispatch
cctlod		dd	?	; Lower Dispatch
		dd	0,0	; Reserve. NULL
cct		ends


; *** MAC Service-Specific flags ***
_mctssf		record \
	ssfreserve:15 = 0,
	ssfLookAhead0:1,
	ssfMultipleTxData:1,
	ssfVirtAddr:1,
	ssfSrcBridge:1,
	ssfIntReq:1,
	ssfOpenClose:1,
	ssfResetMac:1,
	ssfIBMSrc:1,
	ssfRxType:1,
	ssfLoopback:1,
	ssfInitDiag:1,
	ssfStat:1,
	ssfSoftAddr:1,
	ssfPromiscuous:1,
	ssfGroup:1,
	ssfMulticast:1,
	ssfBroadcast:1

; *** MAC Service-Specific Characteristics Table ***
mct		struc
mctsize		dw	?
mcttype		db  16 dup (?)	; Type Name (DIX+802.3)
mctalen		dw	?	; station address length
mctpsa		db  16 dup (?)	; permanent station address
mctcsa		db  16 dup (?)	; current station address
mctcfa		dd	?	; current functional address
mcal		dd	?	; multicast address list
linkspeed	dd	?	; link speed
mctssf		_mctssf <>	; service flags
mfs		dw	?	; maximum frame size
ttbc		dd	?	; total tx buffer capacity
tbs		dw	?	; tx buffer block size
trbc		dd	?	; total rx buffer capacity
rbs		dw	?	; rx buffer block size
mctVendorCode	db 3 dup (?)	; IEEE vendor code
mctAdapterCode	db	?	; Vendor adapter code
mctAdapterDesc	dd	?	; Vendor adapter description
mctIRQ		dw	?	; Interrupt level
mcttqd		dw	?	; tx queue depth
mctmdb		dw	?	; maximun data block in descriptor
mct		ends

; *** multicast address list ***
multicastlist	struc
maxnum		dw	?	; max number
curnum		dw	?	; current number
multicastaddr1	db  16 dup(?)	; address 1
multicastlist	ends


; *** MAC Status ***
_MACstatus	record \
		msreserve:26 = 0,
		msdiag:1,
		msopen:1,
		msbound:1,
		msopcode:3

; *** Current Packet Filter ***
_RxFilter	record \
		fltreserve:12 = 0,
		fltsrcrt:1,
		fltprms:1,
		fltbroad:1,
		fltdirect:1

; *** MAC Service-Specific Status Table ***
mst		struc
mstsize		dw	?
ssttime		dd	?	; date/time. seconds from 1970/1/1
sstMACstatus	_MACstatus <>	; MAC status
sstRxFilter	_RxFilter <>	; current packet filter
sstmsst		dd	?	; media specific status table
sstclrtime	dd	?	; ClearStatistics time
rxframe		dd	?	; rx frames OK
rxframecrc	dd	?	; rx frames with CRC error
rxbyte		dd	?	; rx bytes 
rxframebuf	dd	?	; rx frames discarded(buffer)
rxframemulti	dd	?	; rx multicast frames
rxframebroad	dd	?	; rx broadcast frames
		dd  5 dup(-1)	; reserved
rxframehw	dd	?	; rx frames discarded(hardware)
txframe		dd	?	; tx frames OK
txbyte		dd	?	; tx bytes OK
txframemulti	dd	?	; tx multicast frames
txframebroad	dd	?	; tx broadcast frames
		dd  2 dup(-1)	; reserverd
txframeto	dd	?	; tx frames timeout
txframehw	dd	?	; tx frames hardware error
mst		ends


; *** MAC Upper Dispatch Table ***
updp		struc
updpbp		dd	?	; back pointer to common characteristics
request		dd	?	; Request
txchain		dd	?	; TransmitChain
rxdata		dd	?	; TransferData
rxrelease	dd	?	; ReceiveRelease
indon		dd	?	; IndicationON
indoff		dd	?	; IndicationOFF
updp		ends

; *** Protocol Lower Dispatch Table ***
lowdp		struc
lowdpbp		dd	?	; back pointer to common characteristics
lowifflg	dd	?	; interface flags
reqconfirm	dd	?	; RequestConfirm
txconfirm	dd	?	; TransmitConfirm
rxlookahead	dd	?	; ReceiveLookahead
indiccomplete	dd	?	; IndicationComplete
rxchain		dd	?	; ReceiveChain
stindic		dd	?	; StatusIndication
lowdp		ends


; *** Transmit Buffer Descriptor ***
TxBufDesc	struc
TxPtrType	db	?	; 0-Physical, 1-Virtual(GDT)
		db	?	; reserve
TxDataLen	dw	?	; data block length
TxDataPtr	dd	?	; data block address
TxBufDesc	ends

; *** Transmit Frame Descriptor ***
TxFrameDesc	struc
TxImmedLen	dw	?	; immediate data byte length(max:64)
TxImmedPtr	dd	?	; immediate data virtual address
TxDataCount	dw	?	; count of TxBufDesc
TxBufDesc1	TxBufDesc 8 dup (<>)
TxFrameDesc	ends


; *** ReceiveChain Buffer Descriptor ***
RxBufDesc	struc
RxDataLen	dw	?	; data block length
RxDataPtr	dd	?	; data block Virtual address
RxBufDesc	ends

; *** ReceiveChain Frame Descriptor ***
RxFrameDesc	struc
RxDataCount	dw	?	; count of RxBufDesc
RxBufDesc1	RxBufDesc 8 dup (<>)
RxFrameDesc	ends

; *** TransferData Buffer Descriptor ***
TDBufDesc	struc
TDPtrType	db	?	; 0-Physical, 2-GDT
		db	?	; reserved (0)
TDDataLen	dw	?	; data block length
TDDataPtr	dd	?	; data block address
TDBufDesc	ends

; *** TransferData Frame Descriptor ***
TDFrameDesc	struc
TDDataCount	dw	?	; count of TDBufDesc
TDBufDesc1	TDBufDesc 8 dup (<>)
TDFrameDesc	ends


; *** Configuration Memory Image ***
cmiParam	struc
ParamType	dw	?	; parameter type. 0:Numero 1:string
ParamLen	dw	?	; parameter length
Param		dd	?	; parameter
cmiParam	ends

KeywordEntry	struc
NextKeyword	dd	?	; next keyword entry pointer
PrevKeyword	dd	?	; previous keyword entry pointer
Keyword		db  16 dup (?)	; keyword
NumParams	dw	?	; count of parameters
cmiParam1	cmiParam <>	; parameters
KeywordEntry	ends

ModuleConfig	struc
NextModule	dd	?	; next module pointer
PrevModule	dd	?	; previous module pointer
ModuleName	db  16 dup (?)	; module name
Keyword1	KeywordEntry <>	; Keywords
ModuleConfig	ends


; *** Protocol Manager IOCtl ***
LanManCat	equ	81h	; Category
ProtManCode	equ	58h	; Function

GetProtManInfo	equ	1	; OpCode 1
RegisterModule	equ	2	; OpCode 2

ProtManLevel	equ	1	; Version Number

PMBlock		struc
PMCode		dw	?
PMStatus	dw	?
PMPtr1		dd	?
PMPtr2		dd	?
PMWord		dw	?
PMBlock		ends


; *** System Request ***
srParam		struc
		dw	?	; BP
		dw	?	; IP
		dw	?	; CS
TargetDS	dw	?	; DS of called module
Opcode		dw	?
Param3		dw	?
Param2		dd	?
Param1		dd	?
srParam		ends

srOpInitiateBind equ	1
srOpBind	equ	2
srOpInitiatePrebind equ	3
srOpInitiateUnbind equ	4
srOpUnbind	equ	5


; *** General Request ***
grParam		struc
		dw	?	; BP
		dw	?	; IP
		dw	?	; CS
MACDS		dw	?
Opcode		dw	?
Param2		dd	?
Param1		dw	?
ReqHandle	dw	?
ProtID		dw	?
grParam		ends

grOpInitDiag	equ	1	; InitiateDiagnostics
grOpReadErrLog	equ	2	; ReadErrorLog
grOpSetSTA	equ	3	; SetStationAddress
grOpOpen	equ	4	; OpenAdapter
grOpClose	equ	5	; CloseAdapter
grOpReset	equ	6	; ResetMAC
grOpSetPkFlt	equ	7	; SetPacketFilter
grOpAddMc	equ	8	; AddMulticastAddress
grOpDelMc	equ	9	; DeleteMulticastAddress
grOpUpStat	equ	10	; UpdateStatistics
grOpClrStat	equ	11	; ClearStatistics
grOpIntReq	equ	12	; InterruptRequest
grOpSetFunc	equ	13	; SetFunctionalAddress
grOpSetLooka	equ	14	; SetLookahead


; *** Status Indication ***
siOpRing	equ	1	; RingStatus
siOpCheck	equ	2	; AdapterCheck
siOpStartReset	equ	3	; StartReset
siOpEndReset	equ	5	; EndReset
siOpInterrupt	equ	4	; Interrupt


; *** Return Code ***
SUCCESS			equ	0
WAIT_FOR_RELEASE	equ	1
REQUEST_QUEUED		equ	2
OUT_OF_RESOURCE		equ	6
INVALID_PARAMETER	equ	7
INVALID_FUNCTION	equ	8
NOT_SUPPORTED		equ	9
HARDWARE_FAILURE	equ	24h
INTERRUPT_CONFLICT	equ	26h
GENERAL_FAILURE		equ	0FFh
