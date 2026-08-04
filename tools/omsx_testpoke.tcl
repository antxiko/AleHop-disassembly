# Prueba experimental del POKE de vidas infinitas.
#
# El cargador publicado en "MSX Book II" (Brasil, 1988, pag. 62) dice
# POKE &HB4CC,0, pero en el binario 0xB4CC ya vale 0 (no haria nada) mientras
# que 0x84CC contiene 0x3D = DEC A, dentro de la rutina que quita una vida:
#
#     84C9: LD   A,(8F12)   ; vidas
#     84CC: DEC  A          ; <-- ponerlo a 0 (NOP) = vidas infinitas
#     84CD: CP   0FFh
#     84CF: JP   Z,8C1E     ; game over
#     84D2: LD   (8F12),A
#
# En lugar de intentar morir en el juego -que no se puede automatizar de forma
# fiable- se fuerza la ejecucion de esa rutina poniendo el PC en 0x84C9 y se
# mira si el contador de vidas baja. Con TEMPT_POKE=1 se aplica antes el parche.

set OUT  $::env(TEMPT_OUT)
set TAG  $::env(TEMPT_TAG)
set POKE [expr {[info exists ::env(TEMPT_POKE)] ? $::env(TEMPT_POKE) : 0}]

set LOG [open "$OUT/$TAG.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }

set throttle off
catch {set renderer none}
if {[catch {loadstate tempt_boot} e]} { say "sin savestate: $e"; exit 1 }

proc pulsa {row bit} { keymatrixdown $row $bit; after time 0.3 "keymatrixup $row $bit" }
for {set t 3} {$t < 18} {incr t 4} { after time $t { pulsa 8 1 } }

after time 20 {
    say "parche aplicado: [expr {$POKE ? {SI (0x84CC <- 0x00, NOP)} : {NO (binario original)}}]"
    say [format "0x84CC contiene %#04x" [debug read memory 0x84CC]]
    if {$POKE} { debug write memory 0x84CC 0x00 }
    say [format "0x84CC tras el parche: %#04x" [debug read memory 0x84CC]]

    set antes [debug read memory 0x8F12]
    say [format "VIDAS antes  = %d" $antes]

    # Ejecutar a mano la rutina de "quitar una vida"
    debug set_bp 0x84D5 {} {
        set despues [debug read memory 0x8F12]
        say [format "VIDAS despues = %d" $despues]
        if {$despues == $::antes} {
            say "RESULTADO: la vida NO se ha perdido -> vidas infinitas"
        } else {
            say "RESULTADO: la vida se ha perdido (comportamiento normal)"
        }
        exit 0
    }
    set ::antes $antes
    reg pc 0x84C9
    say "PC forzado a 0x84C9 (entrada de la rutina que quita una vida)"
}
after time 60 { say "TIMEOUT: no se llego a 0x84D5"; exit 1 }
