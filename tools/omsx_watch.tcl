# Watchpoints sobre variables del juego: registra QUE codigo lee o escribe una
# direccion. Es la forma de pasar de "esta direccion tiene el valor que espero"
# (que puede ser casualidad) a "esta rutina la usa", que ya es una prueba.
#
# TEMPT_WATCH = lista "addr:tipo" separada por comas, tipo r|w (p.ej "0x8F12:r").

set OUT   $::env(TEMPT_OUT)
set SECS  [expr {[info exists ::env(TEMPT_SECS)] ? $::env(TEMPT_SECS) : 30}]
set TAG   [expr {[info exists ::env(TEMPT_TAG)]  ? $::env(TEMPT_TAG)  : "watch"}]
set WATCH $::env(TEMPT_WATCH)

set LOG [open "$OUT/$TAG.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }

set throttle off
catch {set renderer none}
if {[catch {loadstate tempt_boot} e]} { say "sin savestate: $e"; exit 1 }

# Un mismo sitio dispara miles de veces; solo interesa el conjunto de rutinas
# distintas que tocan la variable, asi que se cuentan por PC.
array set HITS {}
proc anota {addr tipo} {
    global HITS
    set pc [format 0x%04X [reg pc]]
    set k "$addr $tipo $pc"
    if {[info exists HITS($k)]} { incr HITS($k) } else { set HITS($k) 1 }
}

foreach w [split $WATCH ,] {
    if {$w eq ""} continue
    lassign [split $w :] a t
    set tipo [expr {$t eq "w" ? "write_mem" : "read_mem"}]
    if {[catch {debug set_watchpoint $tipo $a {} "anota $a $t"} e]} {
        say "no se pudo poner watchpoint $tipo en $a: $e"
    } else {
        say "watchpoint $tipo en $a instalado"
    }
}

proc pulsa {row bit} { keymatrixdown $row $bit; after time 0.3 "keymatrixup $row $bit" }
for {set t 3} {$t < $SECS} {incr t 4} { after time $t { pulsa 8 1 } }

after time $SECS {
    global HITS
    say "--- accesos observados (direccion tipo PC -> veces) ---"
    foreach k [lsort [array names HITS]] { say "  $k  ->  $HITS($k)" }
    say "PC final = [format 0x%04X [reg pc]]"
    exit 0
}
