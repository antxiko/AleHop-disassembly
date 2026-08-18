# Empezar

## Solo leer

Los listados de `src/*.asm` están comentados y no hace falta compilar nada para
leerlos. Por dónde entrar, según lo que te interese:

| quiero ver... | mira |
|---|---|
| Cómo arranca el juego | `alehop_game_nucleo.asm`, en 0xC000 |
| El motor: física, colisión, scroll | `alehop_game_extra.asm` |
| El reproductor de música | `alehop_game_sonido.asm` |
| El cargador turbo de cinta | `alehop_slots.asm` |
| Los mapas y los gráficos | `alehop_game_datos.asm` |

## Reconstruirlo

```sh
make
```

Eso extrae la cinta, traza el código, regenera los cinco listados del juego más
los otros tres módulos, y los verifica. En verde significa cuatro cosas:

1. Cada listado vuelve a ensamblar al binario original **byte a byte**.
2. Los cinco trozos del juego, concatenados en orden de carga, dan el bloque
   turbo entero.
3. Ninguna zona de datos se ha colado como código.
4. **No queda ni un byte sin explicar** de los 42645.

Y luego pasan los 36 tests.

Hace falta:

- `python3`
- `pasmo` — para ensamblar (`brew install pasmo`)
- `z80dasm` — para desensamblar
- `openmsx` — solo para la parte de emulador

**La cinta `.tsx` no se distribuye** con el repositorio. Sin ella, `make` avisa
de lo que no puede hacer en vez de fingir que ha ido bien.

## Las imágenes

```sh
make imagenes
```

Dibuja los seis niveles a partir de los datos del juego: la tira completa de
cada uno (2048x64) y una pantalla de verdad con sus tres bandas. No son
capturas: se generan descomprimiendo los gráficos y montando los mapas, que es
la mejor prueba de que el formato está bien entendido.

## El emulador

```sh
ALEHOP_TSX="$PWD/alehop.tsx" ALEHOP_OUT="$PWD/dump" \
  openmsx -machine Philips_VG_8020-20 -script tools/omsx_load.tcl
```

Carga la cinta original usando **el propio cargador del juego como
decodificador** y vuelca la RAM en cada etapa. Es lo que produce
`dump/full_recolocado.bin`, la imagen de 64 KB sobre la que se traza el código:
las direcciones solo significan algo cuando el juego ya está recolocado en
memoria.

Para verlo jugar y hacer capturas:

```sh
ALEHOP_TSX="$PWD/build/alehop_rebuild.tsx" ALEHOP_OUT="$PWD/build/capturas" \
  openmsx -machine Philips_VG_8020-20 -script tools/omsx_juega.tcl
```

Tarda unos siete minutos de tiempo emulado en cargar, igual que en 1988.

## Modificar el juego

Los comentarios van en `src/*.notes`, anclados a dirección para que sobrevivan a
que se vuelva a trazar todo; los `.asm` se generan a partir de ahí, así que un
comentario escrito en un `.asm` se pierde en el siguiente trazado.

Para tocar el código en sí, edita el `.asm` y luego:

```sh
python3 tools/build_tape.py build build/mi_alehop.tsx
```

Eso ensambla, reconstruye los bloques con sus cabeceras y checksums, y produce
una cinta cargable. Mientras `make` siga en verde antes de tocar nada, cualquier
cambio de comportamiento se puede atribuir a lo que hayas cambiado y no a un
error de lectura del binario.
