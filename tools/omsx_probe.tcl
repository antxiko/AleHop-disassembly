# Test minimo: arranca la maquina y comprueba que el BASIC esta vivo.
# openMSX manda `puts` a su propia consola, asi que el diagnostico va a fichero.
set LOG [open "/tmp/omsx_probe.log" w]
proc say {msg} { global LOG; puts $LOG $msg; flush $LOG }

set throttle off

after time 5 {
    say "MACHINE: [machine_info config_name]"
    say "PC=[format 0x%04X [reg pc]]"
    # La pagina de nombres del modo texto empieza en 0x0000 en SCREEN 0 y
    # en 0x1800 en SCREEN 1; volcamos ambas para ver cual tiene texto.
    foreach base {0x0000 0x1800} {
        set out ""
        foreach b [split [debug read_block VRAM $base 40] ""] {
            scan $b %c c
            append out [expr {$c >= 32 && $c < 127 ? $b : "."}]
        }
        say "VRAM($base): $out"
    }
    exit 0
}
after time 30 { say "TIMEOUT sin llegar al chequeo"; exit 1 }
