.section .text

  .global _start

_start:
  popl %esi # Salta il numero di parametri
  popl %esi # Salta il nome del programma

  # Primo parametro
  popl %esi

  # Se il parametro non è vuoto apri il file
  testl %esi, %esi
  jz paramError

  # Apri il file del parametro1
  movl $5, %eax # Syscall open
  movl %esi, %ebx # Nome del file
  movl $0, %ecx # Modalità lettura
  int $0x80

  # Se il file descriptor è null allora errore
  testl %eax, %eax
  jz fileError

  # Il file descriptor si trova in %eax
  # Apre il loop del menu (presupponendo il file descriptor in %eax)
  call menu
  jmp end

paramError:

fileError:

end:
  # Termina
  movl $1, %eax
  movl $0, %ebx
  int $0x80
