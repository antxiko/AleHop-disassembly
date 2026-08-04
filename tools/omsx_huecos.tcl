# Averigua para que sirven los bytes que el analisis estatico no ha sabido
# explicar, mirando QUIEN los toca mientras el juego corre.
#
# El analisis estatico solo dice "esto no es codigo alcanzable". No dice si son
# datos que alguien lee, variables que alguien escribe o bytes muertos. Un
# watchpoint sobre cada hueco responde justo eso: si nadie lo toca en varios
# minutos de partida, es que sobra; si lo toca alguien, ahi esta la rutina que
# da la pista de que significa.
#
# Ademas se teclea movimiento y disparo, para que se ejecute el mayor numero
# posible de rutinas del juego y no solo el bucle en reposo.

set OUT  $::env(TEMPT_OUT)
set SECS [expr {[info exists ::env(TEMPT_SECS)] ? $::env(TEMPT_SECS) : 120}]

set LOG [open "$OUT/huecos.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }

set throttle off
catch {set renderer none}
if {[catch {loadstate tempt_boot} e]} { say "sin savestate: $e"; exit 1 }

# Los huecos que quedan sin explicar, tal y como los da tools/coverage.py
set HUECOS {
    0x8CDC 0x8E00 hueco_8CDC
    0xDA5C 0xDB00 hueco_DA5C
    0x8FA0 0x9000 hueco_8FA0
    0xD015 0xD041 hueco_D015
    0x8ED5 0x8F00 hueco_8ED5
    0xDDAB 0xDDAC hueco_DDAB
    0x8A36 0x8A37 hueco_8A36
    0x856E 0x856F hueco_856E
}

array set HITS {}
proc anota {nombre tipo} {
    global HITS
    set k "$nombre|$tipo|[format 0x%04X [reg pc]]"
    if {[info exists HITS($k)]} { incr HITS($k) } else { set HITS($k) 1 }
}

foreach {ini fin nom} $HUECOS {
    foreach {t etiq} {read_mem lee write_mem escribe} {
        if {[catch {debug set_watchpoint $t "$ini [expr {$fin-1}]" {} "anota $nom $etiq"} e]} {
            say "no se pudo vigilar $nom ($t): $e"
        }
    }
    say "vigilando $nom  \[$ini..[format 0x%04X [expr {$fin-1}]]\]"
}

# Barra espaciadora = fila 8 bit 0; cursores = bits 4(izq) 5(arr) 6(abj) 7(der).
proc tecla {mask ms} {
    keymatrixdown 8 $mask
    after time $ms "keymatrixup 8 $mask"
}

# Secuencia de juego: andar a los lados, saltar en diagonal y disparar, para
# tocar la mayor variedad de rutinas posible.
set ::paso 0
proc juega {} {
    set patron {0x80 0x80 0x01 0x10 0x10 0x01 0xA0 0x01 0x90 0x01 0x20 0x80 0x01 0x10}
    set m [lindex $patron [expr {$::paso % [llength $patron]}]]
    tecla $m 0.25
    incr ::paso
    after time 0.6 juega
}
after time 3 { tecla 0x01 0.3 }   ;# empezar partida

# Vidas infinitas: si no, se acaba la partida y deja de haber juego que observar.
after time 5 { debug write memory 0x84CC 0x00 ; say "parche de vidas infinitas puesto" }

# Empujon al borde derecho cada pocos segundos para que cambie de pantalla y se
# ejecuten las transiciones, los cambios de nivel y el resto de rutinas.
proc empuja {} {
    debug write memory 0x8F09 0xF4
    after time 7 empuja
}
after time 10 empuja
after time 6 juega

after time $SECS {
    global HITS
    say "\n--- accesos observados en $SECS s de partida ---"
    if {[array size HITS] == 0} {
        say "  NINGUNO: los 8 huecos no los toca nadie"
    } else {
        foreach k [lsort [array names HITS]] {
            foreach {nom tipo pc} [split $k |] break
            say [format "  %-14s %-8s desde PC=%s   %d veces" $nom $tipo $pc $HITS($k)]
        }
    }
    say "\nPC final = [format 0x%04X [reg pc]]"
    say "pantalla=[debug read memory 0x8F0D]  nivel=[debug read memory 0x8F0E]  vidas=[debug read memory 0x8F12]"
    exit 0
}
