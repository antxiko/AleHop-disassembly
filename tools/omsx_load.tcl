# Carga la cinta original de Ale Hop! en openMSX y vuelca la RAM en los puntos clave.
#
# Sirve como DECODIFICADOR DE REFERENCIA: en vez de reimplementar el turbo
# loader de Topo Soft, dejamos que el cargador original haga el trabajo y
# capturamos el resultado. Asi los bloques turbo salen exactamente como el
# juego los ve en memoria.
#
# Cadena de carga de Ale Hop! (leida de SLOTS; esto es lo que viene a confirmar):
#   0x9470  TOPO, pantalla de presentacion
#   0xC58F  entrada de SLOTS
#   0xC5AD  SLOTS se copia a si mismo 0xC5BB..0xC63F (133 B) a 0xE09C y salta alli,
#           asi que a partir de ahi todo corre desplazado +0x1AE1
#   0x88B8  bloque turbo 1 cargado (portada, 12388 B); se ejecuta y vuelve
#   0xE0B4  (= 0xC5D3) va a cargar el bloque 2 en 0x0000, 0xA695 = 42645 bytes
#   0xE0C0  (= 0xC5DF) bloque 2 YA cargado, ANTES de recolocar nada  <-- captura clave
#   0xE11E  (= 0xC63D) recolocaciones hechas, salta al juego en 0xC000
#   0xC000  el juego arranca
#
# A diferencia de Temptations, aqui el juego se carga en la PAGINA 0 (0x0000),
# o sea que la ROM del BASIC deja de estar mapeada, y luego se recolocan tres
# trozos con LDIR (0x8A41->0xB000, 0x92DA->0xBD00, 0x9B1A->0xD000).

# openMSX no pasa argv a los scripts de -script, asi que van por entorno.
set TSX  $::env(ALEHOP_TSX)
set OUT  $::env(ALEHOP_OUT)

set LOG [open "$OUT/omsx_load.log" w]
proc say {msg} { global LOG; puts $LOG "\[[format %8.2f [machine_info time]]\] $msg"; flush $LOG }

proc dump {name addr size} {
    global OUT
    set f [open "$OUT/$name" w]
    fconfigure $f -translation binary
    puts -nonewline $f [debug read_block memory $addr $size]
    close $f
    say "volcado $name  <- CPU\[[format 0x%04X $addr] .. [format 0x%04X [expr {$addr+$size-1}]]\] ($size bytes)"
}

set throttle off
catch {set renderer none}

cassetteplayer insert $TSX
say "cinta insertada: $TSX"

# Sondas: registran el paso por cada etapa de la cadena de carga.
debug set_bp 0x9470 {} { say "TOPO en marcha (pantalla de presentacion)" }
debug set_bp 0xC58F {} { say "SLOTS: entrada del cargador turbo" }

debug set_bp 0x88B8 {} {
    say "bloque turbo 1 cargado; PC va a entrar en 0x88B8 (portada)"
    dump "turbo1_ram.bin" 0x88B8 0x3064
}

# Justo despues de cargar el bloque 2 y ANTES de las tres recolocaciones:
# aqui la RAM 0x0000..0xA694 es el bloque turbo 2 tal cual sale de la cinta.
debug set_bp 0xE0C0 {} {
    say "bloque turbo 2 cargado (crudo, sin recolocar)"
    dump "turbo2_ram.bin" 0x0000 0xA695
    dump "full_crudo.bin"  0x0000 0x10000
}

debug set_bp 0xE11E {} {
    say "recolocaciones hechas; va a saltar al juego"
    dump "full_recolocado.bin" 0x0000 0x10000
}

debug set_bp 0xC000 {} {
    say "el juego arranca en 0xC000"
    dump "full_at_C000.bin" 0x0000 0x10000
    say "OK: la cinta original carga y el juego arranca"
    exit 0
}

# El BASIC tarda un poco en estar listo para aceptar teclas.
after time 4 {
    say "tecleando RUN\"CAS:\""
    type "RUN\"CAS:\"\r"
}

after time 900 { say "TIMEOUT: no se llego a 0xC000"; exit 1 }
