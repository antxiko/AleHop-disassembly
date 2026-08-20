# El juego

*Ale Hop!* es un juego de **carreras de obstáculos**. Llevas una bola sonriente
por seis pistas de scroll horizontal, saltando lo que se te ponga por delante y
recogiendo cosas, con el tiempo en contra.

![Nivel 1](../niveles/pantalla_nivel1.png)

Los créditos salen de la propia pantalla de presentación, reconstruida
descomprimiendo los gráficos del binario:

> **PROGRAMA:** ALBERTO L. NAVARRO
> **GRÁFICOS:** LUIGILOPEZ
> TOPO SOFT 1988

## Cómo está montada la pantalla

Las tres bandas horizontales no son un capricho de diseño: son las tres que
regala el modo **SCREEN 2** del MSX. Ese modo parte la pantalla en tres tercios
de 8 filas y le da a cada uno su propio juego de patrones y de colores, lo que
permite tener 768 dibujos distintos en pantalla en vez de 256.

| filas | qué va ahí | de dónde sale |
|---|---|---|
| 0-7 | El fondo, que se repite cuatro veces | mapa de 64x8 en `0x3000 + nivel*0x200` |
| 8-15 | La pista jugable | mapa de 256x8 en `nivel*0x800` |
| 16-23 | El marcador | mapa fijo de 32x8 en `0x4500` |

## El fondo no lleva parallax, aunque lo parezca

Las dos rutinas de volcado leen la misma variable —la columna de cámara, en
0xDB54— pero la de la pista usa el byte entero, con su mapa de **256**
columnas, y la del fondo hace `and 0x3F` sobre ella, con un mapa de **64**.

Es tentador leer ahí un parallax, y así estuvo contado en esta página. Pero
**una máscara no frena nada**: la columna sube de uno en uno para los dos, así
que el fondo avanza al mismo ritmo que la pista. Lo que hace el `and 0x3F` es
darle la vuelta al llegar a 64, o sea que el mismo fondo se repite **cuatro
veces por nivel**. Para ir cuatro veces más despacio haría falta un
desplazamiento —`rrca` dos veces—, no un `and`.

## Los seis niveles

Cada nivel es una tira de 256 columnas de las que solo se ven 32 a la vez.
Puestas enteras, así es el nivel 1:

![Tira del nivel 1](../niveles/tira_nivel1.png)

De cada byte del mapa, los **6 bits bajos** dicen cómo se comporta la casilla y
los **2 altos** cuál de los cuatro bancos gráficos usa. Por eso cada nivel
parece de otro juego aunque el motor sea el mismo: cambia el banco, no el
código.

Las clases de terreno son 15, y salen de comparar los 6 bits bajos contra una
tabla de umbrales de 0xDACE:

```
0C 10 14 18 19 1A 20 22 24 26 28 32 38 3E FF
```

Nueve de esas clases tienen consecuencia: hay casillas que te frenan de golpe
(la cámara retrocede 40 columnas), objetos que suman 375 al marcador y
desaparecen al tocarlos, otras que suman tiempo, una que te da una vida más
—hasta un máximo de 4— y las que te matan.

## Los controles

- **Izquierda y derecha** no te mueven: cambian la **velocidad**, que va de 0 a
  38 y se guarda en 0xDB60. Es un juego de carreras, no de plataformas.
- **Arriba y abajo** te desplazan en diagonal por la pista.
- **Espacio o disparo** salta.

Lo lee con `GTSTCK`, mirando primero las teclas de cursor y luego el joystick 1,
así que valen los dos a la vez.

## El protagonista

La bola es un **sprite multicolor** en una máquina que no los tiene. El MSX1
solo permite un color por sprite, así que el juego superpone **tres sprites**
—uno por color: negro, blanco y amarillo claro— en la misma posición. Los tres
se montan en cada fotograma leyendo su color de 0xDB6E.

La misma técnica se usa en la pantalla de título con la bola que rebota.

## El marcador

Siete dígitos de puntuación, la cara del protagonista y un contador de tiempo.
El panel es un mapa fijo que se vuelca una vez al empezar la fase, y los dígitos
se escriben encima.

## Y si te lo terminas

Al pasar el nivel 6 aparece una pantalla con un mensaje que hace scroll:

![El mensaje final](../mensaje-final.png)

> ENHORABUENA!!! HAS CONSEGUIDO SUPERAR LOS OBSTACULOS QUE TE SEPARABAN DE LA
> VICTORIA... TOPO SOFT TE FELICITA. PERO... **PODRAS CON TEMPTATION??**

El texto no está dibujado en la pantalla: se escribe en marcha, letra a letra,
con una rutina de scroll suave. Y la despedida es un anuncio de otro juego que
Topo Soft había sacado el año anterior.
