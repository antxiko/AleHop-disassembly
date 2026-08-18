# Hallazgos

Lo que no cuentan las otras páginas: dos cosas que están en el binario y el juego no usa.

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
