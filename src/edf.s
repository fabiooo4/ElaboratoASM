# .section .data
#   fd: .int 0               # File descriptor
#   buffer: .string ""       # Spazio per il buffer di input
#   newline: .byte 10        # Valore di '\n'
#   lines: .int 0            # Numero di linee
#
#   readError: .ascii "Errore nella lettura del file\n\0"
#
# .section .bss
#
# .section .text
#   .global edf
#   .type edf, @function
#
# edf:
#   # Salva ebp nello stack per liberare %esp
#   pushl %ebp 
#   movl %esp, %ebp
#
#   # Vai 2 posti indietro nello stack (1 call + 1 push)
#   addl $8, %ebp
#   movl (%ebp), %ebx # Ottiene il file descriptor passato dal menu
#   movl %ebx, fd     # e lo sposta in fd
#
#   popl %ebp # Ripristina %ebp
#
# readFile:
#   mov $3, %eax      # syscall read
#   mov fd, %ebx      # File descriptor
#   mov $buffer, %ecx  # Buffer di input
#   mov $1, %edx      # Lunghezza massima
#   int $0x80
#
#   # Se ci sono errori o EOF esco dalla funzione
#   cmp $0, %eax
#   jl errorRead
#     
#   # Controllo se ho una nuova linea
#   movb buffer, %al
#   cmpb newline, %al
#   # Se c'è una nuova linea incremento il contatore delle linee
#   jne printLine
#   incw lines
#
# printLine:
#   # Stampa la linea
#   mov $4, %eax        # syscall write
#   mov $1, %ebx        # File descriptor standard output (stdout)
#   mov $buffer, %ecx   # Buffer di output
#   int $0x80           # Interruzione del kernel
#
#   # Continua a leggere il file
#   jmp readFile
#
# errorRead:
#   # Se non è un errore, ma è solo finito il file non stampa niente
#   testl %eax, %eax
#   jz edfEnd
#
#   # Se c'è un errore stampa la stringa di errore
#   leal readError, %ecx
#   call printStr
#
# edfEnd:
#   ret


.section .data
filename:
    .ascii "test.txt"    # Nome del file di testo da leggere
fd:
    .int 0               # File descriptor

buffer: .string ""       # Spazio per il buffer di input
newline: .byte 10        # Valore del simbolo di nuova linea
lines: .int 0            # Numero di linee

.section .bss

.section .text
    .globl edf
    .type edf, @function

# Apre il file
edf:
  # Salva ebp nello stack per liberare %esp
  pushl %ebp 
  movl %esp, %ebp

  # Vai 2 posti indietro nello stack (1 call + 1 push)
  addl $8, %ebp
  movl (%ebp), %ebx # Ottiene il file descriptor passato dal menu
  movl %ebx, fd     # e lo sposta in fd

  popl %ebp # Ripristina %ebp

# Legge il file riga per riga
readLine:
    mov $3, %eax       # syscall read
    mov fd, %ebx       # File descriptor
    mov $buffer, %ecx  # Buffer di input
    mov $1, %edx       # Lunghezza massima
    int $0x80           

    # Se ci sono errori o EOF esco dalla funzione
    cmp $0, %eax
    jle endEdf
    
    # Se c'è una nuova linea incrementa il contatore
    movb buffer, %al
    cmpb newline, %al
    jne printLine
    incw lines

printLine:
    # Stampa il contenuto della riga
    mov $4, %eax        # syscall write
    mov $1, %ebx        # File descriptor standard output (stdout)
    mov $buffer, %ecx   # Buffer di output
    int $0x80           # Interruzione del kernel

    jmp readLine # Torna alla lettura del file

endEdf:
  ret
