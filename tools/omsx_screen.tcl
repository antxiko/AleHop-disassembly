# Vuelca la VRAM (y la RAM) tras dejar correr el juego, para saber QUE hay en
# pantalla en cada momento sin depender de capturas de imagen: la tabla de
# nombres se decodifica luego con la tabla de caracteres del juego.
#
# TEMPT_KEYS permite probar teclas: lista de "fila bit" separados por comas,
# p.ej. "8 1" para la barra espaciadora.

set OUT  $::env(TEMPT_OUT)
set SECS [expr {[info exists ::env(TEMPT_SECS)] ? $::env(TEMPT_SECS) : 20}]
set TAG  [expr {[info exists ::env(TEMPT_TAG)]  ? $::env(TEMPT_TAG)  : "scr"}]

set LOG [open "$OUT/$TAG.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }

set throttle off
catch {set renderer none}
if {[catch {loadstate tempt_boot} e]} { say "sin savestate: $e"; exit 1 }

proc pulsa {row bit} {
    keymatrixdown $row $bit
    after time 0.3 "keymatrixup $row $bit"
}

# Pulsaciones programadas: barra espaciadora repetida, por si hay varias
# pantallas encadenadas que piden confirmacion.
for {set t 3} {$t < $SECS} {incr t 4} {
    after time $t { pulsa 8 1 }
}

after time $SECS {
    say "t=[format %.1f [machine_info time]]  PC=[format 0x%04X [reg pc]]"
    foreach {nm base size} {vram 0x0000 0x4000} {
        set f [open "$OUT/$TAG.$nm" w]; fconfigure $f -translation binary
        puts -nonewline $f [debug read_block VRAM $base $size]; close $f
        say "volcado $TAG.$nm"
    }
    set f [open "$OUT/$TAG.ram" w]; fconfigure $f -translation binary
    puts -nonewline $f [debug read_block memory 0x0000 0x10000]; close $f
    say "volcado $TAG.ram"
    exit 0
}
