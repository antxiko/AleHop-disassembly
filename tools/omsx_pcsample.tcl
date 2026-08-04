# Trazado DINAMICO: arranca desde el savestate, pulsa disparo para salir del
# menu y muestrea el PC frame a frame mientras el juego corre.
#
# Para que: el trazado estatico solo alcanza el 13% del binario porque muchas
# rutinas se llaman a traves de tablas de punteros que no se pueden seguir sin
# ejecutar. Cada PC muestreado aqui es una direccion que la CPU ha ejecutado de
# verdad, asi que sirve como semilla fiable para el trazador.
#
# No pretende ser exhaustivo (muestrea, no instrumenta cada instruccion): es
# para descubrir puntos de entrada, no para medir cobertura.

set OUT   $::env(TEMPT_OUT)
set SECS  [expr {[info exists ::env(TEMPT_SECS)] ? $::env(TEMPT_SECS) : 60}]

set LOG [open "$OUT/pcsample.log" w]
set PCS [open "$OUT/pcsample.txt" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }

set throttle off
catch {set renderer none}

if {[catch {loadstate tempt_boot} e]} { say "sin savestate: $e"; exit 1 }
say "savestate cargado, PC=[format 0x%04X [reg pc]]"

# La barra espaciadora esta en la fila 8, bit 0 de la matriz de teclado del MSX.
# Es lo que lee GTTRIG con A=0, que es como el menu detecta el disparo.
proc pulsa {} {
    keymatrixdown 8 1
    after time 0.2 { keymatrixup 8 1 }
}

set ::n 0
# 'after frame' no se re-encadenaba (solo tomaba una muestra), asi que se usa
# tiempo emulado, que si vuelve a registrarse bien.
proc muestrea {} {
    global PCS
    puts $PCS [format %04X [reg pc]]
    incr ::n
    after time 0.02 muestrea
}

# Traza periodica: si el PC se queda clavado en la misma zona, es que el juego
# no esta avanzando y de nada sirve seguir muestreando.
proc latido {} {
    say "  t=[format %6.1f [machine_info time]]  PC=[format 0x%04X [reg pc]]  muestras=$::n"
    after time 5 latido
}

after time 3 {
    say "pulsando disparo para salir del menu"
    pulsa
    after time 1 {
        say "empieza el muestreo"
        muestrea
        latido
    }
}

# Vuelve a pulsar de vez en cuando por si hay mas pantallas de espera.
for {set t 8} {$t < $SECS} {incr t 6} {
    after time $t { pulsa }
}

after time $SECS {
    say "muestras tomadas: $::n"
    say "PC final = [format 0x%04X [reg pc]]"
    set f [open "$OUT/pcsample_full.bin" w]; fconfigure $f -translation binary
    puts -nonewline $f [debug read_block memory 0x0000 0x10000]; close $f
    say "volcado pcsample_full.bin"
    close $PCS
    exit 0
}
