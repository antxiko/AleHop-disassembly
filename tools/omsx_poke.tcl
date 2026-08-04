# Prueba de causalidad sobre las variables del juego: escribe un valor en una
# direccion y comprueba si cambia lo que se ve en pantalla.
#
# Es la unica forma honesta de afirmar "esta direccion ES el contador de vidas":
# que coincida el valor no basta (podria ser casualidad); que al cambiarlo
# cambie el marcador, si.
#
# TEMPT_POKES = lista "addr=valor,addr=valor" en hexadecimal.

set OUT   $::env(TEMPT_OUT)
set SECS  [expr {[info exists ::env(TEMPT_SECS)] ? $::env(TEMPT_SECS) : 25}]
set TAG   [expr {[info exists ::env(TEMPT_TAG)]  ? $::env(TEMPT_TAG)  : "poke"}]
set POKES [expr {[info exists ::env(TEMPT_POKES)] ? $::env(TEMPT_POKES) : ""}]

set LOG [open "$OUT/$TAG.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }

set throttle off
catch {set renderer none}
if {[catch {loadstate tempt_boot} e]} { say "sin savestate: $e"; exit 1 }

proc pulsa {row bit} { keymatrixdown $row $bit; after time 0.3 "keymatrixup $row $bit" }
for {set t 3} {$t < $SECS} {incr t 4} { after time $t { pulsa 8 1 } }

# Deja que la partida arranque del todo antes de tocar nada.
after time [expr {$SECS - 6}] {
    foreach p [split $POKES ,] {
        if {$p eq ""} continue
        lassign [split $p =] a v
        set a [expr $a]; set v [expr $v]
        set old [debug read memory $a]
        debug write memory $a $v
        say [format "poke %#06x : %#04x -> %#04x" $a $old $v]
    }
}

after time $SECS {
    say "t=[format %.1f [machine_info time]]  PC=[format 0x%04X [reg pc]]"
    set f [open "$OUT/$TAG.vram" w]; fconfigure $f -translation binary
    puts -nonewline $f [debug read_block VRAM 0x0000 0x4000]; close $f
    set f [open "$OUT/$TAG.ram" w]; fconfigure $f -translation binary
    puts -nonewline $f [debug read_block memory 0x0000 0x10000]; close $f
    say "volcados $TAG.vram / $TAG.ram"
    exit 0
}
