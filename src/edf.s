.section .data
  filename: .ascii "test.txt"  # Nome del file di testo da leggere
  fd: .int 0                   # File descriptor
  buffer: .string ""           # Spazio per il buffer di input
  newline: .byte 10            # Valore del simbolo di nuova linea
  lines: .int 0                # Numero di linee

  concatenate: .string ""

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
xorl %edi, %edi
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
  # # Stampa il contenuto della riga
  # mov $4, %eax        # syscall write
  # mov $1, %ebx        # File descriptor standard output (stdout)
  # mov $buffer, %ecx   # Buffer di output
  # int $0x80           # Interruzione del kernel

# Se il carattere è un intero convertilo
pushInt:
  # Se il carattere non è una virgola, aggiungilo alla fine della stringa concatenate
  movb buffer, %al

  # if buffer == '\n' || buffer == ',' push, else appenb
  cmpb $10, %al
  je push

  cmpb $44, %al
  jne append

push:
  # Se il carattere è una virgola resetta il contatore
  xorl %edi, %edi

  # Converti la stringa in intero
  leal concatenate, %esi
  call atoi
  # Il risultato è in %eax

  # Inserisci nello stack
  pushl %eax

  movl $0, concatenate

  jmp readLine # Torna alla lettura del file

append:
  # Il carattere viene aggiunto a %ebx + %edi
  leal concatenate, %ebx
  movb %al, (%ebx, %edi)
  incl %edi

  jmp readLine # Torna alla lettura del file

endEdf:
  ret
