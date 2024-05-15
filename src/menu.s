.section .data
  fd: .int 0 # File descriptor primo parametro
  fd2: .int 0 # File descriptor secondo parametro

  title: .ascii "Che algoritmo vuoi usare per pianificare gli ordini?\n\0"
  entry1: .ascii "  1. Earliest Deadline First (EDF)\n\0"
  entry2: .ascii "  2. Highest Priority First (HPF)\n\0"
  entry3: .ascii "  3. Esci\n\0"

  inputError: .ascii "Input non valido, inserire un numero da 1 a 3\n\0"

.section .bss
  input: .string "" # Input buffer

.section .text
  .global menu
  .type menu, @function

# Stampa il menu (presupponendo un file descriptor in %eax)
menu:
  movl %ebx, fd
  movl %eax, fd2

menuLoop:
  # Stampa titolo
  leal title, %ecx
  call printStr

  # Stampa edf
  leal entry1, %ecx
  call printStr

  # Stampa hpf
  leal entry2, %ecx
  call printStr

  # Stampa Esci
  leal entry3, %ecx
  call printStr

  # Ottieni input da tastiera
readInput:
	movl $3, %eax     # syscall read
	movl $0, %ebx     # id tastiera
	leal input, %ecx  # destinazione
	movl $50, %edx    # lunghezza stringa
	int $0x80             

  xorl %ebx, %ebx
countChar:
  # Conta quanti caratteri ha la stringa in input
  movb (%ecx, %ebx), %dl

  incl %ebx

  cmpb $10, %dl
  jne countChar

  # Se il numero di caratteri != 2, stampa errore (2 perchè conta anche \n)
  cmp $2, %ebx
  jne errorInput

  # Metti il primo carattere di %ecx in %dl
  movb (%ecx), %dl

  cmpb $49, %dl # Controlla il primo carattere della stringa in input con '1'
  je exec

  cmpb $50, %dl # Controlla il primo carattere della stringa in input con '2'
  je exec

  cmpb $51, %dl # Controlla il primo carattere della stringa in input con '3'
  je menuEnd

errorInput:
  leal inputError, %ecx
  call printStr
  jmp readInput
  
  
exec:
  pushl fd # Salva il file descriptor nello stack
  pushl fd2 # Salva il file descriptor2 nello stack
  pushl %edx # Salva il carattere di input nello stack

  # Stampa '\n'
  movl $10, input
  movl $4, %eax
  movl $1, %ebx
  leal input, %ecx
  movl $1, %edx
  int $0x80

  call plan
  popl %edx
  popl fd2
  popl fd 

  jmp menuLoop

menuEnd:
  ret
