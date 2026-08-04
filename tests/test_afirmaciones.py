#!/usr/bin/env python3
"""Comprueba que lo que afirma la documentacion sigue siendo cierto.

Un proyecto como este publica muchas afirmaciones sobre un binario: que tal
direccion contiene tal instruccion, que la tabla de saltos tiene 12 entradas,
que el juego se carga en 0x0000. Todas son comprobables, asi que deben
comprobarse solas: si algun dia alguien cambia una nota o el binario, esto salta.

Si el binario del juego no esta disponible (no se distribuye con el
repositorio), estos tests directamente no se cargan y se avisa por pantalla. Los
de tests/test_z80.py no dependen de el y se ejecutan siempre.

OJO con las direcciones: el bloque del juego se carga en 0x0000 pero tres trozos
se recolocan antes de ejecutarse. Aqui se trabaja sobre el fichero de la CINTA,
asi que toda direccion de ejecucion pasa por `off()` para convertirla en offset.
"""
import hashlib
import os
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

CINTA_JUEGO   = os.path.join(RAIZ, "dump", "turbo2_cinta.bin")
CINTA_PORTADA = os.path.join(RAIZ, "dump", "turbo1_cinta.bin")
SLOTS         = os.path.join(RAIZ, "work", "SLOTS.raw")
TOPO          = os.path.join(RAIZ, "work", "TOPO.raw")

# Los trozos del juego: (ejecuta_desde, ejecuta_hasta, offset en la cinta)
RECOLOCA = [
    (0x0000, 0x8A40, 0x0000),
    (0xB000, 0xB898, 0x8A41),
    (0xBD00, 0xC53F, 0x92DA),
    (0xD000, 0xDB79, 0x9B1A),
]


def off(dir_ejecucion):
    """Direccion de ejecucion -> offset dentro del bloque de la cinta."""
    for lo, hi, base in RECOLOCA:
        if lo <= dir_ejecucion <= hi:
            return dir_ejecucion - lo + base
    raise AssertionError(f"{dir_ejecucion:#06x} no cae en ningun trozo del juego")


def leer(path):
    return open(path, "rb").read()


def en(d, dir_ejecucion, n):
    i = off(dir_ejecucion)
    return d[i:i + n]


class TestCadenaDeCarga(unittest.TestCase):
    """La cadena de carga, tal y como la cuenta la documentacion."""

    def setUp(self):
        self.s = leer(SLOTS)          # SLOTS ensambla en 0xC350

    def sl(self, dir_, n):
        return self.s[dir_ - 0xC350:dir_ - 0xC350 + n]

    def test_slots_se_copia_a_si_mismo_y_salta(self):
        # ld hl,0xC5BB / ld de,0xE09C / ld bc,0x0085 / ldir / jp ...
        self.assertEqual(self.sl(0xC5AD, 12),
                         bytes([0x21, 0xBB, 0xC5, 0x11, 0x9C, 0xE0,
                                0x01, 0x85, 0x00, 0xED, 0xB0, 0xC3]))

    def test_el_bloque_1_se_carga_y_ejecuta_en_88B8(self):
        # ld ix,0x88B8 ; ld de,0x3064 (12388 bytes)
        self.assertEqual(self.sl(0xC5BE, 4), bytes([0xDD, 0x21, 0xB8, 0x88]))
        self.assertEqual(self.sl(0xC5C2, 3), bytes([0x11, 0x64, 0x30]))
        self.assertEqual(len(leer(CINTA_PORTADA)), 0x3064)
        # y luego se EJECUTA: call 0x88B8
        self.assertEqual(self.sl(0xC5CA, 3), bytes([0xCD, 0xB8, 0x88]))

    def test_el_juego_se_carga_en_la_pagina_0(self):
        """Lo que mas diferencia a Ale Hop! de Temptations: el juego va a 0x0000,
        no a 0x4000, o sea que la ROM del BASIC deja de estar mapeada."""
        # ld ix,0x0000 ; ld de,0xA695 (42645 bytes)
        self.assertEqual(self.sl(0xC5D3, 4), bytes([0xDD, 0x21, 0x00, 0x00]))
        self.assertEqual(self.sl(0xC5D7, 3), bytes([0x11, 0x95, 0xA6]))
        self.assertEqual(len(leer(CINTA_JUEGO)), 0xA695)

    def test_las_tres_recolocaciones(self):
        """SLOTS mueve tres trozos con LDIR antes de arrancar el juego."""
        esperado = [(0xC5DF, 0x8A41, 0xB000, 0x0899),
                    (0xC5EA, 0x92DA, 0xBD00, 0x0840),
                    (0xC5F5, 0x9B1A, 0xD000, 0x0B7A)]
        for dir_, origen, destino, n in esperado:
            with self.subTest(destino=hex(destino)):
                # ld hl,origen / ld de,destino / ld bc,n / ldir
                self.assertEqual(self.sl(dir_, 11), bytes([
                    0x21, origen & 0xFF, origen >> 8,
                    0x11, destino & 0xFF, destino >> 8,
                    0x01, n & 0xFF, n >> 8, 0xED, 0xB0]))
        # y los rangos que usa este fichero tienen que cuadrar con esos LDIR
        for (lo, hi, base), (_, origen, destino, n) in zip(RECOLOCA[1:], esperado):
            self.assertEqual((lo, hi, base), (destino, destino + n - 1, origen))

    def test_el_juego_arranca_en_C000(self):
        self.assertEqual(self.sl(0xC63D, 3), bytes([0xC3, 0x00, 0xC0]))


class TestBloquesTurbo(unittest.TestCase):
    """Formato del bloque turbo de Topo Soft."""

    def test_el_xor_de_cada_bloque_da_cero(self):
        """Un byte 0x00 de sincronismo, los datos, y un byte de checksum XOR
        elegido para que el XOR de todo el bloque sea 0."""
        for nombre in ("10_raw_10.bin", "11_raw_10.bin"):
            with self.subTest(bloque=nombre):
                d = leer(os.path.join(RAIZ, "extracted", nombre))
                self.assertEqual(d[0], 0x00, "falta el byte de sincronismo")
                x = 0
                for b in d:
                    x ^= b
                self.assertEqual(x, 0, "el checksum XOR no cuadra")


class TestPortada(unittest.TestCase):
    """El bloque turbo 1 son 34 bytes de codigo y una imagen de SCREEN 2."""

    def setUp(self):
        self.d = leer(CINTA_PORTADA)      # ensambla en 0x88B8

    def po(self, dir_, n):
        return self.d[dir_ - 0x88B8:dir_ - 0x88B8 + n]

    def test_vuelca_patrones_y_colores_a_la_vram(self):
        # ld hl,0x891C / ld de,0x0000 / ld bc,0x1800 / call 0x005C (LDIRVM)
        self.assertEqual(self.po(0x88BC, 12),
                         bytes([0x21, 0x1C, 0x89, 0x11, 0x00, 0x00,
                                0x01, 0x00, 0x18, 0xCD, 0x5C, 0x00]))
        # ld hl,0xA11C / ld de,0x2000 / ld bc,0x1800 / call 0x005C
        self.assertEqual(self.po(0x88C9, 12),
                         bytes([0x21, 0x1C, 0xA1, 0x11, 0x00, 0x20,
                                0x01, 0x00, 0x18, 0xCD, 0x5C, 0x00]))

    def test_los_dos_bloques_de_imagen_encajan_justo(self):
        """0x891C + 0x1800 = 0xA11C, y ahi caben otros 0x1800 hasta el final."""
        self.assertEqual(0x891C + 0x1800, 0xA11C)
        self.assertEqual(0xA11C + 0x1800 - 0x88B8, len(self.d))


class TestSonido(unittest.TestCase):
    """El reproductor de sonido, heredado de Temptations pero retocado."""

    def setUp(self):
        self.d = leer(CINTA_JUEGO)

    def test_el_byte_de_melodia_por_encima_de_0x80_es_un_comando(self):
        # ld a,(bc) / cp 0x80 / jp c,0xB072 / sub 0x80 / ld hl,0xB486
        self.assertEqual(en(self.d, 0xB063, 11),
                         bytes([0x0A, 0xFE, 0x80, 0xDA, 0x72, 0xB0,
                                0xD6, 0x80, 0x21, 0x86, 0xB4]))
        # call 0xB3A4 (indexa la tabla) / jp (hl)
        self.assertEqual(en(self.d, 0xB06E, 4), bytes([0xCD, 0xA4, 0xB3, 0xE9]))

    def test_la_tabla_de_saltos_tiene_12_comandos(self):
        """Temptations tenia 15. Los 12 primeros destinos caen dentro del
        reproductor; el 13o apuntaria fuera, que es donde acaba la tabla."""
        dentro = 0
        for i in range(16):
            b = en(self.d, 0xB486 + i * 2, 2)
            destino = b[0] | (b[1] << 8)
            if 0xB000 <= destino <= 0xB898:
                dentro += 1
            else:
                break
        self.assertEqual(dentro, 12)

    def test_vuelca_11_registros_del_psg_desde_un_buffer(self):
        # ld hl,0xB4A0 / ld a,0 / ld d,11 / push af ... out (0xA0),a / out (0xA1),a
        self.assertEqual(en(self.d, 0xB3B1, 8),
                         bytes([0x21, 0xA0, 0xB4, 0x3E, 0x00, 0x16, 0x0B, 0xF5]))
        self.assertEqual(en(self.d, 0xB3BA, 2), bytes([0xD3, 0xA0]))
        self.assertEqual(en(self.d, 0xB3BD, 2), bytes([0xD3, 0xA1]))


class TestArranqueDelJuego(unittest.TestCase):
    """Lo que hace el juego nada mas coger el control en 0xC000."""

    def setUp(self):
        self.d = leer(CINTA_JUEGO)

    def test_engancha_su_rutina_en_el_hook_de_interrupcion(self):
        """ld hl,0xC105 / ld (0xFDA0),hl / ld a,0xC3 / ld (0xFD9F),a
        H.TIMI (0xFD9F) es el hook que el BIOS llama en cada interrupcion de
        video, o sea que 0xC105 corre 50 o 60 veces por segundo."""
        self.assertEqual(en(self.d, 0xC04B, 11),
                         bytes([0x21, 0x05, 0xC1, 0x22, 0xA0, 0xFD,
                                0x3E, 0xC3, 0x32, 0x9F, 0xFD]))

    def test_pone_la_pila_antes_que_nada(self):
        # ld sp,0xF37F
        self.assertEqual(en(self.d, 0xC000, 3), bytes([0x31, 0x7F, 0xF3]))

    def test_la_tabla_de_nombres_se_vuelca_desde_0xBD00(self):
        """ld hl,0xBD00 / ld de,0x1800 / ld bc,0x0300 / call 0x005C: 768 bytes
        a la tabla de nombres de la VRAM. Por eso 0xBD00..0xBFFF son datos."""
        self.assertEqual(en(self.d, 0xC05F, 12),
                         bytes([0x21, 0x00, 0xBD, 0x11, 0x00, 0x18,
                                0x01, 0x00, 0x03, 0xCD, 0x5C, 0x00]))


class TestTopo(unittest.TestCase):
    """TOPO es exactamente el mismo binario que el de Temptations."""

    def test_topo_es_identico_al_de_temptations(self):
        d = leer(TOPO)
        self.assertEqual(len(d), 4254)
        self.assertEqual(
            hashlib.sha256(d).hexdigest(),
            "695cd61a49eb87570f1404c47821d69c2997c5d845f7c48371a46a472b89932d",
            "el TOPO de Ale Hop! ya no es identico al de Temptations")


def load_tests(loader, tests, pattern):
    """Sin los binarios extraidos estos tests no se cargan. No se usa skipIf a
    proposito: un test saltado parece un test que pasa."""
    faltan = [p for p in (CINTA_JUEGO, CINTA_PORTADA, SLOTS, TOPO)
              if not os.path.exists(p)]
    if faltan:
        print("[tests] no se cargan los tests de afirmaciones; falta extraer la "
              "cinta (ejecuta 'make extract')")
        return unittest.TestSuite()
    return tests


if __name__ == "__main__":
    unittest.main(verbosity=2)
