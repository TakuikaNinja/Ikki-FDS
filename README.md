# Ikki FDS

https://github.com/TakuikaNinja/Ikki-FDS

NROM-128 games can often run on the Famicom Disk System with minimal modifications to its program code. This is substantiated by the fact that Yahoo Auctions has had listings for unofficial disk conversions of Ikki, BattleCity, and potentially some other NROM-128 games.

This project aims to port one such game, Ikki, to the FDS. The differences from the original game are as follows:
- Boots and runs on the FDS, bypassing the BIOS' license message check.
- Applies run-time patches to adjust variables that conflict with $0100~$0103 (FDS BIOS variables).
- Executes extra code to set the correct nametable mirroring/arrangement on reset.

It should be noted that the approach taken by this project likely differs from methods used by existing conversions, which may have involved some kind of cartridge-to-disk dumping hardware ("copiers") and a disk file editor (such as Tonkachi Editor).

## Building

The Makefile builds `ikki.fds` using ASM6f (https://github.com/freem/asm6f) plus the original game dump with an NES2.0 header. Said dump is not provided by this repo for obvious legal reasons. The dump used is the following: 

```
Database match: Ikki (Japan)
Database: No-Intro: Nintendo Entertainment System (v. 20210216-231042)
File SHA-1: 1995D5C0CD6AD3C34B70A4D0A3BB6685021EEECB
File CRC32: AC588BE3
ROM SHA-1: 83A3ACD2E1C51CAA7E1460963FACC1D96707F230
ROM CRC32: 821FEB7A
```

## Acknowledgements

Ikki (C) 1985 Sunsoft (Sun Electronics Corp.) This project is purely for demonstration and educational purposes.

- There is prior work from OffGao, who has a video showcasing a hacked version of Ikki running on the FDS: https://www.nicovideo.jp/watch/sm9020475
- Mesen (https://www.mesen.ca/) was used for its excellent debugging tools.
- Hardware testing was done using a Sharp Twin Famicom with the [FDSKey](https://github.com/ClusterM/fdskey).
