; *** Resident part definition

extern	DrvNextPtr: dword	; next driver link in header
extern	DrvName : byte		; Driver name
extern	SysSel : word		; Global Infomation segment
extern	DevHelp : dword		; Device Help Entry
extern	CtxHandle : dword	; Contex Hook handle
extern	CommonChar : cct	; Common Characteristics table
extern	MacChar : mct		; MAC Specific Characteristics table
extern	MacStatus : mst		; MAC Specific Status table
extern	UpDisp : updp		; Upper Dispatch table (call from proto.)
extern	MCSTList : multicastlist ; Multicast list table
extern	LowDisp : lowdp		; Lower Dispatch table (call to proto.)
extern	ProtDS : word		; Protocol DS
extern	drvflags : word		; Driver flags
extern	Indication : word	; Indication
extern	semInt : byte		; semaphore:Interrupt service
extern	semTx : byte		; semaphore:Transmit Function / Queue
extern	semRx : byte		; semaphore:Receive Function / Queue
extern	semFlt : byte		; semaphore:Packet filter, Multicast table
extern	semMii : byte		; semaphore:Media Independent Interface
extern	semStat : byte		; semaphore:Statistics
extern	semInd : byte		; semaphore:Indication

extern	_IndicationON : near16	
extern	_IndicationChkOFF : near16 ; check and turn off if on.
extern	CtxEntry : far16	; Context Hook handler
extern	_EnterCrit : near16	; Enter Critical section
extern	_LeaveCrit : near16	; Leave Critical section
extern	_VirtToPhys : near16	; DevHlp_VirtToPhys call
extern	_PhysToGDT : near16	; DevHlp_PhysToGDTSelector
extern	_Delay1ms : near16	; DevHlp_ProcBlock 1ms
