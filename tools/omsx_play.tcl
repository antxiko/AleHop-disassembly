# Arranca el juego para jugarlo a mano, partiendo del savestate para no esperar
# los ~7 minutos de carga de cinta. Velocidad real y ventana normal.
#
# El savestate se toma justo en 0x8000 (entrada del juego), asi que arranca ya
# en la presentacion.

if {[catch {loadstate tempt_boot} e]} {
    # Sin savestate, al menos que arranque la maquina con la cinta puesta.
    if {[info exists ::env(TEMPT_TSX)]} { cassetteplayer insert $::env(TEMPT_TSX) }
}
set throttle on
