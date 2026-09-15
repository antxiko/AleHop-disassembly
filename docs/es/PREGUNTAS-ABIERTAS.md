# Preguntas abiertas

Los 42.645 bytes del bloque del juego están explicados, los módulos reensamblan
byte a byte y la cinta regenerada tiene el mismo sha256. Lo que queda abierto es
poco, y va aquí.

## De qué compilación es el cargador de 0x8850

Al final de los datos, detrás del último bloque de gráficos comprimidos, hay un
cargador de 45 bytes que no ejecuta nadie. Salta a 0xC000 como el juego de
verdad, pero **deja otro mapa de memoria**: ROM en las páginas 0 *y* 1 y RAM solo
en las dos de arriba, así que en esa versión los datos vivían debajo de la ROM
del BASIC y no debajo del BIOS. Usa además la variable 0xA87D, que en esta
versión no existe: el bloque del juego acaba en 0xA694.

Es, por tanto, un resto de **otra compilación** de Ale Hop!. Cuál era, y si llegó
a salir, no se sabe. El detalle está en [los bytes muertos](BYTES-MUERTOS.html).

## Los 66 bytes de 0x88DA

En la pieza de la portada, entre el `ret` de 0x88D9 —que devuelve el control al
cargador— y la tabla de patrones de la imagen, que empieza en 0x891C, quedan 66
bytes. El listado los da como un residuo que no se ejecuta, y lo marca como
suposición: qué eran no se ha averiguado.
