; for OEMHelp IOCtl - PCI

; Category
IOCTL_OEMHLP	equ	80h
; Function
OEMHLP_PCI	equ	0Bh

; Return Code
; 00h Success
; 81h Function Not Supported
; 83h Bad Vendor ID
; 86h Device Not Found
; 87h Bad Register Number

; Subfunction
PCI_QueryBIOS		equ	00h
PCI_FindDevice		equ	01h
PCI_FindClass		equ	02h
PCI_ReadConfigSpace	equ	03h
PCI_WriteConfigSpace	equ	04h


; PCI_QueryBIOS
P_PCI_QueryBIOS		struc
Subfunction		db	?	; 00h
P_PCI_QueryBIOS		ends

D_PCI_QueryBIOS		struc
rc			db	?
HardwareMechanism	db	?
MajorVersion		db	?
MinorVersion		db	?
LastBus			db	?
D_PCI_QueryBIOS		ends

; PCI_FindDevice
P_PCI_FindDevice	struc
Subfunction		db	?	; 01h
DeviceID		dw	?
VendorID		dw	?
Index			db	?
P_PCI_FindDevice	ends

D_PCI_FindDevice	struc
rc			db	?
Bus			db	?
DevFunc			db	?
D_PCI_FindDevice	ends

; PCI_FindClass
P_PCI_FindClass		struc
Subfunction		db	?	; 02h
ClassCode		dd	?
Index			db	?
P_PCI_FindClass		ends

D_PCI_FindClass		struc
rc			db	?
Bus			db	?
DevFunc			db	?
D_PCI_FindClass		ends

; PCI_ReadConfigSpace
P_PCI_ReadConfigSpace	struc
Subfunction		db	?	; 03h
Bus			db	?
DevFunc			db	?
ConfigRegister		db	?
RegSize			db	?	; 01:byte 02:word 04:dword
P_PCI_ReadConfigSpace	ends

D_PCI_ReadConfigSpace	struc
rc			db	?
Data			dd	?
D_PCI_ReadConfigSpace	ends

; PCI_WriteConfigSpace
P_PCI_WriteConfigSpace	struc
Subfunction		db	?	; 04h
Bus			db	?
DevFunc			db	?
ConfigRegister		db	?
RegSize			db	?
Data			dd	?
P_PCI_WriteConfigSpace	ends

D_PCI_WriteConfigSpace	struc
rc			db	?
D_PCI_WriteConfigSpace	ends


