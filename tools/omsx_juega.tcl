# Carga la cinta REGENERADA, deja el juego arrancar y captura pantallas reales.
#
# Para que sirve: la cinta regenerada es identica byte a byte a la original, asi
# que cargarla no demuestra nada nuevo sobre el formato. Lo que si demuestra
# esto es que el JUEGO FUNCIONA, y ademas da capturas de verdad con las que
# comparar las imagenes que genera tools/render_niveles.py. Si mi lectura del
# formato de los mapas o del descompresor RLE estuviera mal, los renders y estas
# capturas no coincidirian.
#
# Al llegar a 0xC000 guarda un savestate: cargar la cinta cuesta 7 minutos
# emulados y no hace falta repetirlos para volver a mirar algo.

set TSX $::env(ALEHOP_TSX)
set OUT $::env(ALEHOP_OUT)

set LOG [open "$OUT/omsx_juega.log" w]
proc say {msg} { global LOG; puts $LOG "\[[format %8.2f [machine_info time]]\] $msg"; flush $LOG }
proc foto {nombre} {
    global OUT
    screenshot -raw $OUT/$nombre.png
    say "captura $nombre"
}

set throttle off

cassetteplayer insert $TSX
say "cinta insertada: $TSX"

debug set_bp 0xC000 {} {
    say "el juego arranca: fin de la carga"
    catch {savestate alehop_arranque}
    say "savestate guardado"

    # El modo atraccion encadena varias escenas, asi que se mira a lo largo
    # del tiempo en vez de una sola vez.
    after time  3 { foto atraccion_1 }
    after time 10 { foto atraccion_2 }
    after time 20 { foto atraccion_3 }
    after time 35 { foto atraccion_4 }
    after time 50 { foto atraccion_5 }

    # Y despues se pulsa espacio para entrar en la partida.
    after time 60 {
        say "pulsando espacio"
        keymatrixdown 8 1
    }
    after time 60.3 { keymatrixup 8 1 }
    after time 64 { foto partida_1 }
    after time 70 { foto partida_2 }
    after time 78 { foto partida_3 }
    after time 80 { say "OK"; exit 0 }
}

after time 4 {
    say "tecleando RUN\"CAS:\""
    type "RUN\"CAS:\"\r"
}

after time 900 { say "TIMEOUT: no se llego a 0xC000"; exit 1 }
