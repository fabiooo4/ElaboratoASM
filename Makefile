AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/pianificatore

bin/pianificatore: obj/main.o obj/menu.o obj/plan.o obj/printStr.o obj/atoi.o obj/printInt.o obj/bubbleSort.o obj/swapOrders.o obj/output.o obj/writeStrFile.o obj/writeIntFile.o
	ld $(LD_FLAGS) obj/main.o obj/menu.o obj/plan.o obj/printStr.o obj/atoi.o obj/printInt.o obj/bubbleSort.o obj/swapOrders.o obj/output.o obj/writeStrFile.o obj/writeIntFile.o -o bin/pianificatore

obj/main.o: src/main.s 
	as $(AS_FLAGS) $(DEBUG) src/main.s -o obj/main.o

obj/menu.o: src/menu.s 
	as $(AS_FLAGS) $(DEBUG) src/menu.s -o obj/menu.o

obj/plan.o: src/plan.s 
	as $(AS_FLAGS) $(DEBUG) src/plan.s -o obj/plan.o

obj/printStr.o: src/printStr.s 
	as $(AS_FLAGS) $(DEBUG) src/printStr.s -o obj/printStr.o

obj/atoi.o: src/atoi.s 
	as $(AS_FLAGS) $(DEBUG) src/atoi.s -o obj/atoi.o

obj/printInt.o: src/printInt.s 
	as $(AS_FLAGS) $(DEBUG) src/printInt.s -o obj/printInt.o

obj/bubbleSort.o: src/bubbleSort.s 
	as $(AS_FLAGS) $(DEBUG) src/bubbleSort.s -o obj/bubbleSort.o

obj/swapOrders.o: src/swapOrders.s 
	as $(AS_FLAGS) $(DEBUG) src/swapOrders.s -o obj/swapOrders.o

obj/output.o: src/output.s 
	as $(AS_FLAGS) $(DEBUG) src/output.s -o obj/output.o

obj/writeStrFile.o: src/writeStrFile.s 
	as $(AS_FLAGS) $(DEBUG) src/writeStrFile.s -o obj/writeStrFile.o

obj/writeIntFile.o: src/writeIntFile.s 
	as $(AS_FLAGS) $(DEBUG) src/writeIntFile.s -o obj/writeIntFile.o

clean:
	rm -f obj/*.o bin/pianificatore
