# El código por dentro

Los 42645 bytes del bloque del juego se reparten así:

| | bytes | |
|---|---|---|
| Código trazado | 4588 | 10,8 % |
| Datos identificados | 38057 | 89,2 % |
| **Sin explicar** | **0** | |

Que solo el 10,8 % sea código no significa que falte desensamblar: significa que
*Ale Hop!* es, sobre todo, gráficos. Un juego de MSX de esta época cabe en muy
pocas instrucciones; lo que ocupa son los dibujos.

## Cinco listados, no uno

El cargador recoloca tres trozos antes de arrancar el juego, así que las
direcciones de la cinta y las de ejecución no coinciden. Para que el listado se
lea con las direcciones **de verdad** y aun así reensamble al binario original,
el juego se parte en cinco módulos:

| listado | se ejecuta en | en la cinta | bytes |
|---|---|---|---|
| `alehop_game_datos.asm` | 0x0000 | 0x00000 | 35393 |
| `alehop_game_sonido.asm` | 0xB000 | 0x08A41 | 2201 |
| `alehop_game_nucleo.asm` | 0xBD00 | 0x092DA | 2112 |
| `alehop_game_extra.asm` | 0xD000 | 0x09B1A | 2938 |
| `alehop_game_cola.asm` | 0xA694 | 0x0A694 | 1 |

Concatenados en ese orden dan los 42645 bytes exactos. Lo hace
`tools/split_trace.py` y lo comprueba un test.

## Cómo convive con la ROM

El juego arranca en 0xC000 y lo primero que hace, después de poner la pila, es
configurar la memoria con tres llamadas a un conmutador de slots que el cargador
le ha dejado en 0xF000:

```
ld sp,0xF37F
ld (0xC52E),a      ; 0 = arranque normal, distinto = fin de partida
call 0xF000        ; página 0 -> ROM del BIOS
call 0xF014        ; página 1 -> RAM
call 0xF019        ; página 2 -> RAM
```

Ese conmutador tiene **seis puntos de entrada** que hacen lo mismo con
parámetros distintos: tres ponen una página en la configuración del BASIC y tres
en la de todo-RAM, cubriendo las páginas 0, 1 y 2.

La consecuencia práctica, y conviene tenerla presente al leer el listado: **toda
dirección por debajo de 0x4000 que aparezca en un `CALL` o un `JP` es el BIOS**,
no datos del juego. Los 35 KB de gráficos que hay ahí debajo solo son visibles
dentro del cargador de nivel.

## La rutina de frame

El motor no tiene un bucle principal al uso, sino una **máscara de tareas** de
16 bits en 0xDB69. La rutina de frame espera al retrazo y luego consulta bit a
bit:

```
ld ix,0xDB69
halt
bit 7,(ix+0) / call nz,VUELCA_MAPA
bit 6,(ix+0) / call nz,VUELCA_FONDO
bit 5,(ix+0) / call nz,ANIMA_CASILLAS
bit 4,(ix+0) / call nz,APLICA_VELOCIDAD
bit 3,(ix+0) / call nz,AVANZA_CAMARA
bit 2,(ix+0) / call nz,APLICA_ALTURA
bit 1,(ix+0) / call nz,PATRON_SEGUN_FRAME
bit 0,(ix+0) / call nz,PINTA_JUGADOR
bit 7,(ix+1) / call nz,COLISION
bit 6,(ix+1) / call nz,SALTO
bit 5,(ix+1) / call nz,CUENTA_ATRAS
```

Cambiando la máscara se cambia el estado del juego sin tocar el flujo: 0xE0FF
cuando se juega normal, y valores más pequeños cuando el jugador está muriendo o
la fase está terminando. El bucle principal la repone en cada vuelta:

```
BUCLE_PRINCIPAL:
    ld sp,0xF37F        ; la pila se repone: los manejadores de colisión saltan sin limpiarla
    call FRAME
    ld hl,0xE0FF
    ld (0xDB69),hl
    jr BUCLE_PRINCIPAL
```

## La interrupción rápida

El juego engancha su rutina en **H.TIMI** (0xFD9F), el hook que el BIOS llama en
cada interrupción de vídeo. Pero no vuelve por donde debería:

```
in a,(0x99)         ; acepta la interrupción del VDP
pop hl              ; TIRA la dirección de retorno al manejador del BIOS
di
ld hl,0xDB75
inc (hl)            ; contador de frames
call SONIDO_FRAME
pop ix / pop iy / pop af / pop bc / pop de / pop hl
ex af,af' / exx
pop af / pop bc / pop de / pop hl
ei
ret
```

Descarta la vuelta al BIOS y desapila a mano los registros que el BIOS acababa
de guardar. Así se ahorra el resto de la rutina de interrupción del sistema, que
en un juego que va justo de tiempo es mucho. Hay tres copias de este mismo
esqueleto en el binario: la del título, la de la partida, y una tercera que no
se usa.

## El sonido

Cada uno de los tres canales del PSG tiene un bloque de estado de **46 bytes**
(el propio código lo dice: `ld de,0x002E`), con el puntero a su melodía por
duplicado —uno avanza y el otro sirve para repetir—, la duración pendiente, el
volumen, el periodo y unos ajustes que se suman cada frame. Esos ajustes son
dos envolventes por software: una de volumen con dos fases y otra de periodo
con tres, cada una con sus pasos, su incremento con signo y su espera. No son
vibrato: se recorren una sola vez, y solo volverian a empezar si el comando
0x8A encendiera sus bits, algo que en la musica de la portada no pasa —el
unico 0x8A de las tres voces lleva un 0—.

La melodía es un flujo de bytes: por debajo de 0x80 son notas, y de 0x80 para
arriba son comandos que se despachan por una tabla de saltos de **12 entradas**
en 0xB486.

Los tres canales escriben en un búfer de sombra de 11 bytes en 0xB4A0, con el
mismo orden que los registros del chip, y una sola rutina los vuelca todos de
golpe al final del frame.

El reproductor no parece código escrito para este juego, sino una biblioteca
metida dentro. La pista está en el binario: trae **su propio gestor de
interrupción**, listo para engancharse al sistema, y el juego no lo usa nunca
porque tiene el suyo.

## Los gráficos

Van comprimidos con un **RLE de tokens de 16 bits**:

```
0xFFFF        fin del bloque
bit 15 a 1    repetir el byte siguiente (n & 0x7FFF) veces
bit 15 a 0    copiar n bytes literales
```

Son 11 bloques que descomprimen a 2048 bytes exactos cada uno —un tercio de
pantalla de patrones o de color, o los patrones de los sprites— y que encadenan
sin un solo byte de hueco desde 0x4800 hasta 0x884D.

Hay **dos juegos de gráficos**, uno para el juego y otro para la presentación,
que comparten el tercer tercio y los sprites. Las tablas están en 0xDB17 y
0xDB35, y son listas de pares (origen comprimido, destino en VRAM) terminadas en
0x0000.
