# Hallazgos

Lo que apareció al desmontar el juego, ordenado de más a menos sorprendente.

## Un mensaje que casi nadie llegó a leer

Al superar el sexto y último nivel aparece una pantalla con un texto que hace
scroll:

![El mensaje final](../mensaje-final.png)

> ENHORABUENA!!! HAS CONSEGUIDO SUPERAR LOS OBSTACULOS QUE TE SEPARABAN DE LA
> VICTORIA... TOPO SOFT TE FELICITA. PERO... **PODRAS CON TEMPTATION??**

Lo curioso es cómo está hecho. La pantalla que lo enmarca tiene dos recuadros
**vacíos**: el texto no está dibujado en ninguna parte. Está en ASCII en
0xC3F0 y lo pasa una rutina que lee letra a letra, saca el dibujo de cada una de
la propia memoria de vídeo con una llamada al BIOS, y lo desplaza un píxel por
fotograma. Un scroll suave hecho a mano.

La despedida remata invitando a otro juego que Topo Soft había publicado el año
anterior, *Temptations*, que a su vez terminaba invitando a éste. Se llaman el
uno al otro.

Y solo se ve terminándose el juego entero, así que en 1988 no debió leerlo mucha
gente.

## El juego se carga encima de la ROM

Un MSX de 64 KB no tiene los 64 KB a mano: la página de abajo, de 0x0000 a
0x3FFF, la ocupa la ROM del BIOS, y la RAM que hay debajo está tapada. Lo
habitual en un juego de cinta es no complicarse y cargar a partir de 0x4000.

*Ale Hop!* hace lo contrario. Mete el bloque de 42645 bytes **en la página 0**,
encima de donde está el BIOS, y después mueve tres trozos a RAM alta y vuelve a
tapar lo que queda con la ROM.

O sea que los 35 KB de gráficos y mapas están **escondidos debajo del BIOS**
casi todo el tiempo. El juego solo los destapa un instante cada vez que carga un
nivel, entre un `call 0xF00F` y un `call 0xF000`, copia lo que necesita y vuelve
a taparlos. Así puede seguir llamando al BIOS como si nada el resto del tiempo.

Es la decisión que da forma a todo lo demás, incluido que este desensamblado
sean cinco listados en vez de uno.

## Hay sitio para dos niveles que no existen

Los mapas de fondo se buscan con la fórmula `0x3000 + nivel * 0x200`. Hay
espacio para ocho, pero solo seis tienen datos: los 1024 bytes que ocuparían el
7 y el 8 son **relleno 0xFF**, y el cargador corta en el sexto con un
`cp 6 / jp z,0xC000`.

## 135 bytes que no se ejecutan nunca

Cuatro trozos de código Z80 perfectamente coherente a los que no llega ningún
camino. Entre ellos, un **efecto de color a pantalla completa** que convierte
todo el negro en transparente —3673 de los 6144 bytes de color de la pantalla— y
que solo tiene sentido acompañado de un cambio del color de fondo. Medio fundido
que se quedó fuera.

![El efecto que no llegó a usarse](../efecto-muerto.png)

La historia completa de los cuatro, en [BYTES-MUERTOS.md](BYTES-MUERTOS.md).

## El parallax cabe en una instrucción

El fondo se mueve cuatro veces más despacio que la pista, y el truco es de una
sencillez desarmante. Las dos rutinas de volcado leen la misma variable —la
columna de cámara— pero la del fondo le hace un `and 0x3F` y su mapa tiene 64
columnas, mientras que la de la pista usa el byte entero sobre un mapa de 256.
Nada más. Efecto de profundidad a coste cero.

## Un sprite multicolor en una máquina que no los tiene

El MSX1 solo admite un color por sprite. El protagonista se dibuja superponiendo
**tres sprites** en la misma posición, uno por color —negro, blanco y amarillo
claro—, montados de nuevo en cada fotograma. La bola que rebota en la pantalla
de título usa exactamente lo mismo.

## El motor de sonido viene de fuera

El reproductor de música no parece escrito para este juego, sino integrado como
librería. La pista está en el propio binario: trae **su propio manejador de
interrupción**, listo para engancharse al sistema... y el juego no lo usa, porque
tiene el suyo. Se quedó ahí, 21 bytes que no ejecuta nadie.

## Los créditos

La pantalla de presentación, reconstruida descomprimiendo los gráficos y
montando el mapa, dice:

> **PROGRAMA:** ALBERTO L. NAVARRO · **GRÁFICOS:** LUIGILOPEZ · TOPO SOFT 1988

Está leído del binario, no de fuentes externas. Es lo que el propio juego
declara.
