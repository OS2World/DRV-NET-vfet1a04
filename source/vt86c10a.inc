; *** VIA VT86C100A Rhine definition ***

; +++ register definition +++
Rhine_registers	struc
PAR		db	6 dup(?) ; 00 physical address
RxCR		db	?	; 06 receive control
TxCR		db	?	; 07 transmit control
GCR0		db	?	; 08 command 0 (global)
GCR1		db	?	; 09 command 1
		dw	?	; 0a
ISR		dw	?	; 0c interrupt status
IMR		dw	?	; 0e interrupt mask
MAR		dd	?,?	; 10 multicast hash table
CRDA		dd	?	; 18 receive descriptor base
CTDA		dd	?	; 1c transmit descriptor base
CRxDesc		dd	?,?,?,?	; 20 current receive descriptor
NRxDesc		dd	?,?,?,?	; 30 next receive descriptor
CTxDesc		dd	?,?,?,?	; 40 current transmit descriptor
NTxDesc		dd	?,?,?,?	; 50 next transmit descriptor
CRxDMA		dd	?	; 60 current receive DMA pointor
CTxDMA		dd	?	; 64 current transmit DMA pointor
TallyCntTest	dd	?	; 68 tally counter test


PHY_ADR		db	?	; 6c PHY address
MIISR		db	?	; 6d MII status
BCR0		db	?	; 6e bus control 0
BCR1		db	?	; 6f bus control 1
MIICR		db	?	; 70 mii control
MIIADR		db	?	; 71 mii port address
MII_DATA	dw	?	; 72 mii R/W data port
EECSR		db	?	; 74 eeprom control/status
TRST		db	?	; 75 test
GPIO		db	?	; 76 general purpose io
		db	?	; 77 
CFGA		db	?	; 78 chip configuration A
CFGB		db	?	; 79 chip configuration B
CFGC		db	?	; 7a chip configuration C
CFGD		db	?	; 7b chip configuration D
TallyCntMPA	dw	?	; 7c 
TallyCntCRC	dw	?	; 7d 
Rhine_registers	ends

; --- Receive configuration 06h ---
RRFT		equ	0e0h	; receive FIFO threshold (mask)
PROM		equ	 10h	; all unicast accept
AB		equ	  8	; broadcast accept
AM		equ	  4	; multicast hash hit accept
AR		equ	  2	; runt packet accept
SEP		equ	  1	; CRC errored packet accept

RRFT_64		equ	(000b shl 5)
RRFT_32		equ	(001b shl 5)
RRFT_128	equ	(010b shl 5)
RRFT_256	equ	(011b shl 5)
RRFT_512	equ	(100b shl 5)
RRFT_768	equ	(101b shl 5)
RRFT_1024	equ	(110b shl 5)
RRFT_SF		equ	(111b shl 5)


; --- Transmit configuration 07h ---
RTSF		equ	0e0h	; transmit FIFO threshold (mask)
OFSET		equ	  8	: back-off priority select
LB		equ	  6	; loopback mode (mask)

RTSF_64		equ	(000b shl 5)
RTSF_32		equ	(001b shl 5)
RTSF_128	equ	(010b shl 5)
RTSF_256	equ	(011b shl 5)
RTSF_512	equ	(100b shl 5)
RTSF_768	equ	(101b shl 5)
RTSF_1024	equ	(110b shl 5)
RTSF_SF		equ	(111b shl 5)


; --- control 0  08h ---
ISTRT		equ	80h	; initialize start (initiate reset?)
RxDMD		equ	40h	; receive poll demand (self clear?)
TxDMD		equ	20h	; transmit poll demand (self clear?)
TxON		equ	10h	; transmit enable
RxON		equ	 8	; receive enable
STOP		equ	 4	; stop NIC
STRT		equ	 2	; start NIC

; --- control 1  09h ---
SysErr		equ	80h	; System or Rx Buffer Error state(clear STRT)
DPOLL		equ	 8	; disable transmit auto polling
FDX		equ	 4	; full duplex mode
ETEN		equ	 2	; enable early transmit mode
EREN		equ	 1	; enable early recieve mode

; --- interrupt status/mask  0ch/0eh ---
RxMagic		equ	8000h	; magic key packet received
SRCI		equ	4000h	; port state change
ABTI		equ	2000h	; excessive collision tx abort
NORBF		equ	1000h	; RD running up
PKTRace		equ	 800h	; receive FIFO queue list overflow
OVFI		equ	 400h	; receive FIFO overflow
UDFI		equ	 200h	; transmit FIFO underflow
ERI		equ	 100h	; early receive
CNT		equ	  80h	; CRC or miss packet counter overflow
BE		equ	  40h	; PCI bus error
RU		equ	  20h	; receive buffer link error
TU		equ	  10h	; transmit buffer underflow
TXE		equ	   8	; transmit error
RXE		equ	   4	; receive error
PTX		equ	   2	; transmit success
PRX		equ	   1	; receive success

I_RX		equ	PRX or RXE or RU or OVFI or PKTRace or NORBF
I_TX		equ	PTX or TXE or TU or UDFI or ABTI

; --- MII configuration  6ch ---
MPO		equ	0e0h	; MII management polling timer interval(mask)
PHYAD		equ	 1fh	; PHY device address(mask)

; --- MII status  6dh ---
GPIO1Pol	equ	80h	; GPIO1 output polarity
MFDC		equ	20h	; fast MDC autopolling x4
PHYOPT		equ	10h	; fixed PHY address
MIIERR		equ	 8	; MRXERR asserted (wc)
MIIPortErr	equ	 4	; MII management port read error (wc)
LNKFL		equ	 2	; link fail
SPD10		equ	 1	; network speed 10M

; no explanation in the datasheet... refer to the VT6102 datasheet
; --- bus control 0  6eh ---
;MED2		equ	80h	; medium select control
EXTLED		equ	40h	; extra LED support control
CRFT		equ	38h	; control rx FIFO threshold? 000:enable RxCR
DMALen		equ	 7	; DMA length (mask)

DMALen_32	equ	000b
DMALen_64	equ	001b
DMALen_128	equ	010b
DMALen_256	equ	011b
DMALen_512	equ	100b
DMALen_1024	equ	101b
DMALen_SF	equ	110b


; --- bus control 1  6fh ---
CTFT		equ	38h	; control tx FIFO threshold? 000:enable TxCR
POT		equ	 7	; Polling Time Interval (mask)

; --- MII control  70h ---
MAUTO		equ	80h	; MII management port auto polling enable
RCMD		equ	40h	; PHY read enable (self clear)
WCMD		equ	20h	; PHY write enable (self clear)
MDPM		equ	10h	; direct programming mode
MOUT		equ	 8	; MDIO output enable indicator
MDO		equ	 4	; data out
MDI		equ	 2	; data in
MDC		equ	 1	; clock

; --- management interface address  71h ---
;MIDLE		equ	80h	; MII idle (read only)
MSRCEN		equ	40h	; MII status change enable
MDONE		equ	20h	; pause status/control
MAD		equ	1fh	; MII port address (mask)

; --- EEPROM control/status 74h ---
EEPR		equ	80h	; EEPROM programmed status(read only)
EMBP		equ	40h	; EEPROM embedded program enable
AUTOLD		equ	20h	; dynamic reload EEPROM content
EDPM		equ	10h	; direct program mode
ECS		equ	 8	; chip select
ECK		equ	 4	; clock
EDIN		equ	 2	; data in
EDO		equ	 1	; data out (read only)

; --- chip configuration A  78h ---
EELOAD		equ	80h	; EEPROM embedded and direct programming
MIIOPT		equ	40h	; MII option
MMIOE		equ	20h	; memory mapped I/O enable (undocument)

; --- chip configuration B  79h ---
QPKTDIS		equ	80h	; transmit frame queuing disable
TXPACE		equ	40h	; transmit descriptor pacing algorithm
MRMEN		equ	20h	; memory read multiple enable
TxARBIT		equ	10h	; Tx DMA interleave to Rx DMA
RxARBIT		equ	 8	; Rx DMA interleave to Tx DMA
MWWAIT		equ	 4	; write insert one wait
MRWAIT		equ	 2	; read insert one wait
LATMEN		equ	 1	; latency timer

; --- chip configuration D 7bh ---
GPIO2EN		equ	80h	l GPIO2 input status change monitor
DIAG		equ	40h	; diagnostic mode
MRLEN		equ	20h	; memory read line capable
MAGICKEY	equ	10h	; magic key enable
CRADOM		equ	 8	; random backoff algorithm
CAP		equ	 6	; capture effect solution -2 for DEC
MBA		equ	 4	; capture effect solution -1 for AMD
BAKOPT		equ	 1	; backoff algorithm optional



; +++ transmit / receive descriptor definition +++
; --- transmit descriptor ---
TD	struc
sts		dd	?	; status
ctl		dd	?	; control
buf		dd	?	; buffer address
lnk		dd	?	; next link address
	; --- above for hardware, below for driver
vbuf		dd	?	; virtual address of buffer
phys		dd	?	; physical address of this descriptor
reqhandle	dw	?	; request handle
protid		dw	?	; protocol id
len		dw	?	; frame length
vlnk		dw	?	; logical link
TD	ends

; --- receive descriptor ---
RD	struc
sts		dd	?	; status
ctl		dd	?	; control
buf		dd	?	; buffer address
lnk		dd	?	; next link address
	; --- above for hardware, below for driver
vbuf		dd	?	; virtual addresse of buffer
phys		dd	?	; physical addresse of this descriptor
		dw	?	; reserve
vlnk		dw	?	; logical link
RD	ends

; --- transmit status bits ---
OWN		equ	80000000h	; owner
TERR		equ	    8000h	; transmit error
JAB		equ	    4000h	; jabber
SERR		equ	    2000h	; system error
CRS		equ	     400h	; carrier sense lost detect
OWC		equ	     200h	; out of window collision
ABT		equ	     100h	; excessive collision
CDH		equ	      80h	; CD heart beat check failure
NCR		equ	      78h	; collision retry count
UDF		equ	       2	; FIFO underflow
DFR		equ	       1	; deferred

; --- transmit control bits ---
IC		equ	800000h	; interrupt control
TxEDP		equ	400000h	; packet end    10:end  00:invalid
TxSTP		equ	200000h	; packet start  11:single 01:more
CRC		equ	 10000h	; disable CRC generation
BufCHN		equ	  8000h	; chain structure  1:chain 0:ring

; --- receive status bits ---
;OWN		equ	80000000h
RxLen		equ	7fff0000h	; receive length
RXOK		equ	    8000h	; no receive errors
MAR		equ	    2000h	; multicast
BAR		equ	    1000h	; broadcast
PHY		equ	     800h	; physical match
RxCHN		equ	     400h	; chain, always 1
RxSTP		equ	     200h	; packet start  11:single
RxEDP		equ	     100h	; paclet end  10:more  01:end
BUFE		equ	      80h	; link structure error
RxSERR		equ	      40h	; system error
RxRUNT		equ	      20h	; runt
LONG		equ	      10h	; length > 1518bytes
FOV		equ	       8	; FIFO Overflow
FAE		equ	       4	; frame align error
CRCE		equ	       2	; CRC error
RERR		equ	       1	; receive errors


