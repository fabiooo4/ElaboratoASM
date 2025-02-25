.section .data
  fd: .int 0 # File descriptor del primo parametro
  fd2: .int 0 # File descriptor del secondo parametro
  paramError: .ascii "Nessun parametro fornito\n\0"
  fileError: .ascii "Errore nell'apertura del file\n\0"

.section .text

  .global _start

_start:
  popl %esi # Salta il numero di parametri
  popl %esi # Salta il nome del programma


  # Primo parametro
  popl %esi

  # Se il parametro non è vuoto apri il file
  testl %esi, %esi
  jz errorParam


  # Apri il file del parametro1
  movl $5, %eax   # Syscall open
  movl %esi, %ebx # Nome del file
  movl $0, %ecx   # Modalità lettura
  int $0x80

  # Se il file descriptor è null allora errore
  cmp $0, %eax
  jl errorFile

  movl %eax, fd

  # Secondo parametro
  popl %esi

  # Se il parametro non è vuoto apri il file
  testl %esi, %esi
  jz endParams

  # Apri il file del parametro2
  movl $5, %eax   # Syscall open
  movl %esi, %ebx # Nome del file
  movl $1, %ecx   # Modalità scrittura
  int $0x80

  cmp $0, %eax
  jl errorFile

  movl %eax, fd2

endParams:
  # fd2 è già in %eax (se esiste)
  movl fd, %ebx

  # Apre il loop del menu (presupponendo il file descriptor in %ebx,
  # oppure se è stato inserito il secondo parametro il secondo fd sarà in %eax)
  call menu
  jmp end

errorParam:
  # Stampa paramError in stderr
  movl $4, %eax
  movl $2, %ebx
  leal paramError, %ecx
  movl $26, %edx
  int $0x80

  jmp end

errorFile:
  # Stampa fileError in stderr
  movl $4, %eax
  movl $2, %ebx
  leal fileError, %ecx
  movl $31, %edx
  int $0x80

  jmp end

end:
  # Chiudi il file aperto dal parametro1
  mov $6, %eax # syscall close
  mov fd, %ecx # File descriptor
  int $0x80

  # Chiudi il file aperto dal parametro1
  mov $6, %eax # syscall close
  mov fd2, %ecx # File descriptor
  int $0x80

  # Termina
  movl $1, %eax
  movl $0, %ebx
  int $0x80
