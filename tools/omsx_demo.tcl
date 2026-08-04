# Demo visible: carga la cinta RECONSTRUIDA (la que sale de nuestros .asm) para
# ver con los propios ojos que arranca igual que la original.
#
# La carga real son ~7 minutos de cinta. Se acelera x10 mientras carga y se
# vuelve a velocidad normal en cuanto el juego arranca, de modo que se ve toda
# la secuencia (logo de Topo -> portada -> juego) sin esperas.

set TSX $::env(TEMPT_TSX)

set LOG [open "/tmp/omsx_demo.log" w]
proc say {m} { global LOG; puts $LOG "\[[format %7.1f [machine_info time]]\] $m"; flush $LOG }

set speed 1000
cassetteplayer insert $TSX
say "cinta insertada (x10 mientras carga): $TSX"

debug set_bp 0x9470 {} { say "--> logo de Topo Soft" }
debug set_bp 0x88B8 {} { say "--> pantalla de portada" }
debug set_bp 0x8000 {} {
    say "--> el juego arranca: vuelvo a velocidad normal"
    set ::speed 100
}

after time 4 { type "RUN\"CAS:\"\r" }
