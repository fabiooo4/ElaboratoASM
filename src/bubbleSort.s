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

  # Vai 2 posti indietro nello stack (1 call + 1 push)
  addl $8, %ebp

# Salva numero valori e numero righe in .data
  movl %edx, values
  movl %edi, lines

# Sposta %edx alla colonna di parametri scelta dall'offset
  subl %ecx, %edx

# Reset flag
flag:
  movl $0, swapFlag
  movl lines, %edi

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

  descending:
  cmp %ebx, %eax
  jl lineIdx

  # Se a == b usa parametri fallback
  je fallback

  jmp bubbleLoop
  
lineIdx:
  # Torna all'inizio della seconda riga
  pushl %ecx

  subl $1, %ecx
  addl %ecx, %edx

  popl %ecx

  movl %edx, %ebx

  # Vai alla riga sopra
  addl $4, %edx
  movl %edx, %eax
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

  # Carica i registri
  popl %ecx
  popl %esi

  # Se viene usato edf (%ecx = 3) ordina crescente
  cmp $3, %ecx
  jne fallbackDescending

  cmp %ebx, %eax
  jl fallbackLineIdx

fallbackDescending:
  # Se viene usato hpf (%ecx != 3) ordina decrescente
  cmp %ebx, %eax
  jg fallbackLineIdx

  jmp bubbleLoop

fallbackLineIdx:
  # Torna all'inizio della seconda riga
  pushl %esi

  subl $1, %esi
  addl %esi, %edx

  popl %esi

  movl %edx, %ebx

  # Vai alla riga sopra
  addl $4, %edx
  movl %edx, %eax

# Scambia il parametro1(%eax) con parametro2(%ebx)
swap:
  # Salva i registri
  pushl %ecx
  pushl %esi
  pushl %edx
  pushl %edi

  # %eax <- indice della prima riga (offset a ebp)
  # %ebx <- indice della seconda riga (offset a ebp)
  # %ebp <- indice del primo elemento nello stack
  movl $1, swapFlag
  # call swapOrders

  # Carica i valori
  popl %edi
  popl %edx
  popl %esi
  popl %ecx

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
