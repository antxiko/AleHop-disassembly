#!/usr/bin/env python3
"""Presupuesto del bloque del juego: ni un byte sin explicar.

Es el mismo criterio que en Temptations, pero aqui hay que sumarlo sobre los
CINCO trozos, porque el juego se ensambla en cinco listados con orgs distintos.

Por que este control y no el porcentaje de codigo: el 83% de Ale Hop! son datos,
asi que "6,7% de codigo trazado" suena a desensamblado incompleto cuando puede
estar entero. Lo que mide el avance de verdad es que cada byte sea o codigo que
el trazador alcanza, o caer dentro de un rango de datos identificado en las
notas.

Y es un control DISTINTO del de reproducibilidad: un byte puede reensamblar
perfecto y estar sin explicar, o peor, estar mal explicado.

Uso: presupuesto.py <directorio_work> <directorio_src>
"""
import json
import re
import sys

# nombre, org, tamano  (el mismo reparto que tools/split_trace.py)
TROZOS = [
    ("datos",  0x0000, 35393),
    ("sonido", 0xB000, 2201),
    ("nucleo", 0xBD00, 2112),
    ("extra",  0xD000, 2938),
    ("cola",   0xA694, 1),
]


def estado_del_trozo(work, src, nombre, org, size):
    tr = json.load(open(f"{work}/game_{nombre}.trace.json"))
    estado = [0] * size
    for kind, a, b in tr["blocks"]:
        if kind == "c":
            for i in range(max(0, a - org), min(size, b - org)):
                estado[i] = 1
    try:
        notas = open(f"{src}/game_{nombre}.notes", encoding="utf-8")
    except FileNotFoundError:
        return estado
    for ln in notas:
        m = re.match(r"^D\s+(\S+)\s+(\S+)\s+(\S+)\s*(.*)$", ln.strip())
        if m:
            a, b = int(m.group(1), 0), int(m.group(2), 0)
            for i in range(max(0, a - org), min(size, b - org)):
                if estado[i] == 0:
                    estado[i] = 2
    return estado


def main(work, src):
    total = cod = dat = sin = 0
    huecos = []
    print("PRESUPUESTO DEL BLOQUE DEL JUEGO (42645 bytes en cinco trozos)")
    print(f"  {'trozo':8s} {'bytes':>7s} {'codigo':>8s} {'datos':>8s} {'sin explicar':>13s}")
    for nombre, org, size in TROZOS:
        e = estado_del_trozo(work, src, nombre, org, size)
        c, d, s = e.count(1), e.count(2), e.count(0)
        print(f"  {nombre:8s} {size:7d} {c:8d} {d:8d} {s:13d}")
        total += size; cod += c; dat += d; sin += s
        i = 0
        while i < size:
            if e[i] == 0:
                j = i
                while j < size and e[j] == 0:
                    j += 1
                huecos.append((j - i, org + i, org + j, nombre))
                i = j
            else:
                i += 1
    print(f"  {'-'*48}")
    print(f"  {'TOTAL':8s} {total:7d} {cod:8d} {dat:8d} {sin:13d}")
    print(f"\n  explicado: {cod+dat} de {total}  ({(cod+dat)*100/total:.1f}%)")

    if sin:
        print("\nHuecos sin explicar (los mayores primero):")
        for n, a, b, nom in sorted(huecos, reverse=True)[:20]:
            print(f"  [{nom}] {a:#06x}..{b:#06x}  {n:6d} bytes")
        if len(huecos) > 20:
            print(f"  ... y {len(huecos)-20} huecos mas")
        return 1
    print("\n  CERO BYTES SIN EXPLICAR")
    return 0


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:3]))
