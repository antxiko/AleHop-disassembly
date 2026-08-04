# La cinta

*Ale Hop!* se distribuyó en cassette. El fichero preservado es un **TSX**, un
formato pensado para MSX que guarda los bloques de la cinta ya desmodulados, no
el audio: los bytes se leen exactamente, sin margen de error de conversión.

Son 60680 bytes en 12 bloques. Tres son metadatos, uno es el catálogo, y los
ocho restantes contienen el juego.

## Lo que trae

| bloque | qué es | tamaño |
|---|---|---|
| 4-5 | `ALEHOP` — el cargador BASIC, en texto | 256 B |
| 6-7 | `TOPO` — el logo de Topo Soft | 4254 B |
| 8-9 | `SLOTS` — buscador de RAM y cargador turbo | 753 B |
| 10 | Bloque turbo 1: la pantalla de portada | 12388 B |
| 11 | Bloque turbo 2: **el juego entero** | 42645 B |

Los tres primeros ficheros viajan en bloques **KCS**, el formato estándar del
MSX: lento y con cabecera. Los dos últimos son **bloques turbo**, que es donde
Topo Soft se salía de lo normal.

## El formato turbo

Un bloque turbo es sencillísimo una vez que se sabe:

```
[0x00] [ ......... datos ......... ] [checksum]
```

Un byte de sincronismo a cero, los datos, y un byte de checksum elegido para que
el **XOR de todo el bloque dé cero**. Está comprobado sobre los dos bloques, y
es un test del proyecto.

Lo que lo hace rápido no es el formato sino cómo se lee: el cargador de SLOTS no
usa la rutina de cassette del BIOS, sino que mide a mano la anchura de los
pulsos leyendo el bit 7 del puerto 0xA2. Así puede apurar mucho más la
velocidad.

## La cadena de carga

Al teclear `RUN"CAS:"` se pone en marcha una secuencia de cinco etapas.
Verificada en el emulador con un breakpoint en cada una: se alcanzan todas, en
orden, en 435 segundos de tiempo emulado (los siete minutos largos de cinta que
recordará cualquiera que jugase en la época).

```
0x9470  TOPO      El logo de Topo Soft mientras carga el resto
0xC58F  SLOTS     Busca RAM en todos los slots y se recoloca a sí mismo
0x88B8  turbo 1   Carga la portada y la ejecuta: se vuelca a la VRAM y vuelve
0x0000  turbo 2   Carga el juego entero... en la página 0
        Recoloca tres trozos a RAM alta y parchea seis vectores
0xC000  El juego arranca
```

## Lo raro: cargar encima de la ROM

Un MSX de 64 KB no tiene 64 KB a mano. La memoria se ve por ventanas de 16 KB
llamadas páginas, y la de abajo —la página 0, de 0x0000 a 0x3FFF— la ocupa
normalmente la ROM del BIOS. La RAM está debajo, pero tapada.

Lo habitual en un juego de cinta es no meterse ahí y cargar a partir de 0x4000.
*Ale Hop!* hace lo contrario: mete los 42645 bytes **en la página 0**, encima de
donde está el BIOS. Para poder hacerlo tiene que localizar primero esa RAM y
saber conmutarla, que es justo el trabajo del buscador de SLOTS: prueba los 4
slots primarios por 4 secundarios escribiendo y releyendo, y anota **dos**
configuraciones de memoria, la normal y la de todo-RAM, para poder alternar
entre ellas durante la partida.

Una vez cargado, mueve tres trozos con `LDIR`:

| de (carga) | a (ejecución) | bytes | qué es |
|---|---|---|---|
| 0x8A41 | 0xB000 | 2201 | El reproductor de sonido |
| 0x92DA | 0xBD00 | 2112 | El núcleo y la pantalla de título |
| 0x9B1A | 0xD000 | 2938 | El motor del juego |

Y lo que queda abajo —35393 bytes de gráficos y mapas— **se vuelve a tapar con
la ROM**. El juego corre con el BIOS puesto, para poder llamarlo, y solo destapa
la RAM de debajo un instante cada vez que carga un nivel, entre un
`call 0xF00F` y un `call 0xF000`.

Esa es la razón de que el desensamblado no sea un listado sino cinco: cada trozo
se ensambla con el `org` de donde se ejecuta de verdad, y concatenados en el
orden de la cinta dan el bloque original byte a byte.

## Ida y vuelta

El formato está entendido del todo, y hay dos pruebas:

1. `tools/tsx_parse.py` + `tools/tsx_build.py` desmontan y vuelven a montar el
   TSX con el **mismo sha256**. No queda ni un byte del contenedor sin
   interpretar.
2. `tools/build_tape.py` ensambla los `.asm` comentados, reconstruye los bloques
   con sus cabeceras y checksums, y produce una cinta **idéntica a la original**
   (`499d74c7...`). Esa cinta carga en openMSX y el juego funciona.

Lo segundo es lo que hace útil el desensamblado: si se cambia algo en el código,
se puede volver a una cinta que arranca.
