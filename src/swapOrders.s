.section .text
  .global swapOrders
  .type swapOrders, @function


# %eax: indice della prima riga (offset a ebp)
# %ebx: indice della seconda riga (offset a ebp)
# %ebp: indice del primo elemento nello stack
swapOrders:
  movl $4, %ecx

swapValues:
  # Scambia 2 valori per l'intera riga (4 volte)
  # a = d
  # b -> *a
  # d -> *b
  movl (%ebp, %eax, 4), %edx
  movl (%ebp, %ebx, 4), %edi

  leal (%ebp, %eax, 4), %esi
  movl %edi, (%esi)

  leal (%ebp, %ebx, 4), %esi
  movl %edx, (%esi)

  decl %eax
  decl %ebx

  loop swapValues

  ret
