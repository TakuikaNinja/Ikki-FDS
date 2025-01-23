PPUCTRL = $2000
NMI_1 = $dff6
NMI_2 = $dff8
NMI_3 = $dffa
RST_FLAG = $0102
RST_TYPE = $0103
FDS_RESET = $fffc
Ptr = $76 ; $76~$77 are always cleared on reset, so clobbering it won't matter
FDS_CTRL_MIRROR = $fa
FDS_CTRL = $4025

; "NMI" routine which is entered to bypass the BIOS check
Bypass:
		lda #$00										; disable NMIs since we don't need them anymore
		sta PPUCTRL
		
		lda Vectors										; put real NMI handler in NMI vector 3
		sta NMI_3
		lda Vectors+1
		sta NMI_3+1
		
		lda #$35										; tell the FDS that the BIOS "did its job"
		sta RST_FLAG
		lda #$ac
		sta RST_TYPE
		
		jsr FixPointers
		jmp (FDS_RESET)									; jump to reset FDS

; This game uses data in the $0100~$012f region of memory, 
; which conflicts with FDS BIOS variables at $0100~$0103.
; Add $10 to the low byte of each pointer value so they use $0110~$013f instead.
FixPointers:
		lda #$00
		tay
		ldx #(Pointers_Hi - Pointers_Lo - 1)
-
		lda Pointers_Lo,x
		sta Ptr
		lda Pointers_Hi,x
		sta Ptr+1
		lda (Ptr),y
		clc
		adc #$10
		sta (Ptr),y
		dex
		bpl -
		rts

Pointers_Lo:
	.dl $824e, $827f, $8565, $8859, $885f, $a14e, $a214, $a228, $a22e, $a233, $a5cc

Pointers_Hi:
	.dh $824e, $827f, $8565, $8859, $885f, $a14e, $a214, $a228, $a22e, $a233, $a5cc

; New reset handler which sets vertical mirroring (horrizontal arrangement)
Reset:
		lda FDS_CTRL_MIRROR								; get setting previously used by FDS BIOS
		and #$f7										; and set for vertical mirroring
		sta FDS_CTRL
	.db $4c ; JMP Absolute
	.incbin FILE, INES_HDR + prg_length - 4, 2 ; jump to original reset handler

.org NMI_1
Vectors:
	.incbin FILE, INES_HDR + prg_length - 6, 2 ; NMI #1
	.incbin FILE, INES_HDR + prg_length - 6, 2 ; NMI #2
	.dw Bypass ; NMI #3, entry point
	.dw Reset ; reset
	.incbin FILE, INES_HDR + prg_length - 2, 2 ; IRQ (unused?)

