# Consigli

Un sistema produttivo deve produrre 10 prodotti in 100 unità di tempo. Ogni prodotto
avrà una durata di produzione diversa. (il 100 è completamente inutile, basta fare 1
prodotto in massimo 10 unità di tempo). Si può implementare la logica degli array per risolvere
il problema.

Se il prodotto viene completato in ritardo bisogna pagare (priorità) \* (tempo di ritardo) euro.


conclusione  10    p (tf - scad) * prio
9,2,9,2      8     p = (10 - 9) * 2
11,4,6,4     4     p = (8 - 6) * 4
8,1,5,4      3     p = (4 - 5) * 4
10,3,2,2     0     p = (3 - 2) * 2 x
