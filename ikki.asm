; ==================================================================================================================================
; ----------------------------------------------------------------------------------------------------------------------------------
; Ikki FDS Port Disk Layout
; ----------------------------------------------------------------------------------------------------------------------------------
; Disk Structure
	.org $0000
	INES_HDR = $10 ; size of iNES header
	FILE equ "Ikki (Japan).nes"
	
; ----------------------------------------------------------------------------------------------------------------------------------
; Disk definitions taken from SMB2J's disassembly
	DiskInfoBlock     = 1
	FileAmountBlock   = 2
	FileHeaderBlock   = 3
	FileDataBlock     = 4
	PRG = 0
	CHR = 1
	VRAM = 2
	FILE_COUNT = 5

; ----------------------------------------------------------------------------------------------------------------------------------
; Disk info + file amount blocks
	.db DiskInfoBlock
	.db "*NINTENDO-HVC*"
	.db 0												; manufacturer
	.db "RIK "											; game title + space for normal disk
	.db 0, 0, 0, 0, 0									; game version, side, disk, disk type, unknown
	.db FILE_COUNT										; boot file count
	.db $ff, $ff, $ff, $ff, $ff
	.db $60, $11, $28									; cart release date according to nescartdb (1985/11/28)
	.db $49, $61, 0, 0, 2, 0, 0, 0, 0, 0				; region stuff
	.db $99, $11, $09									; use disk write date as date of port release for now
	.db 0, $80, 0, 0, 7, 0, 0, 0, 0						; unknown data, disk writer serial no., actual disk side, price

	.db FileAmountBlock
	.db FILE_COUNT

; ----------------------------------------------------------------------------------------------------------------------------------
; PRG
	.db FileHeaderBlock
	.db $00, $00
	.db "IKKIPRGM"
	.dw $8000
	.dw prg_length
	.db PRG
	
	.db FileDataBlock
	prg_length = $4000 ; 16KiB
	.incbin FILE, INES_HDR, prg_length
	
; Entry Point + Interrupt Vectors
	.db FileHeaderBlock
	.db $01, $01
	.db "IKKIVECS"
	.dw vec
	.dw vec_length
	.db PRG
	
	.db FileDataBlock
	old_addr = $
	.base $df80
	vec:
		.include "bypass.asm"
	vec_length = $ - vec
	.base old_addr + vec_length

; ----------------------------------------------------------------------------------------------------------------------------------
; CHR
	.db FileHeaderBlock
	.db $02, $02
	.db "IKKICHAR"
	.dw $0000
	.dw chr_length
	.db CHR
	
	.db FileDataBlock
	chr_length = $2000 ; 8KiB
	.incbin FILE, INES_HDR + prg_length, chr_length

; ----------------------------------------------------------------------------------------------------------------------------------
; kyodaku file
	.db FileHeaderBlock
	.db $03, $03
	.db "-BYPASS-"
	.dw $2000
	.dw $0001
	.db PRG

	.db FileDataBlock
	.db $90 ; enable NMI byte loaded into PPU control register - bypasses "KYODAKU-" file check
	
; this file will never be loaded but it's big enough for an NMI to kick in while seeking the disk
	.db FileHeaderBlock
	.db $04, $FF
	.db "-BYPASS-"
	.dw $0000
	.dw $0400
	.db PRG

	.db FileDataBlock
	.dsb $0400
	
	.pad 65500

