; ==================================================================================================================================
; ----------------------------------------------------------------------------------------------------------------------------------
; Ikki FDS Port Disk Layout
; ----------------------------------------------------------------------------------------------------------------------------------
; Definitions
.enum
	INES_HDR = $10 ; size of iNES header
	PRG_SIZE = $4000
	DiskInfoBlock     = 1
	FileAmountBlock   = 2
	FileHeaderBlock   = 3
	FileDataBlock     = 4
	PRG = 0
	CHR = 1
	VRAM = 2
	FILE_COUNT = 3
.endenum

.define FILE "Ikki (Japan).nes"

; ----------------------------------------------------------------------------------------------------------------------------------
; Prepare original dump for patching (see bypass.asm)
	.segment "ORIGINAL"
	.incbin FILE, INES_HDR, PRG_SIZE

; Disk Structure
	.segment "SIDE1A"

; ----------------------------------------------------------------------------------------------------------------------------------
; Disk info + file amount blocks
	.byte DiskInfoBlock
	.byte "*NINTENDO-HVC*"
	.byte 0												; manufacturer
	.byte "RIK "										; game title + space for normal disk
	.byte 0, 0, 0, 0, 0									; game version, side, disk, disk type, unknown
	.byte FILE_COUNT									; boot file count
	.byte $ff, $ff, $ff, $ff, $ff
	.byte $60, $11, $28									; cart release date according to nescartdb (1985/11/28)
	.byte $49, $61, 0, 0, 2, 0, 0, 0, 0, 0				; region stuff
	.byte $99, $11, $09									; use disk write date as date of port release for now
	.byte 0, $80, 0, 0, 7, 0, 0, 0, 0					; unknown data, disk writer serial no., actual disk side, price

	.byte FileAmountBlock
	.byte FILE_COUNT + 1 + 1 ; lie about the file amount so the BIOS keeps seeking

; ----------------------------------------------------------------------------------------------------------------------------------
; PRG
	.segment "FILE0_HDR"
	.import __FILE0_DAT_RUN__
	.import __FILE0_DAT_SIZE__
	.byte FileHeaderBlock
	.byte $00, $00
	.byte "IKKIPRGM"
	.word __FILE0_DAT_RUN__
	.word __FILE0_DAT_SIZE__
	.byte PRG
	
	.byte FileDataBlock
	.segment "FILE0_DAT"
	.incbin "prg.bin"
	
; Entry Point + Interrupt Vectors
	.segment "FILE1_HDR"
	.import __FILE1_DAT_RUN__
	.import __FILE1_DAT_SIZE__
	.byte FileHeaderBlock
	.byte $01, $01
	.byte "IKKIVECS"
	.word __FILE1_DAT_RUN__
	.word __FILE1_DAT_SIZE__
	.byte PRG
	
	.byte FileDataBlock
	.include "bypass.asm"

; ----------------------------------------------------------------------------------------------------------------------------------
; CHR
	.segment "FILE2_HDR"
	.import __FILE2_DAT_RUN__
	.import __FILE2_DAT_SIZE__
	.byte FileHeaderBlock
	.byte $02, $02
	.byte "IKKICHAR"
	.word __FILE2_DAT_RUN__
	.word __FILE2_DAT_SIZE__
	.byte CHR
	
	.byte FileDataBlock
	.segment "FILE2_DAT"
	.incbin FILE, INES_HDR + PRG_SIZE, $2000

; ----------------------------------------------------------------------------------------------------------------------------------
; kyodaku bypass file
	.segment "FILE3_HDR"
	.import __FILE3_DAT_RUN__
	.import __FILE3_DAT_SIZE__
	.byte FileHeaderBlock
	.byte $03, $03
	.byte "-BYPASS-"
	.word __FILE3_DAT_RUN__
	.word __FILE3_DAT_SIZE__
	.byte PRG

	.byte FileDataBlock
	.segment "FILE3_DAT"
	.byte $90 ; enable NMI byte loaded into PPU control register - bypasses "KYODAKU-" file check

