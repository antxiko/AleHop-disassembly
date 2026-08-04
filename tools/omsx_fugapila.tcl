# Comprueba si el game over pierde pila.
#
# El juego fija la pila una sola vez, en 0x8058 (ld sp,0x8FFF), durante el
# arranque. Pero al terminar la partida, 0x8C43 hace 'jp 08076h', que entra
# DESPUES de esa instruccion. Si al llegar al game over la pila no estaba en su
# sitio, la nueva partida arranca con SP mas bajo y el error se acumula.
#
# Se mide provocando varios game over seguidos y anotando SP en cada reinicio.

set OUT $::env(TEMPT_OUT)
set LOG [open "$OUT/fugapila.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }

set throttle off
catch {set renderer none}
if {[catch {loadstate tempt_boot} e]} { say "sin savestate: $e"; exit 1 }

proc tecla {mask ms} { keymatrixdown 8 $mask; after time $ms "keymatrixup 8 $mask" }
after time 3 { tecla 0x01 0.3 }

set ::vueltas 0
# Cada vez que la partida se reinicia por game over, anotar donde quedo la pila.
debug set_bp 0x8076 {} {
    incr ::vueltas
    say [format "reinicio %2d: SP = 0x%04X" $::vueltas [reg sp]]
    if {$::vueltas >= 8} {
        say "\nLa pila se fija UNA sola vez, en 0x8058 (ld sp,0x8FFF), y el game"
        say "over entra por 0x8076, que esta despues. Si los numeros de arriba"
        say "bajan, cada partida perdida se come un trozo de pila."
        exit 0
    }
}

# Forzar game over: poner 0 vidas y saltar a la rutina que quita una.
proc mata {} {
    debug write memory 0x8F12 0x00
    reg pc 0x84C9
    after time 4 mata
}
after time 10 mata
after time 300 { say "TIMEOUT tras $::vueltas reinicios"; exit 1 }
