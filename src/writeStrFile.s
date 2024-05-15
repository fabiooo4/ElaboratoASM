.section .text
  .global writeStrFile
  .type writeStrFile, @function

# Stampa la stringa in %ecx
# Nel file descriptor in %ebx
writeStrFile:
  # Resetta %edx per contare quanti caratteri stampare
  xorl %edx, %edx

countChars:
  # Muove il carattere in posizione %ecx + %edx in %al
  movb (%ecx,%edx), %al 

  # Se il carattere è 0 smetti di contare
  testb %al, %al
  jz print

  # Incrementa $edx e itera al prossimo carattere
  incl %edx
  jmp countChars
  
print:
  movl $4, %eax
  # %ebx contiene il file descriptor
  # %ecx contiene la stringa da stampare
  # %edx contiene la lunghezza della stringa
  int $0x80

  # Stampa '\n'
  # %eax contiene già la syscall write
  # %ebx contiene già l'id di stdout
  movl $10, %ecx
  movl $1, %edx
  int $0x80

  ret
