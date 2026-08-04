# Segunda pasada: carga la cinta, guarda un savestate en el arranque del juego
# y luego lo deja correr para capturar el estado con el juego YA funcionando.
#
# Interesa sobre todo el vector de interrupcion: el trazado estatico desde
# 0x8000 no encuentra la rutina de interrupcion porque se instala en tiempo de
# ejecucion, y de ella cuelga buena parte del codigo del juego.

set TSX $::env(TEMPT_TSX)
set OUT $::env(TEMPT_OUT)

set LOG [open "$OUT/omsx_run.log" w]
proc say {m} { global LOG; puts $LOG "\[[format %8.2f [machine_info time]]\] $m"; flush $LOG }

proc dumpmem {name addr size} {
    global OUT
    set f [open "$OUT/$name" w]; fconfigure $f -translation binary
    puts -nonewline $f [debug read_block memory $addr $size]; close $f
}

set throttle off
catch {set renderer none}
cassetteplayer insert $TSX

debug set_bp 0x8000 {} {
    say "juego arrancando: guardo savestate 'tempt_boot'"
    catch {savestate tempt_boot} e
    say "savestate -> $e"
    # Dejar correr el juego un buen rato de tiempo emulado.
    after time 20 {
        say "--- estado con el juego en marcha ---"
        say "PC=[format 0x%04X [reg pc]]  SP=[format 0x%04X [reg sp]]"
        say "modo interrupcion IM=[debug read \"CPU regs\" 10] I=[format 0x%02X [reg i]]"
        foreach {n a} {H.KEYI 0xFD9A H.TIMI 0xFD9F} {
            binary scan [debug read_block memory $a 5] H* hx
            say "$n ($a) = $hx"
        }
        dumpmem "running_full.bin" 0x0000 0x10000
        say "volcado running_full.bin"
        exit 0
    }
}
after time 4 {
    say "tecleando RUN\"CAS:\""
    type "RUN\"CAS:\"\r"
}
after time 900 { say "TIMEOUT"; exit 1 }
