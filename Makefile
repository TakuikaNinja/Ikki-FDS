GAME=ikki
FORMAT=fds
OUTPUT=$(GAME).$(FORMAT)
ASSEMBLER=ca65
LINKER=ld65

OBJ_FILES=$(GAME).o

all: $(OUTPUT)

$(OUTPUT): $(OBJ_FILES) $(GAME).cfg
	$(LINKER) -o $(GAME).fds -C $(GAME).cfg $(OBJ_FILES) -m $(GAME).map.txt -Ln $(GAME).labels.txt --dbgfile $(GAME).dbg

$(OBJ_FILES): $(GAME).asm bypass.asm

%.o:%.asm
	$(ASSEMBLER) $< -g -o $@

.PHONY: clean

clean:
	rm -f *.lst $(OUTPUT) *.bin *.nl *.mlb *.cdl *.o *.dbg *.nl *.map.txt *.labels.txt

