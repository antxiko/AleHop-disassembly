; ==========================================================================
; ALE HOP! - MSX - juego, trozo 'cola' (se ejecuta en 0xA694)
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0a694


; ----------------------------------------------------------------------
; DATOS relleno_final: Un 0x00 de relleno al final del bloque turbo 2
;   0xa694..0xa695  (1 bytes)
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; ------------------------------------------------------------
; Byte de relleno del final del bloque. Ninguna de las tres
; recolocaciones lo copia, asi que en la RAM del juego no llega
; a existir: solo esta en la cinta.
; ------------------------------------------------------------
; ----------------------------------------------------------------------
	defb 000h	; a694  .
