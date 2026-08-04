# Fuerza la pantalla final del juego para poder verla, con y sin la trampa
# anti-tramposos activada.
#
# La trampa vive en 0x8B80: si la variable 0x8F1E no vale cero, escribe
# "POR QUE NO PRUEBAS SIN POKES" encima de la ultima linea de la pantalla de
# victoria. En el juego original NADIE enciende esa bandera, asi que la unica
# forma de ver el castigo es encenderla a mano.
#
# TEMPT_CHEAT=1 la enciende; con 0 se captura el final limpio para comparar.

set OUT   $::env(TEMPT_OUT)
set TAG   $::env(TEMPT_TAG)
set CHEAT [expr {[info exists ::env(TEMPT_CHEAT)] ? $::env(TEMPT_CHEAT) : 0}]

set LOG [open "$OUT/$TAG.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }

set throttle off
catch {set renderer none}
if {[catch {loadstate tempt_boot} e]} { say "sin savestate: $e"; exit 1 }

proc tecla {mask ms} { keymatrixdown 8 $mask; after time $ms "keymatrixup 8 $mask" }
after time 3 { tecla 0x01 0.3 }   ;# salir del menu y empezar partida

after time 12 {
    if {$CHEAT} {
        debug write memory 0x8F1E 0x01
        say "bandera de tramposo 0x8F1E <- 0x01"
    } else {
        say "bandera de tramposo 0x8F1E = [debug read memory 0x8F1E] (sin tocar)"
    }
    # Colocarse en la ultima pantalla del juego y saltar a la rutina del final.
    debug write memory 0x8F0D 27
    say "pantalla <- 27 (la ultima del nivel 4)"
    reg pc 0x8B6D
    say "PC forzado a FINAL_JUEGO (0x8B6D)"
}

# Dar tiempo a que pinte la pantalla de victoria y, si toca, el reproche encima.
after time 16 {
    say "PC=[format 0x%04X [reg pc]]  pantalla=[debug read memory 0x8F0D]"
    set f [open "$OUT/$TAG.vram" w]; fconfigure $f -translation binary
    puts -nonewline $f [debug read_block VRAM 0x0000 0x4000]; close $f
    say "volcado $TAG.vram"
    exit 0
}
after time 90 { say "TIMEOUT"; exit 1 }
