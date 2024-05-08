AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/pianificatore

bin/pianificatore: obj/main.o
	ld $(LD_FLAGS) obj/main.o -o bin/pianificatore

obj/main.o: src/main.s 
	as $(AS_FLAGS) $(DEBUG) src/main.s -o obj/main.o

clean:
	rm -f obj/*.o bin/pianificatore
