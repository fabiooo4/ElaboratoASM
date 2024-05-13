.section .data
  algorithm: .long 0 # Algoritmo
  values: .long 0 # Numero di valori nello stack
  lines: .long 0 # Numero di ordini

  outputTitle: .ascii "Pianificazione \0"
  edfStr: .ascii "EDF:\n\0"
  hpfStr: .ascii "HPF:\n\0"
  conclusion: .ascii "Conclusione: \0"
  penalty: .ascii "Penalty: \0"
  char: .ascii ""

.section .bss

.section .text
  .global output
  .type output, @function

# Funzione che stampa la pianifica degli ordini
# %eax: algorithm
# %ebx: values
# $ecx: lines
output:
  # Salva ebp nello stack per liberare %esp
  pushl %ebp 
  movl %esp, %ebp

  movl %eax, algorithm
  movl %ebx, values
  movl %ecx, lines

  # Vai 2 posti indietro nello stack (1 call + 1 push)
  addl $8, %ebp

  # Stampa il titolo scegliendo EDF o HPF in base all'input dell'utente
  leal outputTitle, %ecx
  call printStr

  # Se edf:
  cmpl $1, algorithm
  jne outHpf

  leal edfStr, %ecx
  call printStr

  jmp calcOutput

outHpf:
  # Se hpf:
  cmpl $2, algorithm
  jne endOutput

  leal hpfStr, %ecx
  call printStr

calcOutput:
  movl $-1, %edx # Resetta %edx per offset

  # Porta l'offset al primo valore
  addl values, %edx
  # Porta l'offset alla colonna della durata
  decl %edx

  movl lines, %ebx
  xorl %ecx, %ecx # Resetta %ecx per tenere traccia del tempo
# Metti il tempo di inizio nello stack
pushTime:
  pushl %ecx

  cmpl $0, %ebx
  je print

  addl (%ebp, %edx, 4), %ecx

  subl $4, %edx

  decl %ebx
  jmp pushTime

print:
  movl $-1, %edx # Resetta %edx per offset

  # Porta l'offset al primo valore
  addl values, %edx
  movl lines, %ebx
printID:
  cmp $0, %ebx
  je printConclusion

  pushl %edx
  pushl %ebx

  # Stampa l'ID
  movl (%ebp, %edx, 4), %eax
  call printInt

  # Stampa ':'
  movl $58, char
  movl $4, %eax
  movl $1, %ebx
  leal char, %ecx
  movl $1, %edx
  int $0x80


  # Stampa il tempo di inizio
  popl %ebx
  # Offset da %esp (+2 push)
  addl $1, %ebx

  movl (%esp, %ebx, 4), %eax

  pushl %ebx
  call printInt
  popl %ebx

  # Riporto %ebx al valore precedente
  subl $1, %ebx

  pushl %ebx

  # Stampa il carattere '\n'
  movb $10, char

  movl $4, %eax
  movl $1, %ebx
  leal char, %ecx
  movl $1, %edx
  int $0x80

  popl %ebx
  popl %edx

  subl $4, %edx
  decl %ebx
  jmp printID

printConclusion:
  # Stampa 'Conclusione'
  leal conclusion, %ecx
  call printStr

  # Stampa il tempo finale
  movl (%esp), %eax
  call printInt

  # Stampa il carattere '\n'
  movb $10, char

  movl $4, %eax
  movl $1, %ebx
  leal char, %ecx
  movl $1, %edx
  int $0x80


  # Resetta i registri
  xorl %eax, %eax
  xorl %ebx, %ebx
  xorl %edi, %edi
  xorl %esi, %esi

  movl $-1, %edx # Resetta %edx per offset

  # Porta l'offset al primo valore
  addl values, %edx
  # Porta l'offset alla colonna della scadenza
  subl $2, %edx

  movl lines, %ecx

  movl %ecx, %esi
  decl %esi
calcPenalty:
  # penalty = (tf - scad) * prio
  movl (%esp, %esi, 4), %eax # Tempo finale (tf)
  movl (%ebp, %edx, 4), %ebx # Scadenza (scad)

  subl %ebx, %eax # %eax = tf - scad

  cmp $0, %eax
  jle noPenalty

  pushl %edx

  # Offset a priorità
  decl %edx
  movl (%ebp, %edx, 4), %ebx # Priorità (prio)

  xorl %edx, %edx
  # %eax = (tf - scad) * prio
  mull %ebx  
  popl %edx

  addl %eax, %edi

noPenalty:
  subl $4, %edx
  decl %esi
  loop calcPenalty

  # Stampa 'Penalty: '
  leal penalty, %ecx
  call printStr

  # Stampa penalità in %edi
  movl %edi, %eax
  call printInt

  # Stampa il carattere '\n'
  movl $2, %ecx
newLine:
  movb $10, char

  pushl %ecx
  movl $4, %eax
  movl $1, %ebx
  leal char, %ecx
  movl $1, %edx
  int $0x80
  popl %ecx

  loop newLine


  # Rimuovi dallo stack tutti i tempi di inizio
  movl lines, %ecx
  incl %ecx
popTimes:
  popl %eax
  loop popTimes

endOutput:
  popl %ebp # Ripristina %ebp

  ret
