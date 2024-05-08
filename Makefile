AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/pianificatore

bin/pianificatore: obj/main.o obj/menu.o obj/edf.o obj/hpf.o obj/printStr.o
	ld $(LD_FLAGS) obj/main.o obj/menu.o obj/edf.o obj/hpf.o obj/printStr.o -o bin/pianificatore

obj/main.o: src/main.s 
	as $(AS_FLAGS) $(DEBUG) src/main.s -o obj/main.o

obj/menu.o: src/menu.s 
	as $(AS_FLAGS) $(DEBUG) src/menu.s -o obj/menu.o

obj/edf.o: src/edf.s 
	as $(AS_FLAGS) $(DEBUG) src/edf.s -o obj/edf.o

obj/hpf.o: src/hpf.s 
	as $(AS_FLAGS) $(DEBUG) src/hpf.s -o obj/hpf.o

obj/printStr.o: src/printStr.s 
	as $(AS_FLAGS) $(DEBUG) src/printStr.s -o obj/printStr.o

clean:
	rm -f obj/*.o bin/pianificatore
