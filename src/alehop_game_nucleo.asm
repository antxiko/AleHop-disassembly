; ==========================================================================
; ALE HOP! - MSX - juego, trozo 'nucleo' (se ejecuta en 0xBD00)
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0bd00


; ----------------------------------------------------------------------
; DATOS tabla_nombres: Pantalla completa de 32x24 -> VRAM 0x1800
;   0xbd00..0xc000  (768 bytes)
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; ############################################################
; TABLA DE NOMBRES (768 bytes de datos, no codigo)
; ############################################################
; 32x24 casillas que 0xC05F manda a VRAM 0x1800 de una tacada.
; ----------------------------------------------------------------------
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,082h,07dh,07eh,081h,0ffh,0ffh,0ffh,082h,07dh	; bd00  ........}~.....}
	defb 07eh,081h,0ffh,0ffh,0ffh,082h,07dh,07eh,081h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bd10  ~.....}~........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,080h,0ffh,0ffh,0ffh,0ffh,0ffh,07fh	; bd20  ................
	defb 080h,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,080h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bd30  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,084h,08ah,08ah,08ah,08ah,08ah,08ah,08ah,08ah	; bd40  ................
	defb 08ah,08ah,08ah,08ah,08ah,08ah,08ah,08ah,085h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bd50  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,08bh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bd60  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,089h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bd70  ................
	defb 07eh,07dh,07eh,07dh,07eh,07dh,07eh,08bh,0ffh,066h,067h,068h,0ffh,069h,06ah,0ffh	; bd80  ~}~}~}~..fgh.ij.
	defb 06bh,068h,066h,067h,066h,067h,076h,0ffh,089h,07dh,07eh,07dh,07eh,07dh,07eh,07dh	; bd90  khfgfgv..}~}~}~}
	defb 080h,07fh,080h,07fh,080h,07fh,080h,08bh,0ffh,06ch,06dh,06eh,06fh,070h,071h,0ffh	; bda0  .........lmnopq.
	defb 078h,06dh,072h,073h,074h,075h,077h,0ffh,089h,07fh,080h,07fh,080h,07fh,080h,07fh	; bdb0  xmrstuw.........
	defb 0ffh,0ffh,07dh,07eh,0ffh,0ffh,082h,08bh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bdc0  ..}~............
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,089h,081h,0ffh,0ffh,07dh,07eh,0ffh,0ffh	; bdd0  ............}~..
	defb 0ffh,0ffh,07fh,080h,0ffh,0ffh,0ffh,086h,088h,088h,088h,088h,088h,088h,088h,088h	; bde0  ................
	defb 088h,088h,088h,088h,088h,088h,088h,088h,087h,0ffh,0ffh,0ffh,07fh,080h,0ffh,0ffh	; bdf0  ................
	defb 0ffh,0ffh,0ebh,0ech,0ffh,0ffh,0ffh,0ffh,0ffh,0f0h,0edh,0eeh,0efh,0ffh,0ffh,0ffh	; be00  ................
	defb 0ffh,0ffh,0ffh,0f0h,0edh,0eeh,0efh,0ffh,0ffh,0ffh,0ffh,0ffh,0ebh,0ech,0ffh,0ffh	; be10  ................
	defb 0ffh,0ffh,0edh,0eeh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ebh,0ech,0ebh,0ech,0ebh,0ech	; be20  ................
	defb 0ebh,0ech,0ebh,0ech,0ebh,0ech,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0edh,0eeh,0ffh,0ffh	; be30  ................
	defb 0ffh,0ffh,0ebh,0ech,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0edh,0eeh,0edh,0eeh,0edh,0eeh	; be40  ................
	defb 0edh,0eeh,0edh,0eeh,0edh,0eeh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ebh,0ech,0ffh,0ffh	; be50  ................
	defb 0ebh,0ech,0edh,0eeh,0ebh,0ech,0ebh,0ech,0ebh,0ech,0ebh,0ech,0efh,0ffh,0f0h,0efh	; be60  ................
	defb 0f0h,0efh,0ffh,0f0h,0ebh,0ech,0ebh,0ech,0ebh,0ech,0ebh,0ech,0edh,0eeh,0ebh,0ech	; be70  ................
	defb 0edh,0eeh,0ebh,0ech,0edh,0eeh,0edh,0eeh,0edh,0eeh,0edh,0eeh,0ffh,0ffh,0ffh,0f0h	; be80  ................
	defb 0efh,0ffh,0ffh,0ffh,0edh,0eeh,0edh,0eeh,0edh,0eeh,0edh,0eeh,0ebh,0ech,0edh,0eeh	; be90  ................
	defb 0ffh,0f0h,0edh,0eeh,0efh,0f2h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h	; bea0  ................
	defb 0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f3h,0f0h,0edh,0eeh,0efh,0ffh	; beb0  ................
	defb 0ffh,0ffh,0ebh,0ech,0ffh,0f9h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bec0  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f7h,0ffh,0ebh,0ech,0ffh,0ffh	; bed0  ................
	defb 0ffh,0ffh,0edh,0eeh,0ffh,0f4h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h	; bee0  ................
	defb 0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f5h,0ffh,0edh,0eeh,0ffh,0ffh	; bef0  ................
	defb 0ffh,000h,0e0h,0e1h,001h,0ffh,0ffh,0ffh,0ffh,0ffh,0e5h,0e0h,0e1h,0e4h,0ffh,0ffh	; bf00  ................
	defb 0ffh,0ffh,0e5h,0e0h,0e1h,0e4h,0ffh,0ffh,0ffh,0ffh,0ffh,000h,0e0h,0e1h,001h,0ffh	; bf10  ................
	defb 0ffh,007h,0e2h,0e3h,005h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0e2h,0e3h,0ffh,0ffh,0ffh	; bf20  ................
	defb 0ffh,0ffh,0ffh,0e2h,0e3h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,007h,0e2h,0e3h,005h,0ffh	; bf30  ................
	defb 0ffh,007h,0e0h,0e1h,005h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0e0h,0e1h,0ffh,0ffh,0ffh	; bf40  ................
	defb 0ffh,0ffh,0ffh,0e0h,0e1h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,007h,0e0h,0e1h,005h,0ffh	; bf50  ................
	defb 0ffh,007h,0e2h,0e3h,005h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h	; bf60  ................
	defb 006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,007h,0e2h,0e3h,005h,0ffh	; bf70  ................
	defb 0ffh,007h,0e0h,0e1h,005h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h	; bf80  ................
	defb 0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,007h,0e0h,0e1h,005h,0ffh	; bf90  ................
	defb 0ffh,007h,0e2h,0e3h,005h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h	; bfa0  ................
	defb 0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,007h,0e2h,0e3h,005h,0ffh	; bfb0  ................
	defb 0ffh,007h,0e0h,0e1h,005h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h	; bfc0  ................
	defb 004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,007h,0e0h,0e1h,005h,0ffh	; bfd0  ................
	defb 0ffh,007h,0e2h,0e3h,005h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bfe0  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,007h,0e2h,0e3h,005h,0ffh	; bff0  ................

; ======================================================================
; CODIGO 0xc000..0xc264  (612 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; ARRANQUE EN FRIO
; ############################################################
; A donde salta SLOTS cuando ha terminado de cargar la cinta.
; Verificado con un breakpoint en openMSX.
; ----------------------------------------------------------------------
ARRANQUE:		; Punto de entrada del juego
	ld sp,0f37fh		;c000   ; Lo primero de todo: la pila
	ld (0c52eh),a		;c003   ; Guarda A, que trae SLOTS: 0 = arranque normal, distinto de 0 = venimos de terminar la partida
	push af			;c006
	push hl			;c007
	push de			;c008
	push bc			;c009
	call 0f000h		;c00a   ; Pagina 0 -> ROM del BIOS. Por eso valen los CALL a 0x0056 y 0x005C
	call 0f014h		;c00d   ; Pagina 1 -> RAM
	call 0f019h		;c010   ; Pagina 2 -> RAM
	pop bc			;c013
	pop de			;c014
	pop hl			;c015
	pop af			;c016
	nop			;c017   ; Hueco de 32 NOP: sitio reservado para parches
	nop			;c018
	nop			;c019
	nop			;c01a
	nop			;c01b
	nop			;c01c
	nop			;c01d
	nop			;c01e
	nop			;c01f
	nop			;c020
	nop			;c021
	nop			;c022
	nop			;c023
	nop			;c024
	nop			;c025
	nop			;c026
	nop			;c027
	nop			;c028
	nop			;c029
	nop			;c02a
	nop			;c02b
	nop			;c02c
	nop			;c02d
	nop			;c02e
	nop			;c02f
	nop			;c030
	nop			;c031
	nop			;c032
	nop			;c033
	nop			;c034
	nop			;c035
	nop			;c036
	call LIMPIA_PANTALLA		;c037
	ld hl,0c3ceh		;c03a
	call L_C2AE		;c03d
	ld hl,01b00h		;c040   ; Apaga los 32 sprites poniendolos fuera de pantalla (Y = 0xC0)
	ld a,0c0h		;c043
	ld bc,00080h		;c045
	call 00056h		;c048   ; BIOS FILVRM - Fills VRAM with value
	ld hl,INTERRUPCION_TITULO		;c04b   ; Engancha 0xC105 en el hook H.TIMI, que el BIOS llama en cada interrupcion de video
	ld (0fda0h),hl		;c04e
	ld a,0c3h		;c051
	ld (0fd9fh),a		;c053
	call ARRANCA_MUSICA		;c056
	ld a,(0c52eh)		;c059   ; Segun la bandera, portada normal o pantalla de final de partida
	and a			;c05c
	jr z,L_C074		;c05d
	ld hl,0bd00h		;c05f   ; Vuelca la tabla de nombres de 0xBD00 a la VRAM
	ld de,01800h		;c062
	ld bc,00300h		;c065
	call 0005ch		;c068   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld hl,0c510h		;c06b
	call CARGA_GRAFICOS_2		;c06e
	jp SCROLL_MENSAJE		;c071
L_C074:
	ld hl,04000h		;c074   ; Vuelca el mapa de la pantalla de presentacion (0x4000)
	ld bc,00300h		;c077
	ld de,01800h		;c07a
	call 0005ch		;c07d   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld hl,0c510h		;c080
	call CARGA_GRAFICOS_2		;c083
BUCLE_ATRACCION:		; El bucle del modo atraccion: encadena las cinco escenas y vuelve a empezar
	call ESCENA_2		;c086   ; Las cinco escenas del modo atraccion, en bucle hasta que alguien pulse
	call ESCENA_1		;c089
	call ESCENA_3		;c08c
	call ESCENA_4		;c08f
	call ESCENA_5		;c092
	jr BUCLE_ATRACCION		;c095
ESCENA_1:		; Primera escena: coloca la bola y la deja rebotando hasta que se pulsa disparo
	xor a			;c097
	ld (0c532h),a		;c098
	ld (0c533h),a		;c09b
	ld a,04ch		;c09e
	ld (0c531h),a		;c0a0
L_C0A3:
	call PREPARA_BOLA		;c0a3   ; 0x4C es la columna de partida de la bola
	ld a,0edh		;c0a6
	call L_C282		;c0a8
	ld a,024h		;c0ab
	ld (0c534h),a		;c0ad
L_C0B0:
	call LEE_DISPARO_2		;c0b0
	jr z,L_C0A3		;c0b3
	ld hl,0c532h		;c0b5
	inc (hl)		;c0b8
	ret z			;c0b9
	call PINTA_BOLA		;c0ba
	halt			;c0bd   ; Espera al retrazo: la animacion va a 50/60 fotogramas por segundo
	jr L_C0B0		;c0be
PREPARA_BOLA:		; Deja la bola en su fotograma inicial y pinta los cuatro sprites
	ld a,00ch		;c0c0
	ld (0c534h),a		;c0c2
	call PINTA_BOLA		;c0c5
	ld b,004h		;c0c8
	call PINTA_N_SPRITES		;c0ca
	ret			;c0cd
HL_MAS_A:		; Utilidad: HL += A. La misma que 0xD123 en el motor
	push de			;c0ce
	ld e,a			;c0cf
	ld d,000h		;c0d0
	add hl,de		;c0d2
	pop de			;c0d3
	ret			;c0d4
LEE_DISPARO:		; GTTRIG: mira el espacio y tambien el boton del joystick
	xor a			;c0d5
	call 000d8h		;c0d6   ; BIOS GTTRIG - Returns current trigger status
	and a			;c0d9
	ret nz			;c0da
	ld a,001h		;c0db
	call 000d8h		;c0dd   ; BIOS GTTRIG - Returns current trigger status
	and a			;c0e0
	ret			;c0e1
DESCOMPRIME_2:		; El mismo descompresor RLE que 0xD2BE, pero volcando a 0xC540
	ld de,0c540h		;c0e2
L_C0E5:
	ld c,(hl)		;c0e5
	inc hl			;c0e6
	ld b,(hl)		;c0e7
	inc hl			;c0e8
	bit 7,b			;c0e9
	jr z,L_C101		;c0eb
	ld a,0ffh		;c0ed
	cp b			;c0ef
	jr nz,L_C0F4		;c0f0
	cp c			;c0f2
	ret z			;c0f3
L_C0F4:
	res 7,b			;c0f4
	ld a,(hl)		;c0f6
	ld (de),a		;c0f7
	inc de			;c0f8
	dec bc			;c0f9
	ld a,c			;c0fa
	or b			;c0fb
	jr nz,L_C0F4		;c0fc
	inc hl			;c0fe
	jr L_C0E5		;c0ff
L_C101:
	ldir			;c101
	jr L_C0E5		;c103
INTERRUPCION_TITULO:		; Manejador enganchado en H.TIMI durante el titulo
	in a,(099h)		;c105
	pop hl			;c107
	ld hl,0c53bh		;c108
	inc (hl)		;c10b   ; Contador de frames del titulo, el equivalente a 0xDB75 en la partida
	call 0b036h		;c10c   ; Mueve la musica: el reproductor va enganchado a la interrupcion
	pop ix			;c10f
	pop iy			;c111
	pop af			;c113
	pop bc			;c114
	pop de			;c115
	pop hl			;c116
	ex af,af'		;c117
	exx			;c118
	pop af			;c119
	pop bc			;c11a
	pop de			;c11b
	pop hl			;c11c
	ei			;c11d
	nop			;c11e   ; Doce NOP de relleno, sitio reservado para parches
	nop			;c11f
	nop			;c120
	nop			;c121
	nop			;c122
	nop			;c123
	nop			;c124
	nop			;c125
	nop			;c126
	nop			;c127
	nop			;c128
	nop			;c129
	ret			;c12a
FOTOGRAMA_BOLA:		; Saca el fotograma de la bola de los bits 2-3 del contador de frames
	ld a,(0c53bh)		;c12b
	and 00ch		;c12e   ; Los bits 2 y 3 del contador dan cuatro fotogramas de animacion
	ld (0c534h),a		;c130
	ret			;c133
PINTA_BOLA:		; Monta los tres planos de color de la bola y los escribe como sprites
	ld iy,0c3ech		;c134   ; Tres pasadas, una por plano de color: asi se hace un sprite multicolor en el MSX1
	ld hl,0c537h		;c138
	ld b,003h		;c13b
L_C13D:
	ld a,(0c531h)		;c13d
	ld c,a			;c140
	ld a,(0c533h)		;c141
	add a,c			;c144
	ld (iy+000h),a		;c145
	ld a,(0c532h)		;c148
	ld (iy+001h),a		;c14b
	ld a,(0c534h)		;c14e
	sub b			;c151
	add a,003h		;c152
	sla a			;c154
	sla a			;c156
	ld (iy+002h),a		;c158   ; El numero de patron va multiplicado por 4 porque los sprites son de 16x16
	ld a,(hl)		;c15b
	ld (iy+003h),a		;c15c
	ld a,004h		;c15f
	sub b			;c161
	call ESCRIBE_SPRITE_2		;c162
	inc hl			;c165
	djnz L_C13D		;c166
	call LEE_DISPARO		;c168
	jp nz,EMPIEZA_PARTIDA		;c16b
	ret			;c16e
EMPIEZA_PARTIDA:		; Desengancha la interrupcion, silencia el PSG y salta al motor
	ld hl,0fd9fh		;c16f
	ld (hl),0c9h		;c172   ; Mete un RET en el hook H.TIMI para desenganchar la interrupcion del titulo
	call 00090h		;c174   ; BIOS GICINI - Initialises PSG and sets initial value for the PLAY statement | BIOS GICINI: calla el PSG antes de entrar en la partida
	jp 0d000h		;c177   ; Al pulsar disparo se salta al motor del juego: es la unica entrada a 0xD000
LEE_DISPARO_2:		; Otra lectura del disparo, la que usan las escenas
	ld hl,0c535h		;c17a
	inc (hl)		;c17d
	ld a,(hl)		;c17e
	sra a			;c17f
	sra a			;c181
	ld hl,0c533h		;c183
	add a,(hl)		;c186
	ld (hl),a		;c187
	ret			;c188
ESCENA_5:		; Ultima escena del modo atraccion
	ld a,038h		;c189
	ld (0c534h),a		;c18b
	xor a			;c18e
	ld (0c533h),a		;c18f
	ld (0c532h),a		;c192
	ld a,04ah		;c195
	ld (0c531h),a		;c197
L_C19A:
	ld bc,0ec01h		;c19a
	call L_C245		;c19d
	call PINTA_BOLA		;c1a0
	ld hl,0c532h		;c1a3
	ld a,003h		;c1a6
	add a,(hl)		;c1a8
	ld (hl),a		;c1a9
	halt			;c1aa
	jr nc,L_C19A		;c1ab
	ld hl,01b00h		;c1ad
	ld a,0c0h		;c1b0
	jp 0004dh		;c1b2   ; BIOS WRTVRM - Writes data in VRAM
ESCENA_3:		; Tercera escena
	xor a			;c1b5
	ld (0c532h),a		;c1b6
	ld (0c533h),a		;c1b9
	ld (0c53bh),a		;c1bc
	ld a,04ah		;c1bf
	ld (0c531h),a		;c1c1
	ld a,028h		;c1c4
	ld (0c534h),a		;c1c6
L_C1C9:
	call PINTA_BOLA		;c1c9
	ld hl,0c532h		;c1cc
	inc (hl)		;c1cf
	inc (hl)		;c1d0
	ret z			;c1d1
	halt			;c1d2
	ld hl,0c533h		;c1d3
	inc (hl)		;c1d6
	ld a,(0c53bh)		;c1d7
	and 004h		;c1da
	jr z,L_C1C9		;c1dc
	dec (hl)		;c1de
	dec (hl)		;c1df
	jr L_C1C9		;c1e0
ESCENA_4:		; Cuarta escena
	xor a			;c1e2
	ld (0c532h),a		;c1e3
	ld (0c533h),a		;c1e6
	ld a,04ah		;c1e9
	ld (0c531h),a		;c1eb
L_C1EE:
	ld a,(0c53bh)		;c1ee
	sra a			;c1f1
	and 007h		;c1f3
	ld hl,0c3e4h		;c1f5
	call HL_MAS_A		;c1f8
	ld a,(hl)		;c1fb
	ld (0c534h),a		;c1fc
	call PINTA_BOLA		;c1ff
	ld hl,0c532h		;c202
	inc (hl)		;c205
	inc (hl)		;c206
	ret z			;c207
	halt			;c208
	jr L_C1EE		;c209
CARGA_GRAFICOS_2:		; Gemelo de 0xD5FC: recorre una tabla de pares (origen, destino VRAM)
	nop			;c20b
	ld e,(hl)		;c20c
	inc hl			;c20d
	ld d,(hl)		;c20e
	inc hl			;c20f
	ld a,d			;c210
	or e			;c211
	ret z			;c212
	push hl			;c213
	ex de,hl		;c214
	call DESCOMPRIME_2		;c215
	pop hl			;c218
	ld e,(hl)		;c219
	inc hl			;c21a
	ld d,(hl)		;c21b
	inc hl			;c21c
	push hl			;c21d
	ld bc,00800h		;c21e
	ld hl,0c540h		;c221
	call 0005ch		;c224   ; BIOS LDIRVM - Block transfers to VRAM from memory
	pop hl			;c227
	jr CARGA_GRAFICOS_2		;c228
ESCRIBE_SPRITE_2:		; Vuelca los 4 bytes de atributo de un sprite. Gemelo de 0xD885
	push hl			;c22a
	push bc			;c22b
	push de			;c22c
	sla a			;c22d
	sla a			;c22f
	ld hl,01b00h		;c231
	call HL_MAS_A		;c234
	ex de,hl		;c237
	ld hl,0c3ech		;c238
	ld bc,00004h		;c23b
	call 0005ch		;c23e   ; BIOS LDIRVM - Block transfers to VRAM from memory
	pop de			;c241
	pop bc			;c242
	pop hl			;c243
	ret			;c244
L_C245:
	ld a,(0c531h)		;c245
	ld d,a			;c248
	ld a,(0c533h)		;c249
	add a,d			;c24c
	ld iy,0c3ech		;c24d
	ld (iy+000h),a		;c251
	ld a,(0c532h)		;c254
	ld (iy+001h),a		;c257
	ld (iy+002h),b		;c25a
	ld (iy+003h),c		;c25d
	xor a			;c260
	jp ESCRIBE_SPRITE_2		;c261

; ----------------------------------------------------------------------
; DATOS codigo_muerto_1: 26 bytes de codigo al que no llega nadie
;   0xc264..0xc27e  (26 bytes)
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; ------------------------------------------------------------
; CODIGO MUERTO (26 bytes). Desensambla como un bucle coherente:
; ld hl,0xC532 / ld a,(0xC52F) / add a,(hl) / ld (hl),a
; call 0xC17A / push af / call 0xC134
; ld bc,0x7C05 / call 0xC245 / pop af / ret z / halt / jr -26
; Pero no hay una sola instruccion que salte aqui, ni ningun
; puntero 64 C2 en todo el binario. Es codigo de otra version.
; ------------------------------------------------------------
; ----------------------------------------------------------------------
	defb 021h,032h,0c5h,03ah,02fh,0c5h,086h,077h,0cdh,07ah,0c1h,0f5h,0cdh,034h,0c1h,001h	; c264  !2.:/..w.z...4..
	defb 005h,07ch,0cdh,045h,0c2h,0f1h,0c8h,076h,018h,0e6h	; c274  .|.E...v..

; ======================================================================
; CODIGO 0xc27e..0xc38e  (272 bytes)
; ======================================================================


PINTA_N_SPRITES:		; Pinta B sprites seguidos
	halt			;c27e
	djnz PINTA_N_SPRITES		;c27f
	ret			;c281
L_C282:
	ld (0c535h),a		;c282
	xor a			;c285
	ld (0c533h),a		;c286
	ret			;c289
ESCENA_2:		; Segunda escena
	xor a			;c28a
	ld (0c532h),a		;c28b
	ld (0c533h),a		;c28e
	ld a,04ah		;c291
	ld (0c531h),a		;c293
L_C296:
	call FOTOGRAMA_BOLA		;c296
	call PINTA_BOLA		;c299
	ld hl,0c532h		;c29c
	inc (hl)		;c29f
	ret z			;c2a0
	halt			;c2a1
	jr L_C296		;c2a2
LIMPIA_PANTALLA:		; Prepara la pantalla antes de dibujar
	ld hl,00000h		;c2a4
	ld bc,04000h		;c2a7
	xor a			;c2aa
	jp 00056h		;c2ab   ; BIOS FILVRM - Fills VRAM with value
L_C2AE:
	ld c,(hl)		;c2ae
	inc hl			;c2af
	ld b,(hl)		;c2b0
	inc hl			;c2b1
	ld a,c			;c2b2
	or b			;c2b3
	ret z			;c2b4
	push hl			;c2b5
	call 00047h		;c2b6   ; BIOS WRTVDP - Writes data in the VDP-register
	pop hl			;c2b9
	jr L_C2AE		;c2ba
SCROLL_MENSAJE:		; Hace pasar el mensaje de fin de partida, letra a letra y pixel a pixel
	call REINICIA_SCROLL		;c2bc
L_C2BF:
	ld hl,(0c53dh)		;c2bf
	inc hl			;c2c2
	ld (0c53dh),hl		;c2c3
	ld a,(hl)		;c2c6   ; Lee la siguiente letra del mensaje; el 0x00 lo devuelve al principio
	and a			;c2c7
	jp z,SCROLL_MENSAJE		;c2c8
	cp 020h			;c2cb
	jr nz,L_C2D1		;c2cd
	ld a,096h		;c2cf   ; El espacio (0x20) se cambia por 0x96 para que caiga en el hueco blanco de la tipografia
L_C2D1:
	add a,069h		;c2d1   ; Sumando 0x69 el codigo ASCII se convierte en numero de tile
	ld e,a			;c2d3
	ld d,000h		;c2d4
	sla e			;c2d6
	rl d			;c2d8
	sla e			;c2da
	rl d			;c2dc
	sla e			;c2de
	rl d			;c2e0
	ld hl,00800h		;c2e2
	add hl,de		;c2e5
	ld de,0cde0h		;c2e6
	ld bc,00008h		;c2e9
	call 00059h		;c2ec   ; BIOS LDIRMV - Block transfers to memory from VRAM | BIOS LDIRMV: se lee el dibujo de la letra desde la propia VRAM
	ld b,008h		;c2ef
L_C2F1:
	push bc			;c2f1
	call DESPLAZA_UNA_FILA		;c2f2
	ld hl,0cd40h		;c2f5
	ld de,00800h		;c2f8
	ld bc,000a0h		;c2fb
	call 0005ch		;c2fe   ; BIOS LDIRVM - Block transfers to VRAM from memory
	halt			;c301   ; Dos esperas de retrazo: es lo que marca la velocidad del scroll
	halt			;c302
	pop bc			;c303
	djnz L_C2F1		;c304
	call LEE_DISPARO		;c306
	jp nz,EMPIEZA_PARTIDA		;c309
	jr L_C2BF		;c30c
DESPLAZA_UNA_FILA:		; Rota un pixel a la izquierda las 8 filas del renglon
	ld b,008h		;c30e
L_C310:
	push bc			;c310
	ld hl,0cddfh		;c311
	ld a,b			;c314
	call HL_MAS_A		;c315
	call L_C31F		;c318
	pop bc			;c31b
	djnz L_C310		;c31c
	ret			;c31e
L_C31F:
	rl (hl)			;c31f
	push af			;c321
	pop bc			;c322
	ld de,0fff8h		;c323
	add hl,de		;c326
	ld de,0cd40h		;c327
	and a			;c32a
	sbc hl,de		;c32b
	ret c			;c32d
	add hl,de		;c32e
	push bc			;c32f
	pop af			;c330
	jr L_C31F		;c331
REINICIA_SCROLL:		; Limpia el renglon y vuelve a poner el puntero al principio del mensaje
	ld hl,0cd40h		;c333
	ld de,0cd41h		;c336
	ld bc,000a6h		;c339
	ld (hl),000h		;c33c
	ldir			;c33e
	ld hl,0c3efh		;c340
	ld (0c53dh),hl		;c343
	ld hl,00d58h		;c346
	ld bc,000e0h		;c349
L_C34C:
	call 0004ah		;c34c   ; BIOS RDVRM - Reads the content of VRAM
	cpl			;c34f
	bit 7,a			;c350
	call z,0004dh		;c352   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;c355
	dec bc			;c356
	ld a,b			;c357
	or c			;c358
	jr nz,L_C34C		;c359
	ld hl,02800h		;c35b
	ld bc,000a0h		;c35e
L_C361:
	push hl			;c361
	ld de,02800h		;c362
	and a			;c365
	sbc hl,de		;c366
	ld a,l			;c368
	and 007h		;c369
	sra a			;c36b
	ld hl,0c3e0h		;c36d
	call HL_MAS_A		;c370
	ld a,(hl)		;c373
	pop hl			;c374
	call 0004dh		;c375   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;c378
	dec bc			;c379
	ld a,c			;c37a
	or b			;c37b
	jr nz,L_C361		;c37c
	ld hl,019d9h		;c37e
	ld a,013h		;c381
L_C383:
	push af			;c383
	call 0004dh		;c384   ; BIOS WRTVRM - Writes data in VRAM
	dec hl			;c387
	pop af			;c388
	dec a			;c389
	jp p,L_C383		;c38a
	ret			;c38d

; ----------------------------------------------------------------------
; DATOS codigo_muerto_2: 43 bytes: efecto de cambio de color de la VRAM, sin usar
;   0xc38e..0xc3b9  (43 bytes)
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; ------------------------------------------------------------
; CODIGO MUERTO (43 bytes). Es un efecto de cambio de color:
; recorre los 0x1830 bytes de la tabla de color de la VRAM
; (desde 0x2000), lee cada byte con RDVRM, le da dos vueltas a
; la rutina de 0xC3A7 -que rota los nibbles y cambia el color 1
; por el 0- y lo devuelve con WRTVRM.
; Nadie lo llama: buscado el puntero 8E C3 en todo el binario,
; cero apariciones. Y 0xC3A7 solo se referencia desde dentro de
; este mismo trozo. Un efecto que se quedo fuera.
; ------------------------------------------------------------
; ----------------------------------------------------------------------
	defb 021h,000h,020h,001h,030h,018h,0cdh,04ah,000h,0cdh,0a7h,0c3h,0cdh,0a7h,0c3h,0cdh	; c38e  !. .0..J........
	defb 04dh,000h,023h,00bh,078h,0b1h,020h,0eeh,0c9h,0cbh,007h,0cbh,007h,0cbh,007h,0cbh	; c39e  M.#.x. .........
	defb 007h,057h,0e6h,00fh,0eeh,001h,07ah,0c0h,0e6h,0f0h,0c9h	; c3ae  .W....z....

; ======================================================================
; CODIGO 0xc3b9..0xc3ce  (21 bytes)
; ======================================================================


ARRANCA_MUSICA:		; Pone las tres voces de la musica del titulo, una por canal del PSG
	ld de,0b593h		;c3b9
	xor a			;c3bc
	call 0b015h		;c3bd
	ld de,0b640h		;c3c0
	inc a			;c3c3
	call 0b015h		;c3c4
	ld de,0b877h		;c3c7
	inc a			;c3ca
	jp 0b015h		;c3cb

; ----------------------------------------------------------------------
; DATOS tabla_C3CE: 18 bytes que lee 0xC03A al arrancar, antes de llamar a 0xC2AE
;   0xc3ce..0xc3e0  (18 bytes)
; DATOS tablas_cortas: Dos tablitas: 0xC3E0 (la lee 0xC36D) y 0xC3E4 (la lee 0xC1F5)
;   0xc3e0..0xc3ec  (12 bytes)
; DATOS buffer_sprite: Los 4 bytes de atributo (Y, X, patron, color) que monta PINTA_BOLA con IY. El equivalente en la partida es 0xDADD
;   0xc3ec..0xc3f0  (4 bytes)
; DATOS mensaje_final: El texto que hace scroll al terminar el juego, en ASCII, terminado en 0x00
;   0xc3f0..0xc4a7  (183 bytes)
; DATOS relleno_mensaje: El 0x00 que cierra el mensaje y espacios de relleno hasta la tabla de graficos
;   0xc4a7..0xc510  (105 bytes)
; DATOS tabla_graficos: Juego de graficos de la presentacion. Es el MISMO contenido que la tabla de 0xDB35 del motor: pares (origen comprimido, destino VRAM) terminados en 0x0000
;   0xc510..0xc52e  (30 bytes)
; DATOS bandera_arranque: 0xC52E: 0 = arranque normal, distinto de 0 = se vuelve de terminar la partida. La escribe 0xC003 con el valor que trae SLOTS y la lee 0xC059
;   0xc52e..0xc531  (3 bytes)
; DATOS variables_titulo: Las variables de la pantalla de titulo. Las mas usadas: 0xC532 (12 accesos), 0xC533 (10), 0xC531 y 0xC534 (7 cada una), 0xC53B (contador de frames de la interrupcion, igual que 0xDB75 en la partida) y 0xC53D (puntero de 16 bits)
;   0xc531..0xc540  (15 bytes)
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; ############################################################
; DATOS Y VARIABLES DE LA PANTALLA DE TITULO
; ############################################################
; ----------------------------------------------------------------------
	defb 000h,002h,001h,062h,002h,006h,003h,0ffh,004h,003h,007h,011h,005h,036h,006h,007h	; c3ce  ...b.........6..
	defb 000h,000h,040h,050h,070h,0f0h,010h,010h,010h,010h,014h,018h,01ch,020h,000h,000h	; c3de  ..@Pp........ ..
	defb 000h,000h,045h,04eh,048h,04fh,052h,041h,042h,055h,045h,04eh,041h,05ch,05ch,05ch	; c3ee  ..ENHORABUENA\\\
	defb 020h,020h,020h,020h,020h,048h,041h,053h,020h,043h,04fh,04eh,053h,045h,047h,055h	; c3fe       HAS CONSEGU
	defb 049h,044h,04fh,020h,053h,055h,050h,045h,052h,041h,052h,020h,04ch,04fh,053h,020h	; c40e  IDO SUPERAR LOS 
	defb 04fh,042h,053h,054h,041h,043h,055h,04ch,04fh,053h,020h,051h,055h,045h,020h,054h	; c41e  OBSTACULOS QUE T
	defb 045h,020h,053h,045h,050h,041h,052h,041h,042h,041h,04eh,020h,044h,045h,020h,04ch	; c42e  E SEPARABAN DE L
	defb 041h,020h,056h,049h,043h,054h,04fh,052h,049h,041h,05bh,05bh,05bh,020h,020h,020h	; c43e  A VICTORIA[[[   
	defb 020h,020h,020h,054h,04fh,050h,04fh,020h,053h,04fh,046h,054h,020h,054h,045h,020h	; c44e     TOPO SOFT TE 
	defb 046h,045h,04ch,049h,043h,049h,054h,041h,05bh,020h,020h,020h,020h,050h,045h,052h	; c45e  FELICITA[    PER
	defb 04fh,05bh,05bh,05bh,020h,020h,050h,04fh,044h,052h,041h,053h,020h,043h,04fh,04eh	; c46e  O[[[  PODRAS CON
	defb 020h,020h,020h,054h,045h,04dh,050h,054h,041h,054h,049h,04fh,04eh,05dh,05dh,020h	; c47e     TEMPTATION]] 
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c48e                  
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,000h,020h,020h,020h,020h,020h,020h	; c49e           .      
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4ae                  
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4be                  
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4ce                  
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4de                  
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4ee                  
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4fe                  
	defb 020h,020h,035h,06dh,000h,000h,037h,071h,000h,020h,0cfh,074h,000h,008h,0e9h,07bh	; c50e    5m..7q. .t...{
	defb 000h,028h,0eeh,05fh,000h,010h,0c9h,066h,000h,030h,093h,082h,000h,038h,000h,000h	; c51e  .(._...f.0...8..
	defb 000h,000h,000h,04ch,080h,000h,000h,000h,000h,001h,00fh,00bh,000h,000h,000h,000h	; c52e  ...L............
	defb 000h,0ffh	; c53e  ..
