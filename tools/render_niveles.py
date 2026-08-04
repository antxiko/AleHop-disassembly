#!/usr/bin/env python3
"""Dibuja los seis niveles de Ale Hop!, tal y como los ve el jugador.

Aqui no hay pantallas fijas como en Temptations: cada nivel es una TIRA de 256
columnas por 8 filas de la que solo se ven 32 columnas a la vez. Asi que se
generan dos cosas por nivel:

  tira_nivelN.png      la tira entera, 2048 x 64 px, para ver el trazado completo
  pantalla_nivelN.png  una pantalla de verdad (32x24) con las tres bandas:
                       el fondo arriba, el mapa en medio y el marcador abajo

Las tres bandas usan tercios distintos de la SCREEN 2, cada uno con su propio
juego de patrones y de colores, que es justo como funciona ese modo.

Y el fondo va con parallax: el volcado del fondo hace `and 0x3F` sobre la
columna de camara mientras que el del mapa usa los 8 bits, asi que se desplaza
cuatro veces mas despacio.

Uso: render_niveles.py <bloque_del_juego.bin> <directorio_salida>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from render_maps import PALETA, png  # noqa: E402

# Juego de graficos "A", el del juego (tabla en 0xDB17)
GFX_A = [(0x4800, 0x0000), (0x4CE2, 0x2000),   # tercio 0: fondo
         (0x5148, 0x0800), (0x58E9, 0x2800),   # tercio 1: mapa
         (0x5FEE, 0x1000), (0x66C9, 0x3000)]   # tercio 2: marcador
MAPA_MARCADOR = 0x4500


def descomprime(d, origen):
    """RLE de la rutina 0xD2BE: word LE, 0xFFFF fin, bit 15 = repeticion."""
    out = bytearray()
    i = origen
    while True:
        bc = d[i] | (d[i + 1] << 8)
        i += 2
        if bc == 0xFFFF:
            return bytes(out)
        if bc & 0x8000:
            out += bytes([d[i]]) * (bc & 0x7FFF)
            i += 1
        else:
            out += d[i:i + bc]
            i += bc


def carga_vram(d):
    v = bytearray(0x4000)
    for org, dest in GFX_A:
        v[dest:dest + 0x800] = descomprime(d, org)
    return v


def pinta_tile(img, v, tercio, tile, px, py, esc, fondo):
    pat_base = tercio * 0x800
    col_base = 0x2000 + tercio * 0x800
    for l in range(8):
        pat = v[pat_base + tile * 8 + l]
        col = v[col_base + tile * 8 + l]
        c1 = fondo if (col >> 4) == 0 else PALETA[col >> 4]
        c0 = fondo if (col & 15) == 0 else PALETA[col & 15]
        for b in range(8):
            rgb = c1 if pat & (0x80 >> b) else c0
            for sy in range(esc):
                for sx in range(esc):
                    img[(py + l) * esc + sy][(px + b) * esc + sx] = rgb


def tira(d, v, nivel, esc=1, backdrop=1):
    """El nivel entero de 256 columnas."""
    mapa = 0x0000 + nivel * 0x800
    w, h = 256 * 8 * esc, 8 * 8 * esc
    fondo = PALETA[backdrop]
    img = [[fondo] * w for _ in range(h)]
    for fila in range(8):
        for col in range(256):
            pinta_tile(img, v, 1, d[mapa + fila * 256 + col],
                       col * 8, fila * 8, esc, fondo)
    return w, h, img


def pantalla(d, v, nivel, camara=0, esc=2, backdrop=1):
    """Una pantalla completa: fondo, mapa y marcador."""
    mapa = 0x0000 + nivel * 0x800
    fnd = 0x3000 + nivel * 0x200
    w, h = 32 * 8 * esc, 24 * 8 * esc
    fondo = PALETA[backdrop]
    img = [[fondo] * w for _ in range(h)]
    for fila in range(8):                       # banda 0: el fondo, con parallax
        for col in range(32):
            t = d[fnd + fila * 64 + ((camara & 0x3F) + col) % 64]
            pinta_tile(img, v, 0, t, col * 8, fila * 8, esc, fondo)
    for fila in range(8):                       # banda 1: el mapa del nivel
        for col in range(32):
            t = d[mapa + fila * 256 + (camara + col) % 256]
            pinta_tile(img, v, 1, t, col * 8, (8 + fila) * 8, esc, fondo)
    for fila in range(8):                       # banda 2: el marcador
        for col in range(32):
            t = d[MAPA_MARCADOR + fila * 32 + col]
            pinta_tile(img, v, 2, t, col * 8, (16 + fila) * 8, esc, fondo)
    return w, h, img


def main(binpath, outdir):
    d = open(binpath, "rb").read()
    v = carga_vram(d)
    os.makedirs(outdir, exist_ok=True)
    for n in range(6):
        w, h, img = tira(d, v, n)
        png(f"{outdir}/tira_nivel{n+1}.png", w, h, img)
        w, h, img = pantalla(d, v, n, camara=0)
        png(f"{outdir}/pantalla_nivel{n+1}.png", w, h, img)
        print(f"  nivel {n+1}: tira 2048x64 y pantalla 512x384")
    print(f"12 imagenes en {outdir}/")


if __name__ == "__main__":
    main(*sys.argv[1:3])
