#!/usr/bin/env python3
"""Inventario de lo identificado: todas las rutinas y rangos de datos con nombre.

Lo saca de src/game.notes, que es la fuente de verdad de las anotaciones, para
que el inventario no se quede desfasado respecto al codigo comentado.

Uso: inventario.py <notes> [trace.json]
"""
import json
import re
import sys


def main(notespath, tracepath=None):
    labels, datos = {}, []
    for ln in open(notespath, encoding="utf-8"):
        ln = ln.rstrip()
        m = re.match(r"^L\s+(\S+)\s+(\S+)\s*(.*)$", ln)
        if m:
            labels[int(m.group(1), 0)] = (m.group(2), m.group(3).strip())
            continue
        m = re.match(r"^D\s+(\S+)\s+(\S+)\s+(\S+)\s*(.*)$", ln)
        if m:
            datos.append((int(m.group(1), 0), int(m.group(2), 0),
                          m.group(3), m.group(4).strip()))

    # Nombres que el generador pone por defecto: no son identificaciones reales.
    reales = {a: v for a, v in labels.items() if not v[0].startswith("L_")}

    print("=" * 78)
    print(f" RUTINAS IDENTIFICADAS: {len(reales)}")
    print("=" * 78)
    for a in sorted(reales):
        nom, desc = reales[a]
        print(f"  {a:#06x}  {nom:<22s} {desc[:46]}")

    datos.sort()
    print()
    print("=" * 78)
    print(f" RANGOS DE DATOS IDENTIFICADOS: {len(datos)}")
    print("=" * 78)
    for a, b, nom, desc in datos:
        print(f"  {a:#06x}..{b:#06x} {b-a:6d} B  {nom:<22s} {desc[:34]}")

    if tracepath:
        tr = json.load(open(tracepath))
        ncod = sum(b - a for k, a, b in tr["blocks"] if k == "c")
        print()
        print(f"  codigo trazado: {ncod} bytes en "
              f"{sum(1 for k,_,_ in tr['blocks'] if k=='c')} regiones")


if __name__ == "__main__":
    main(*sys.argv[1:3])
