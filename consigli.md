# Consigli

Un sistema produttivo deve produrre 10 prodotti in 100 unità di tempo. Ogni prodotto
avrà una durata di produzione diversa. (il 100 è completamente inutile, basta fare 1
prodotto in massimo 10 unità di tempo). Si può implementare la logica degli array per risolvere
il problema.

Se il prodotto viene completato in ritardo bisogna pagare (priorità) \* (tempo di ritardo) euro.


x,6,10,5   (6 - 10)
x,5,16,5   (11 - 16)
x,3,23,5   (14 - 23)
x,8,31,4   (22 - 31)
x,2,32,4   (24 - 32)
x,6,35,3   (30 - 35)
x,7,44,2   (37 - 44)
x,1,50,2   (38 - 50)
x,9,61,2   (47 - 61)
x,3,65,1   (50 - 65)
