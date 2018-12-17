SYMFORMAT=dwarf
FORMAT=elf

gcd: gcd.o
	gcc -m32 -nostartfiles -g -o gcd gcd.o

gcd.o: gcd.asm
	nasm -f $(FORMAT) -g -F $(SYMFORMAT) gcd.asm

run: gcd
	./gcd

clean: gcd gcd.o
	rm gcd gcd.o
