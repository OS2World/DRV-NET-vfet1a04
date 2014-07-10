; *** Hardware dependent resident part definition

; --- DMA Descriptor management ---
extern	TxHead : word
extern	TxFreeHead : word

extern	RxInProg : word
extern	RxHead : word
extern	RxTail : word
extern	RxBusyHead : word
extern	RxBusyTail : word

; --- System(PCI) Resource ---
extern	IOaddr : word
extern	MEMSel : word		; selector for MEMaddr
extern	MEMaddr : dword
extern	IRQlevel : byte
extern	CacheLine : byte
extern	Latency : byte
extern	ChipRev : byte

; --- Configuration Memory Image Parameters ---
extern	cfgSLOT : byte
extern	cfgTXQUEUE : byte
extern	cfgRXQUEUE : byte
extern	cfgMAXFRAMESIZE : word
extern	cfgTxDRTH : byte
extern	cfgRxDRTH : byte

extern	cfgBCR0 : byte
extern	cfgBCR1 : byte
extern	cfgCFGB : byte
extern	cfgCFGD : byte
extern	cfgDAPOLL : byte

; --- Buffer Address ---
extern	BufferLin : dword
extern	BufferPhys : dword
extern	BufferSize : dword
extern	BufferSelCnt : word
extern	TxCopySel : word
extern	BufferSel : word


; ---Vendor Adapter Description ---
extern	AdapterDesc : byte


; --- Hardware Depended Services ---
extern	_hwTxChain : near16
extern	_hwRxRelease : near16
extern	_hwEnableRxInd : near16
extern	_hwDisableRxInd : near16
extern	_hwSetMACaddr : near16
extern	_hwOpen : near16
extern	_hwClose : near16
extern	_hwIntReq : near16
extern	_hwUpdatePktFlt : near16
extern	_hwUpdateMulticast : near16
extern	_hwUpdateStat : near16
extern	_hwClearStat : near16
extern	_hwReset : near16

extern	_hwCheckInt : near16
extern	_hwDisableInt : near16
extern	_hwEnableInt : near16
extern	_hwServiceInt : near16
extern	_hwPollLink : near16


; --- Driver Version ---
extern	DrvMajVer : abs
extern	DrvMinVer : abs

