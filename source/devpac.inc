CMDInit		equ	0
CMDOpen		equ	0dh
CMDClose	equ	0eh
CMDGenIOCTL	equ	10h

_RPH		struc
Len		db	?
Unit		db	?
Cmd		db	?
Status		dw	?
Flag		db	?
reserve		db	3 dup(?)
Link		dd	?
_RPH		ends

_RPINIT		struc
RPH		_RPH<>
Unit		db	?
DevHlpEP	dd	?
InitArgs	dd	?
DriveNum	db	?
_RPINIT		ends

_RPINITOUT	struc
RPH		_RPH<>
Unit		db	?
CodeEnd		dw	?
DataEnd		dw	?
BPBArray	dw	?
Status		dw	?
_RPINITOUT	ends

_RP_GENIOCTL2	struc
RPH		_RPH<>
Category	db	?
Function	db	?
ParmPacket	dd	?
DataPacket	dd	?
sfn		dw	?
ParmLen		dw	?
DataLen		dw	?
_RP_GENIOCTL2	ends


DevHlp_ProcBlock	equ	 4h
DevHlp_ProcRun		equ	 5h
DevHlp_VirtToPhys	equ	16h
DevHlp_SetIRQ		equ	1Bh
DevHlp_UnSetIRQ		equ	1Ch
DevHlp_SetTimer		equ	1Dh
DevHlp_ResetTimer	equ	1Eh
DevHlp_GetDOSVar	equ	24h
DHGETDOSV_SYSINFOSEG	equ	1
DevHlp_AllocGDTSelector	equ	2Dh
DevHlp_PhysToGDTSelector equ	2Eh
DevHlp_EOI		equ	31h
DevHlp_TickCount	equ	33h
DevHlp_FreeGDTSelector	equ	53h
DevHlp_PhysToGDTSel	equ	54h
DevHlp_VMAlloc		equ	57h
VMDHA_FIXED		equ	2
VMDHA_CONTIG		equ	8
VMDHA_USEHIGHMEM	equ	(1 shl 11)
DevHlp_VMFree		equ	58h
DevHlp_VirtToLin	equ	5Bh
DevHlp_LinToGDTSelector	equ	5Ch
DevHlp_AllocateCtxHook	equ	63h
DevHlp_FreeCtxHook	equ	64h
DevHlp_ArmCtxHook	equ	65h
