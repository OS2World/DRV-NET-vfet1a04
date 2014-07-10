; *** Media Independent Interface definition
;      from National Semiconductor DP83861 specification

miiBMCR		equ	0	; Basic Mode Control
miiBMSR		equ	1	; Basic Mode Status
miiPHYID1	equ	2	; PHY Identifier #1
miiPHYID2	equ	3	; PHY Identifier #2
miiANAR		equ	4	; Auto Negotiation Advertisement
miiANLPAR	equ	5	; Auto Nego. Link Pertner Ability
miiANER		equ	6	; Auto Nego. Expansion
miiANNPTR	equ	7	; Auto Nego. Next page Tx
miiANNPRR	equ	8	; Auto Nego. Next page Rx
mii1KTCR	equ	9	; 1000BASE-T control
mii1KSTSR	equ	10	; 1000BASE-T status
mii1KSCR	equ	15	; 1000BASE-T extended status


miiBMCR_Reset		equ	8000h
miiBMCR_Loopback	equ	4000h
miiBMCR_Speed0		equ	2000h
miiBMCR_ANEnable	equ	1000h
miiBMCR_Powerdown	equ	 800h
miiBMCR_Isolate		equ	 400h
miiBMCR_RestartAN	equ	 200h
miiBMCR_Duplex		equ	 100h
miiBMCR_ColTest		equ	  80h
miiBMCR_Speed1		equ	  40h

miiBMSR_T4		equ	8000h	; 100BASE-T4
miiBMSR_100FD		equ	4000h	; 100BASE-TX Full Duplex
miiBMSR_100HD		equ	2000h	; 100BASE-TX Half Duplex
miiBMSR_10FD		equ	1000h	; 10BASE-T Full Duplex
miiBMSR_10HD		equ	 800h	; 10BASE-T Half Duplex
miiBMSR_T2FD		equ	 400h	; 100BASE-T2 Full Duplex
miiBMSR_T2HD		equ	 200h	; 100BASE-T2 Half Duplex
miiBMSR_ExtStat		equ	 100h	; 1000BASE-T Extended Status
miiBMSR_PS		equ	  40h	; Preamble Suppression
miiBMSR_ANComp		equ	  20h	; AutoNegotiation Complete
miiBMSR_RF		equ	  10h	; Remote Fault
miiBMSR_ANCap		equ	   8h	; AutoNegotiation Ability
miiBMSR_LinkStat	equ	   4h	; Link Status since last read
miiBMSR_Jabber		equ	   2h	; Jabber Detect
miiBMSR_ExtCap		equ	   1h	; Extended Capability

miiAN_NP		equ	8000h	; Next Page Indication
miiAN_ACK		equ	4000h	; Acknowledge
miiAN_RF		equ	2000h	; Remote Fault
miiAN_ASYPAUSE		equ	 800h	; Asymmetrical PAUSE
miiAN_PAUSE		equ	 400h	; PAUSE
miiAN_T4		equ	 200h	; 100BASE-T4
miiAN_100FD		equ	 100h	; 100BASE-TX Full Duplex
miiAN_100HD		equ	  80h	; 100BASE-TX Half Duplex
miiAN_10FD		equ	  40h	; 10BASE-T Full Duplex
miiAN_10HD		equ	  20h	; 10BASE-T Half Duplex

miiANEP_PDF		equ	  10h	; Parallel detection fault
miiANEP_LPNPA		equ	   8h	; Link Partner Next page support
miiANEP_NPA		equ	   4h	; local device Next page support
miiANEP_PageRx		equ	   2h	; Link Code Word Page received
miiANEP_LPANA		equ	   1h	; Link Partner AntoNego. support

miiANNP_NP		equ	8000h	; Next page desired
miiANNP_MP		equ	2000h	; Message/Unformatted page
miiANNP_ACK2		equ	1000h	; Acknowledge2
miiANNP_TOG		equ	 800h	; Toggle
miiANNP_CODE		equ	 7ffh	; Code (mask)


mii1KSCR_1KXFD		equ	8000h	; 1000BASE-X Full Duplex
mii1KSCR_1KXHD		equ	4000h	; 1000BASE-X Half Duplex
mii1KSCR_1KTFD		equ	2000h	; 1000BASE-T Full Duplex
mii1KSCR_1KTHD		equ	1000h	; 1000BASE-T Half Duplex

mii1KSTSR_MMSFault	equ	8000h	; manual Master/Slave fault
mii1KSTSR_MSCR		equ	4000h	; Master/Slave configuration Result
mii1KSTSR_LRS		equ	2000h	; Local Receiver status
mii1KSTSR_RRS		equ	1000h	; Remote Receiver Status
mii1KSTSR_LP1KFD	equ	 800h	; LinkPartner 1000BASE-T Full
mii1KSTSR_LP1KHD	equ	 400h	; LinkPartner 1000BASE-T Half
mii1KSTSR_LPASYM	equ	 200h	; LinkPartner Asym PAUSE cap.

mii1KTCR_Test		equ	0e000h	; test mode (mask)
mii1KTCR_MSE		equ	1000h	; manual Master/Slave enable
mii1KTCR_MSA		equ	 800h	; manual Master/Slave advertise
mii1KTCR_Port		equ	 400h	; Port Type. Repeater/Switch(1) or DTE(0)
mii1KTCR_1KTFD		equ	 200h	; 1000BASE-T Full Duplex capable
mii1KTCR_1KTHD		equ	 100h	; 1000BASE-T Half Fuplex capable
