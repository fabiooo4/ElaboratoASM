.section .data
  fd: .int 0          # File descriptor primo parametro
  fd2: .int 0          # File descriptor secondo parametro
  buffer: .string ""  # Spazio per il buffer di input
  newline: .byte 10   # Valore del simbolo di nuova linea
  values: .int 0      # Numero di valori inseriti nello stack
  lines: .long 0      # Numero di prodotti inseriti nello stack
  algorithm: .long 0  # Tipo di algoritmo da utilizzare: 1 edf, 2 hpf
  concatenate: .string ""  # Stringa per concatenare le cifre lette da file
  str: .ascii " "
  inputError: .ascii "  Il file di input non è corretto\n\0"

.section .text
    .global plan
    .type plan, @function

# Pianifica per primi gli ordini con scadenza minore
# Se la scadenza è uguale va prima quello con priorità più alta
plan:
  # Salva ebp nello stack per liberare %esp
  pushl %ebp 
  movl %esp, %ebp

  # Vai 2 posti indietro nello stack (1 call + 1 push)
  addl $8, %ebp
  movl (%ebp), %ebx  # Ottiene il carattere in input (algoritmo da utilizzare)
  subl $48, %ebx
  movl %ebx, algorithm # Lo sposta in algorithm

  # Vai ancora 1 indietro per ottenere il file descriptor secondo parametro
  addl $4, %ebp
  movl (%ebp), %ebx  # Ottiene il file descriptor passato dal menu
  movl %ebx, fd2     # e lo sposta in fd2

  # Vai ancora 1 indietro per ottenere il file descriptor primo parametro
  addl $4, %ebp
  movl (%ebp), %ebx  # Ottiene il file descriptor passato dal menu
  movl %ebx, fd      # e lo sposta in fd


  popl %ebp # Ripristina %ebp

  xorl %edi, %edi

  # Resetta il numero di valori e di linee letti e concatenate
  movl $0, values
  movl $0, lines
  movl $0, concatenate

  # Siccome il file è già stato aperto nel main e questa potrebbe non essere la
  # prima volta che viene letto bisogna "resettare" la posizione di lettura all'inizio
  # del file ogni volta che si vuole leggere da esso
  mov $19, %eax  # syscall lseek (riposiziona il read/write offset)
  mov fd, %ebx   # File descriptor
  mov $0, %ecx   # Valore di offset
  mov $0, %edx   # Posizione di riferimento (0 = inizio del file)
  int $0x80

  mov $19, %eax  # syscall lseek (riposiziona il read/write offset)
  mov fd2, %ebx   # File descriptor
  mov $0, %ecx   # Valore di offset
  mov $0, %edx   # Posizione di riferimento (0 = inizio del file)
  int $0x80

# Legge il file riga per riga
readLine:

  # Lettura di 1 byte alla volta (1 carattere)
  mov $3, %eax       # syscall read
  mov fd, %ebx       # File descriptor
  mov $buffer, %ecx  # Buffer di input
  mov $1, %edx       # Lunghezza massima
  int $0x80           

  # Se ci sono errori esco dalla funzione
  cmp $0, %eax
  jl endPlan

  # Altrimenti se c'è EOF controllo se l'input ha valori corretti ed eseguo l'algoritmo
  je check

  # Se c'è una nuova linea incrementa il contatore
  movb buffer, %al
  cmpb newline, %al
  jne pushInt 
  incw lines

# Se il carattere è un intero convertilo
pushInt:
  # Se il carattere non è una virgola, aggiungilo alla fine della stringa concatenate
  movb buffer, %al

  # if buffer == '\n' || buffer == ',' push, else appenb
  cmpb $10, %al
  je push

  cmpb $44, %al
  je push

  cmpb $48, %al
  jl errorInput

  cmpb $57, %al
  jg errorInput

  jmp append

push:
  # Se il carattere è una virgola resetta il contatore
  xorl %edi, %edi

  # Incrementa il contatore dei valori inseriti nello stack
  incw values

  # Converti la stringa in intero
  leal concatenate, %esi
  call atoi
  # Il risultato è in %eax

  # Inserisci nello stack
  pushl %eax

  # Resetta la stringa concatenate 
  movl $0, concatenate

  jmp readLine # Torna alla lettura del file

append:
  # Il carattere viene aggiunto a %ebx + %edi
  leal concatenate, %ebx
  movb %al, (%ebx, %edi)
  incl %edi

  jmp readLine # Torna alla lettura del file


# Controlla se i valori rispettano i vincoli imposti
check:
  # Salva %ebp per poterlo cambiare liberamente
  pushl %ebp
  movl %esp, %ebp

  movl values, %ecx
checkLoop:
  movl (%ebp, %ecx, 4), %eax # ID (1 <= ID <= 127)
  decl %ecx

  cmpl $1, %eax
  jl endCheck

  cmpl $127, %eax
  jg endCheck

  movl (%ebp, %ecx, 4), %eax # Durata (1 <= D <= 10)
  decl %ecx

  cmpl $1, %eax
  jl endCheck

  cmpl $10, %eax
  jg endCheck

  movl (%ebp, %ecx, 4), %eax # Scadenza (1 <= S <= 100)
  decl %ecx

  cmpl $1, %eax
  jl endCheck

  cmpl $100, %eax
  jg endCheck

  movl (%ebp, %ecx, 4), %eax # Priorità (1 <= P <= 5)

  cmpl $1, %eax
  jl endCheck

  cmpl $5, %eax
  jg endCheck

  loop checkLoop
  popl %ebp
  jmp planAlgorithm

endCheck:
  popl %ebp
  jmp errorInput

planAlgorithm:
  # Controlla l'algoritmo da usare
  cmpl $1, algorithm
  je edf

  # Altrimenti
  cmpl $2, algorithm
  movl values, %ecx
  jne popInt

  movl $4, %ecx
  movl $3, %esi

  jmp sort

edf:
  movl $3, %ecx
  movl $4, %esi

sort:
  # Riordina lo stack in base ad un offset messo in %ecx e il numero di valori in %edx
  # %ecx/$esi <- 1 = identificativo
  # %ecx/$esi <- 2 = durata
  # %ecx/$esi <- 3 = scadenza
  # %ecx/$esi <- 4 = priorità
  # Fallback in %esi nel caso a = b (nel caso di edf sarebbe la priorità se 2 scadenze sono uguali)
  # Numero di righe in %edi
  movl values, %edx
  movl lines, %edi
  call bubbleSort

  # Stack ordinato

  # Funzione che stampa la pianifica degli ordini
  movl algorithm, %eax
  movl values, %ebx
  movl lines, %ecx
  movl fd2, %edx
  call output

# Togli dallo stack tutti i valori
  movl values, %ecx
popInt:
  popl %eax
  loop popInt

endPlan:
  ret

errorInput:
  movl $4, %eax
  movl $2, %ebx
  leal inputError, %ecx
  movl $35, %edx
  int $0x80

  movl values, %ecx
  testl %ecx, %ecx
  jz terminate

  movl values, %ecx
terminatePop:
  popl %eax
  loop terminatePop

terminate:
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
