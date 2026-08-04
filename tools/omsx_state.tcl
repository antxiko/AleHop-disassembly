# Analiza el juego EN MARCHA partiendo del savestate guardado en 0x8000,
# para no tener que recargar los 7 minutos de cinta en cada iteracion.
#
# Objetivo: localizar la rutina de interrupcion. El trazado estatico desde
# 0x8000 no la encuentra porque el puntero se instala en tiempo de ejecucion,
# y de ella cuelga el bucle de juego.

set OUT $::env(TEMPT_OUT)
set SECS [expr {[info exists ::env(TEMPT_SECS)] ? $::env(TEMPT_SECS) : 20}]

set LOG [open "$OUT/omsx_state.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }

proc try {label script} {
    if {[catch {uplevel 1 $script} r]} { say "$label = <error: $r>" } else { say "$label = $r" }
}

set throttle off
catch {set renderer none}

if {[catch {loadstate tempt_boot} e]} {
    say "NO se pudo cargar el savestate: $e"
    exit 1
}
say "savestate cargado; PC=[format 0x%04X [reg pc]]"

after time $SECS {
    say "--- juego en marcha tras $SECS s emulados ---"
    try "PC" { format 0x%04X [reg pc] }
    try "SP" { format 0x%04X [reg sp] }
    try "I"  { format 0x%02X [reg i] }
    try "IM" { reg im }
    try "IFF1" { reg iff1 }

    # Hooks de la BIOS en RAM: si el juego engancha la interrupcion de
    # temporizador, aqui habra un JP a su rutina.
    foreach {n a} {H.KEYI 0xFD9A H.TIMI 0xFD9F} {
        binary scan [debug read_block memory $a 5] H* hx
        say "$n ($a) = $hx"
    }
    # Con IM 2 el vector se compone con I; volcamos la tabla por si acaso.
    set i [reg i]
    binary scan [debug read_block memory [expr {$i*256}] 16] H* hx
    say "tabla IM2 en [format 0x%04X [expr {$i*256}]] = $hx"

    set f [open "$OUT/running_full.bin" w]; fconfigure $f -translation binary
    puts -nonewline $f [debug read_block memory 0x0000 0x10000]; close $f
    say "volcado running_full.bin"

    catch {screenshot -raw $OUT/running.png} sr
    say "screenshot -> $sr"
    exit 0
}
after time [expr {$SECS + 600}] { say "TIMEOUT"; exit 1 }
