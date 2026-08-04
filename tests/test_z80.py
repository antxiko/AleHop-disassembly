#!/usr/bin/env python3
"""Comprueba que el decodificador de instrucciones Z80 mide bien.

Es la pieza de la que depende todo lo demas: si una instruccion se mide con la
longitud equivocada, el trazador se desalinea y a partir de ahi el desensamblado
entero es basura. Los casos de abajo cubren precisamente donde es facil fallar:
los prefijos DD/FD (que anaden un byte de desplazamiento solo en algunos
opcodes), los ED de cuatro bytes, y los prefijos encadenados.
"""
import os
import sys
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))
from z80trace import Tracer  # noqa: E402


def largo(bytes_):
    """Longitud que el decodificador asigna a la instruccion de bytes_."""
    return Tracer(bytes(bytes_) + b"\x00" * 8, 0).ilen(0)


class TestLongitudes(unittest.TestCase):
    def test_instrucciones_de_un_byte(self):
        for op in (0x00, 0x76, 0x7F, 0xC9, 0xE9, 0xF3, 0xFB):
            self.assertEqual(largo([op]), 1, f"opcode {op:#04x}")

    def test_inmediato_de_un_byte(self):
        for op in (0x06, 0x3E, 0x18, 0x20, 0xC6, 0xFE, 0xD3, 0xDB):
            self.assertEqual(largo([op, 0x12]), 2, f"opcode {op:#04x}")

    def test_inmediato_de_dos_bytes(self):
        for op in (0x01, 0x21, 0x31, 0x22, 0x3A, 0xC3, 0xCD, 0xCA):
            self.assertEqual(largo([op, 0x34, 0x12]), 3, f"opcode {op:#04x}")

    def test_prefijo_cb_siempre_dos(self):
        self.assertEqual(largo([0xCB, 0x00]), 2)
        self.assertEqual(largo([0xCB, 0xFF]), 2)

    def test_prefijo_ed_normal_son_dos(self):
        for op2 in (0xB0, 0x44, 0x5F, 0x45, 0x4D):
            self.assertEqual(largo([0xED, op2]), 2, f"ED {op2:#04x}")

    def test_prefijo_ed_con_direccion_son_cuatro(self):
        # ED 43 nn nn = ld (nnnn),bc y sus hermanos
        for op2 in (0x43, 0x53, 0x63, 0x73, 0x4B, 0x5B, 0x6B, 0x7B):
            self.assertEqual(largo([0xED, op2, 0x34, 0x12]), 4, f"ED {op2:#04x}")

    def test_indice_sin_desplazamiento(self):
        # DD 21 nn nn = ld ix,nnnn -> 4 bytes
        self.assertEqual(largo([0xDD, 0x21, 0x34, 0x12]), 4)
        # DD E9 = jp (ix) -> 2 bytes
        self.assertEqual(largo([0xDD, 0xE9]), 2)

    def test_indice_con_desplazamiento(self):
        # DD 7E dd = ld a,(ix+d) -> 3 bytes: el desplazamiento cuenta
        self.assertEqual(largo([0xDD, 0x7E, 0x05]), 3)
        # DD 36 dd nn = ld (ix+d),n -> 4 bytes
        self.assertEqual(largo([0xDD, 0x36, 0x05, 0x99]), 4)
        # DD 86 dd = add a,(ix+d) -> 3 bytes
        self.assertEqual(largo([0xDD, 0x86, 0x05]), 3)

    def test_indice_con_bit(self):
        # DD CB dd op = 4 bytes siempre
        self.assertEqual(largo([0xDD, 0xCB, 0x05, 0x46]), 4)
        self.assertEqual(largo([0xFD, 0xCB, 0x05, 0xC6]), 4)

    def test_prefijo_repetido_cuenta_uno(self):
        # DD DD ... : el primero se descarta, ocupa 1 byte
        self.assertEqual(largo([0xDD, 0xDD, 0x21, 0x34, 0x12]), 1)

    def test_fuera_del_binario_devuelve_cero(self):
        t = Tracer(b"\x21", 0)          # ld hl,nnnn incompleto
        self.assertEqual(t.ilen(0), 0)


class TestFlujo(unittest.TestCase):
    def test_halt_no_corta_el_flujo(self):
        """HALT espera a la interrupcion y sigue: tratarlo como fin de rutina
        dejaba el trazado en el 2% de cobertura."""
        # halt ; ld a,1 ; ret
        t = Tracer(bytes([0x76, 0x3E, 0x01, 0xC9]), 0)
        t.trace([0])
        self.assertEqual(list(t.mark), [1, 1, 1, 1],
                         "el codigo despues del HALT debe quedar trazado")

    def test_ret_corta_el_flujo(self):
        # ret ; ld a,1  -> lo de despues del ret NO se alcanza
        t = Tracer(bytes([0xC9, 0x3E, 0x01]), 0)
        t.trace([0])
        self.assertEqual(list(t.mark), [1, 0, 0])

    def test_sigue_las_llamadas(self):
        # 0: call 4 ; 3: ret ; 4: ret
        t = Tracer(bytes([0xCD, 0x04, 0x00, 0xC9, 0xC9]), 0)
        t.trace([0])
        self.assertEqual(t.mark[4], 1, "el destino del CALL debe trazarse")

    def test_no_entra_en_zona_de_datos(self):
        """Una sola semilla mal deducida no debe poder meter al trazador en los
        graficos: es lo que produjo una cobertura falsa del 80%."""
        # 0: jp 4 ; 4: seria codigo, pero 4..7 esta declarado como datos
        datos = bytes([0xC3, 0x04, 0x00, 0x00, 0x3E, 0x01, 0xC9, 0x00])
        t = Tracer(datos, 0, nocode=[(4, 8)])
        t.trace([0])
        self.assertEqual(sum(t.mark[4:8]), 0, "no debe trazar dentro de la zona de datos")

    def test_avisa_de_los_saltos_indirectos(self):
        # jp (hl): no se puede seguir sin ejecutar, debe quedar registrado
        t = Tracer(bytes([0xE9]), 0)
        t.trace([0])
        self.assertEqual(len(t.blind), 1)


if __name__ == "__main__":
    unittest.main(verbosity=2)
