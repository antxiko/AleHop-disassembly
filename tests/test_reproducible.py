#!/usr/bin/env python3
"""Comprueba las garantias del proyecto, de punta a punta.

1. Reproducibilidad: cada listado vuelve a ensamblar al binario original.
2. Los cinco trozos del juego, concatenados en orden de CARGA, dan el bloque
   turbo 2 entero. Esta es propia de Ale Hop!: como el cargador recoloca tres
   trozos, cada listado se ensambla con el `org` de donde se EJECUTA, y solo
   juntandolos en el orden de la cinta se recupera el original.
3. Sanidad del trazado: los graficos no estan marcados como codigo.
4. Presupuesto: no queda ni un byte sin explicar.
5. Ida y vuelta del TSX: la cinta se entiende del todo.

La 1 y la 3 son distintas y hacen falta las dos. La reproducibilidad caza que
una instruccion se haya leido mal; no caza que unos graficos se hayan tomado por
codigo, porque en ese caso los bytes salen igual y solo cambia su interpretacion.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

# El directorio temporal del sistema: en Windows no hay /tmp.
TMP = tempfile.gettempdir()
RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))

MODULOS = [
    ("alehop_slots.asm",   "work/SLOTS.raw",        0xC350),
    ("alehop_topo.asm",    "work/TOPO.raw",         0x9470),
    ("alehop_portada.asm", "dump/turbo1_cinta.bin", 0x88B8),
]

# Los cinco trozos del juego, EN ORDEN DE CARGA. El `org` es donde se ejecuta
# cada uno despues de que el cargador lo recoloque.
TROZOS = [
    ("alehop_game_datos.asm",  "work/game_datos.bin",  0x0000),
    ("alehop_game_sonido.asm", "work/game_sonido.bin", 0xB000),
    ("alehop_game_nucleo.asm", "work/game_nucleo.bin", 0xBD00),
    ("alehop_game_extra.asm",  "work/game_extra.bin",  0xD000),
    ("alehop_game_cola.asm",   "work/game_cola.bin",   0xA694),
]

HAY_PASMO = shutil.which("pasmo") is not None
HAY_TRAZADO = os.path.exists(os.path.join(RAIZ, "work", "game64.trace.json"))
HAY_LISTADOS = all(os.path.exists(os.path.join(RAIZ, "src", m[0]))
                   for m in MODULOS + TROZOS)


def sha(path):
    return hashlib.sha256(open(path, "rb").read()).hexdigest()


def ensambla(asmname, out):
    asm = os.path.join(RAIZ, "src", asmname)
    return subprocess.run(["pasmo", "--bin", asm, out],
                          capture_output=True, text=True)


class TestReproducible(unittest.TestCase):
    """Ensamblar el listado tiene que dar el binario original, byte a byte."""

    def test_los_modulos_reensamblan_identicos(self):
        hechos = 0
        for asmname, binrel, _org in MODULOS + TROZOS:
            with self.subTest(modulo=asmname):
                out = os.path.join(TMP, f"_al_{asmname}.bin")
                r = ensambla(asmname, out)
                self.assertEqual(r.returncode, 0,
                                 f"pasmo fallo en {asmname}: {r.stderr[:300]}")
                self.assertEqual(sha(out), sha(os.path.join(RAIZ, binrel)),
                                 f"{asmname} no reproduce {binrel} byte a byte")
                hechos += 1
        self.assertEqual(hechos, len(MODULOS) + len(TROZOS))

    def test_los_trozos_concatenados_dan_el_bloque_del_juego(self):
        """La prueba que de verdad cierra el juego: cinco listados con orgs
        distintos que, puestos en el orden de la cinta, dan los 42645 bytes."""
        trozos = b""
        for asmname, _bin, _org in TROZOS:
            out = os.path.join(TMP, f"_al_{asmname}.bin")
            r = ensambla(asmname, out)
            self.assertEqual(r.returncode, 0, r.stderr[:300])
            trozos += open(out, "rb").read()
        original = open(os.path.join(RAIZ, "dump", "turbo2_cinta.bin"), "rb").read()
        self.assertEqual(len(trozos), 42645)
        self.assertEqual(hashlib.sha256(trozos).hexdigest(),
                         hashlib.sha256(original).hexdigest(),
                         "los trozos concatenados no dan el bloque turbo 2")


class TestSanidad(unittest.TestCase):
    """Las zonas que sabemos que son datos no pueden salir como codigo."""

    def test_ninguna_zona_de_datos_marcada_como_codigo(self):
        tr = json.load(open(os.path.join(RAIZ, "work", "game64.trace.json")))
        nocode = os.path.join(RAIZ, "src", "game.nocode")
        lo = min(a for _, a, _ in tr["blocks"])
        hi = max(b for _, _, b in tr["blocks"])
        cod = bytearray(hi - lo)
        for kind, a, b in tr["blocks"]:
            if kind == "c":
                for i in range(a - lo, b - lo):
                    cod[i] = 1
        zonas = 0
        for ln in open(nocode, encoding="utf-8"):
            campos = ln.split("#")[0].split()
            if len(campos) < 2:
                continue
            a, b = int(campos[0], 0), int(campos[1], 0)
            ini, fin = max(a, lo), min(b, hi)
            if fin <= ini:
                continue
            pct = sum(cod[ini - lo:fin - lo]) * 100 // (fin - ini)
            with self.subTest(zona=f"{a:#06x}-{b:#06x}"):
                self.assertLessEqual(pct, 5,
                    f"{pct}% de {a:#06x}-{b:#06x} marcado como codigo: trazado contaminado")
            zonas += 1
        self.assertGreater(zonas, 0, "no hay zonas de datos declaradas")


class TestPresupuesto(unittest.TestCase):
    """Cada byte del bloque del juego tiene que estar explicado: o es codigo que
    el trazador alcanza, o cae en un rango de datos identificado en las notas."""

    def test_no_quedan_bytes_sin_explicar(self):
        r = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "presupuesto.py"),
             os.path.join(RAIZ, "work"), os.path.join(RAIZ, "src")],
            capture_output=True, text=True)
        self.assertEqual(r.returncode, 0,
                         f"quedan bytes sin explicar:\n{r.stdout[-1500:]}")
        self.assertIn("CERO BYTES SIN EXPLICAR", r.stdout)


class TestCinta(unittest.TestCase):
    """Parsear y reconstruir la cinta debe devolver un fichero identico."""

    def test_ida_y_vuelta_del_tsx(self):
        man = os.path.join(RAIZ, "extracted", "manifest.json")
        # Por el nombre, no "el primer .tsx que haya": en la carpeta puede
        # haber cintas de otros juegos, y entonces se compararia contra otra.
        originales = [f for f in os.listdir(RAIZ)
                      if f.lower().endswith(".tsx") and "alehop" in f.lower()]
        self.assertEqual(len(originales), 1,
                         "hace falta la cinta de Alehop en la raiz")
        out = os.path.join(TMP, "_al_regen.tsx")
        r = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "tsx_build.py"),
             man, out, os.path.join(RAIZ, "extracted")],
            capture_output=True, text=True)
        self.assertEqual(r.returncode, 0, r.stderr[:300])
        self.assertEqual(sha(out), sha(os.path.join(RAIZ, originales[0])),
                         "la cinta reconstruida difiere de la original")


def load_tests(loader, tests, pattern):
    """Solo se cargan los tests cuyas condiciones se cumplen.

    No se usa skipIf a proposito: un test saltado parece un test que pasa, y no
    hay forma de distinguirlo de uno desactivado para tapar un fallo.
    """
    faltan = []
    if not HAY_PASMO:    faltan.append("pasmo (brew install pasmo)")
    if not HAY_TRAZADO:  faltan.append("el trazado (ejecuta 'make')")
    if not HAY_LISTADOS: faltan.append("los listados .asm (ejecuta 'make')")
    if faltan:
        print("[tests] no se cargan los tests de reproducibilidad; falta: "
              + ", ".join(faltan))
        return unittest.TestSuite()
    hay_tsx = any(f.lower().endswith(".tsx") for f in os.listdir(RAIZ))
    suite = unittest.TestSuite()
    for t in tests:
        for caso in t:
            if isinstance(caso, unittest.TestSuite):
                for x in caso:
                    if "ida_y_vuelta" in str(x) and not hay_tsx:
                        continue
                    suite.addTest(x)
            else:
                suite.addTest(caso)
    return suite


if __name__ == "__main__":
    unittest.main(verbosity=2)
