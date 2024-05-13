.section .data
  values: .int 0      # Numero di valori inseriti nello stack
  lines: .long 0      # Numero di valori inseriti nello stack
  swapFlag: .byte 0   # Flag per segnare se è stato effettuato uno scambio

.section .text
  .global bubbleSort
  .type bubbleSort, @function

# %ecx offset parametri
# %edx numero valori
# %edi numero di righe nel file
# %esi fallback parametri
bubbleSort:
  # Salva ebp nello stack per liberare %esp
  pushl %ebp 
  movl %esp, %ebp

  # Salva numero valori e numero righe in .data
  movl %edx, values
  movl %edi, lines

  # Vai 2 posti indietro nello stack (1 call + 1 push)
  addl $8, %ebp

# Reset flag
flag:
  movl $0, swapFlag
  movl lines, %edi

  # Sposta %edx alla colonna di parametri scelta dall'offset
  movl values, %edx
  subl %ecx, %edx

bubbleLoop:
  decl %edi

  # Se abbiamo controllato tutte le righe controlla se la lista è ordinata
  cmpl $0, %edi
  je isOrdered

  movl (%ebp, %edx, 4), %eax  # Parametro 1
  subl $4, %edx
  movl (%ebp, %edx, 4), %ebx  # Parametro 2

  # Se viene usato hpf (%ecx != 3) ordina decrescente
  cmp $3, %ecx
  jne descending

  # Se viene usato edf (%ecx = 3) ordina crescente
  cmp %ebx, %eax
  jg lineIdx

  # Se a == b usa parametri fallback
  je fallback

  jmp bubbleLoop

  descending:
  cmp %ebx, %eax
  jl lineIdx

  # Se a == b usa parametri fallback
  je fallback

  jmp bubbleLoop
  
lineIdx:
  # Torna all'inizio della seconda riga
  pushl %edx
  pushl %ecx

  subl $1, %ecx
  addl %ecx, %edx

  popl %ecx

  movl %edx, %ebx

  # Vai alla riga sopra
  addl $4, %edx
  movl %edx, %eax
  popl %edx
  jmp swap

fallback:
  # Salva i registri
  pushl %esi
  pushl %ecx

  # Sposta %edx una riga indietro per leggere il primo parametro
  addl $4, %edx

  # Sposta %edx alla colonna di parametri scelta dal fallback
  subl %esi, %ecx
  addl %ecx, %edx

  # Leggi i parametri
  movl (%ebp, %edx, 4), %eax  # Parametro 1
  subl $4, %edx
  movl (%ebp, %edx, 4), %ebx  # Parametro 2

  subl %ecx, %edx

  # Carica i registri
  popl %ecx
  popl %esi

  # Se viene usato edf (%ecx = 3) ordina decrescente
  cmp $3, %ecx
  jne fallbackDescending

  cmp %ebx, %eax
  jl lineIdx

  jmp bubbleLoop

fallbackDescending:
  # Se viene usato hpf (%ecx != 3) ordina crescente
  cmp %ebx, %eax
  jg lineIdx

  jmp bubbleLoop

# Scambia il parametro1(%eax) con parametro2(%ebx)
swap:
  # Salva i registri
  pushl %edx
  pushl %ecx
  pushl %esi
  pushl %edi

  # %eax <- indice della prima riga (offset a ebp)
  # %ebx <- indice della seconda riga (offset a ebp)
  # %ebp <- indice del primo elemento nello stack
  movl $1, swapFlag
  call swapOrders

  # Carica i valori
  popl %edi
  popl %esi
  popl %ecx
  popl %edx

  jmp bubbleLoop

isOrdered:
  # Se non è stato effettuato nessuno swap allora la lista è ordinata
  cmpl $1, swapFlag
  jne return

  jmp flag

return:
  popl %ebp # Ripristina %ebp

  # Lo stack sarà ordinato in base al valore scelto da %ecx
  ret
