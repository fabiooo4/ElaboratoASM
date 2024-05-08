.section .data
  fd: .int 0               # File descriptor
  buffer: .string ""       # Spazio per il buffer di input
  newline: .byte 10        # Valore di '\n'
  lines: .int 0            # Numero di linee

.section .text
  .global edf
  .type edf, @function

edf:
  # Salva ebp nello stack per liberare %esp
  pushl %ebp 
  movl %esp, %ebp

  # Vai 2 posti indietro nello stack (1 call + 1 push)
  addl $8, %ebp
  movl (%ebp), %ebx # Ottiene il file descriptor passato dal menu
  movl %ebx, fd # e lo sposta in fd

  popl %ebp # Ripristina %ebp

  ret
