.enum
	PPU_CTRL = $2000
	PPU_STATUS = $2002
	NMI_3 = $dffa
	RST_FLAG = $0102
	RST_TYPE = $0103
	FDS_RESET = $fffc
	FDS_CTRL = $4025
.endenum

; "NMI" routine which is entered to bypass the BIOS check
.segment "FILE0_DAT"
Bypass:
		lda #$00										; disable NMIs since we don't need them anymore
		sta PPU_CTRL
		
		lda Vectors										; put real NMI handler in NMI vector 3
		sta NMI_3
		lda Vectors+1
		sta NMI_3+1
		
		lda #$35										; tell the FDS that the BIOS "did its job"
		sta RST_FLAG
		lda #$ac
		sta RST_TYPE
		
		jmp (FDS_RESET)									; jump to reset FDS

; This game uses data in the $0100~$012f region of memory, 
; which conflicts with FDS BIOS variables at $0100~$0103.
; Add $10 to the low byte of each pointer value so they use $0110~$013f instead.
.segment "POINTER_PATCH0"
	.byte $20
.segment "POINTER_PATCH1"
	.byte $2f
.segment "POINTER_PATCH2"
	.byte $20
.segment "POINTER_PATCH3"
	.byte $20
.segment "POINTER_PATCH4"
	.byte $20
.segment "POINTER_PATCH5"
	.byte $10
.segment "POINTER_PATCH6"
	.byte $13
.segment "POINTER_PATCH7"
	.byte $11
.segment "POINTER_PATCH8"
	.byte $12
.segment "POINTER_PATCH9"
	.byte $20
.segment "POINTER_PATCHA"
	.byte $20

; Patch reset handler to CLI and set horrizontal arrangement (vertical mirroring)
.segment "RESET_PATCH"
		cli
		lda #$00
		sta PPU_CTRL
:
		lda PPU_STATUS
		bpl :-
		lda #$26
		sta FDS_CTRL

.segment "FILE1_DAT"
Vectors:
	.incbin FILE, INES_HDR + PRG_SIZE - 6, 2 ; NMI #1
	.incbin FILE, INES_HDR + PRG_SIZE - 6, 2 ; NMI #2
	.addr Bypass ; NMI #3, entry point
	.incbin FILE, INES_HDR + PRG_SIZE - 4, 2 ; reset
	.incbin FILE, INES_HDR + PRG_SIZE - 2, 2 ; IRQ (unused?)

