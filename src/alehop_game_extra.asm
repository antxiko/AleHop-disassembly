; ==========================================================================
; ALE HOP! - MSX - juego, trozo 'extra' (se ejecuta en 0xD000)
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0d000


; ======================================================================
; CODIGO 0xd000..0xdab2  (2738 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; RUTINA DE FRAME: el corazon del juego
; ############################################################
; Espera al retrazo con HALT y luego despacha hasta 11 tareas
; segun una mascara de 16 bits guardada en 0xDB69/0xDB6A. Cada
; bit enciende o apaga una subrutina, con lo que el juego cambia
; de comportamiento (jugando, muriendo, cambiando de nivel) sin
; mas que cambiar la mascara. La mascara normal es 0xE0FF.
; ----------------------------------------------------------------------
L_D000:
	jp EMPIEZA_PARTIDA		;d000
FRAME:		; Una vuelta de juego: HALT y despacho por la mascara 0xDB69
	ld ix,0db69h		;d003   ; IX apunta a la mascara de tareas: los 11 `bit n,(ix+d)` de abajo la leen
	halt			;d007
	bit 7,(ix+000h)		;d008
	call nz,VUELCA_MAPA	;d00c
	bit 6,(ix+000h)		;d00f
	call nz,VUELCA_FONDO	;d013
	bit 5,(ix+000h)		;d016
	call nz,ANIMA_CASILLAS	;d01a
	bit 4,(ix+000h)		;d01d
	call nz,APLICA_VELOCIDAD	;d021
	bit 3,(ix+000h)		;d024
	call nz,AVANZA_CAMARA	;d028
	bit 2,(ix+000h)		;d02b
	call nz,APLICA_ALTURA	;d02f
	bit 1,(ix+000h)		;d032
	call nz,PATRON_SEGUN_FRAME	;d036
	bit 0,(ix+000h)		;d039
	call nz,PINTA_JUGADOR	;d03d
	bit 7,(ix+001h)		;d040
	call nz,COLISION	;d044
	bit 6,(ix+001h)		;d047
	call nz,SALTO	;d04b
	bit 5,(ix+001h)		;d04e
	call nz,CUENTA_ATRAS	;d052
	ld a,(0db54h)		;d055
	cp 0e0h			;d058
	jp nc,L_D761		;d05a
	ret			;d05d
SALTO:		; Disparo: dispara el salto y lleva su fisica
	call L_D259		;d05e
	ret z			;d061
	call CLASE_DE_CASILLA		;d062
	and a			;d065
	ret z			;d066
	ld hl,0dae1h		;d067
	call L_D986		;d06a
	ld bc,04000h		;d06d
	call L_DA7B		;d070
	ld a,003h		;d073
	ld (0db6dh),a		;d075
	call L_D096		;d078
	ld a,0edh		;d07b
	call L_DA85		;d07d
	ld a,024h		;d080
	ld (0db67h),a		;d082
	ld hl,020e9h		;d085
	ld (0db69h),hl		;d088
L_D08B:
	call L_D471		;d08b
	jp z,L_DA74		;d08e
	call FRAME		;d091
	jr L_D08B		;d094
L_D096:
	ld a,00ch		;d096
	ld (0db67h),a		;d098
	call PINTA_JUGADOR		;d09b
	ld b,004h		;d09e
	call L_D954		;d0a0
	ret			;d0a3
VUELCA_FONDO:		; Manda el fondo a VRAM 0x1800. El `and 0x3F` de la camara es lo que hace el parallax
	ld hl,0db7ah		;d0a4
	ld a,(0db54h)		;d0a7
	and 03fh		;d0aa
	push af			;d0ac
	call HL_MAS_A		;d0ad
	ld (0db61h),hl		;d0b0
	ld de,01800h		;d0b3
	ld (0db63h),de		;d0b6
	ld b,008h		;d0ba
L_D0BC:
	push bc			;d0bc
	ld bc,00020h		;d0bd
	ld a,(0db54h)		;d0c0
	and 03fh		;d0c3
	cp 021h			;d0c5
	jr c,L_D0D0		;d0c7
	and 01fh		;d0c9
	sub 020h		;d0cb
	neg			;d0cd
	ld c,a			;d0cf
L_D0D0:
	call COPIA_FILA		;d0d0
	pop bc			;d0d3
	djnz L_D0BC		;d0d4
	pop af			;d0d6
	cp 021h			;d0d7
	ret c			;d0d9
	and 01fh		;d0da
	sub 020h		;d0dc
	neg			;d0de
	ld c,a			;d0e0
	ld hl,01800h		;d0e1
	call HL_MAS_A		;d0e4
	ld de,0db7ah		;d0e7
	ex de,hl		;d0ea
	ld (0db61h),hl		;d0eb
	ld (0db63h),de		;d0ee
	sub 020h		;d0f2
	neg			;d0f4
	ld c,a			;d0f6
	ld (0db65h),bc		;d0f7
	ld b,008h		;d0fb
L_D0FD:
	push bc			;d0fd
	ld bc,(0db65h)		;d0fe
	call COPIA_FILA		;d102
	pop bc			;d105
	djnz L_D0FD		;d106
	ret			;d108
COPIA_FILA:		; Copia una fila a VRAM: origen +0x40 (64 columnas), destino +0x20 (32)
	call 0005ch		;d109   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld de,00040h		;d10c
	ld hl,(0db61h)		;d10f
	add hl,de		;d112
	ld (0db61h),hl		;d113
	push hl			;d116
	ld hl,(0db63h)		;d117
	sra e			;d11a
	add hl,de		;d11c
	ld (0db63h),hl		;d11d
	ex de,hl		;d120
	pop hl			;d121
	ret			;d122
HL_MAS_A:		; Utilidad: HL += A
	push de			;d123
	ld e,a			;d124
	ld d,000h		;d125
	add hl,de		;d127
	pop de			;d128
	ret			;d129
ANIMA_CASILLAS:		; Cada 8 frames avanza un fotograma las casillas especiales
	ld a,(0db75h)		;d12a
	and 007h		;d12d
	ret nz			;d12f
	ld hl,0dd79h		;d130
	ld de,0e57ah		;d133
L_D136:
	ld a,(de)		;d136
	cp 0ffh			;d137
	ret z			;d139
	call HL_MAS_A		;d13a
	ld a,(hl)		;d13d
	inc a			;d13e
	and 003h		;d13f
	ld b,a			;d141
	ld a,(hl)		;d142
	and 0fch		;d143
	or b			;d145
	ld (hl),a		;d146
	inc de			;d147
	jr L_D136		;d148
VUELCA_MAPA:		; Manda las 8 filas del mapa a VRAM 0x1900 con OTIR
	ld hl,018ffh		;d14a
	call 00050h		;d14d   ; BIOS SETRD - Enables VDP to read
	ld hl,0dd7ah		;d150
	ld a,(0db54h)		;d153
	call HL_MAS_A		;d156
	ld a,(00007h)		;d159
	ld c,a			;d15c
	ld b,008h		;d15d
L_D15F:
	push bc			;d15f
	ld b,020h		;d160
	push hl			;d162
	di			;d163
	otir			;d164
	pop hl			;d166
	inc h			;d167
	pop bc			;d168
	djnz L_D15F		;d169
	ei			;d16b
	jp L_D49A		;d16c
LEE_MANDO:		; GTSTCK: primero teclas de cursor, luego joystick 1
	xor a			;d16f
	call 000d5h		;d170   ; BIOS GTSTCK - Returns the joystick status
	and a			;d173
	ret nz			;d174
	inc a			;d175
	call 000d5h		;d176   ; BIOS GTSTCK - Returns the joystick status
	and a			;d179
	ret			;d17a
L_D17B:
	call LEE_MANDO		;d17b
	ld e,000h		;d17e
	ret z			;d180
	ld c,a			;d181
	and 003h		;d182
	cp 003h			;d184
	ret z			;d186
	inc e			;d187
	ld a,c			;d188
	and 004h		;d189
	ret z			;d18b
	dec e			;d18c
	dec e			;d18d
	ret			;d18e
L_D18F:
	cp 00ah			;d18f
	ret nc			;d191
	push hl			;d192
	push de			;d193
	ld hl,(0f3dch)		;d194
	call L_D1B6		;d197
	sla a			;d19a
	ld b,a			;d19c
	sla a			;d19d
	add a,b			;d19f
	add a,00bh		;d1a0
	ld b,003h		;d1a2
	ld de,0001fh		;d1a4
L_D1A7:
	call 0004dh		;d1a7   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;d1aa
	inc a			;d1ab
	call 0004dh		;d1ac   ; BIOS WRTVRM - Writes data in VRAM
	inc a			;d1af
	add hl,de		;d1b0
	djnz L_D1A7		;d1b1
	pop de			;d1b3
	pop hl			;d1b4
	ret			;d1b5
L_D1B6:
	push de			;d1b6
	ld e,h			;d1b7
	ld h,000h		;d1b8
	ld b,005h		;d1ba
L_D1BC:
	add hl,hl		;d1bc
	djnz L_D1BC		;d1bd
	ld d,000h		;d1bf
	add hl,de		;d1c1
	ld de,01800h		;d1c2
	add hl,de		;d1c5
	pop de			;d1c6
	ret			;d1c7
L_D1C8:
	ld hl,0db59h		;d1c8
	ld de,00b12h		;d1cb
	ld (0f3dch),de		;d1ce
	ld b,006h		;d1d2
L_D1D4:
	push bc			;d1d4
	ld a,(hl)		;d1d5
	bit 0,b			;d1d6
	jr z,L_D1E3		;d1d8
	srl a			;d1da
	srl a			;d1dc
	srl a			;d1de
	srl a			;d1e0
	inc hl			;d1e2
L_D1E3:
	and 00fh		;d1e3
	call L_D18F		;d1e5
	push hl			;d1e8
	ld hl,0f3ddh		;d1e9
	dec (hl)		;d1ec
	dec (hl)		;d1ed
	pop hl			;d1ee
	pop bc			;d1ef
	djnz L_D1D4		;d1f0
	ret			;d1f2
L_D1F3:
	inc (hl)		;d1f3
	inc (hl)		;d1f4
	ld hl,0db59h		;d1f5
	ld a,075h		;d1f8
	add a,(hl)		;d1fa
	daa			;d1fb
	ld (hl),a		;d1fc
	inc hl			;d1fd
	ld a,000h		;d1fe
	adc a,(hl)		;d200
	inc a			;d201
	inc a			;d202
	inc a			;d203
	daa			;d204
	ld (hl),a		;d205
	inc hl			;d206
	ld a,000h		;d207
	adc a,(hl)		;d209
	daa			;d20a
	ld (hl),a		;d20b
	ld hl,0dae1h		;d20c
	call L_D986		;d20f
	ld bc,00078h		;d212
	call L_DA7B		;d215
	ld a,00fh		;d218
	ld e,00ch		;d21a
	call 00093h		;d21c   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,002h		;d21f
	ld (0db6dh),a		;d221
	jp L_D1C8		;d224
LISTA_ESPECIALES:		; Recorre el mapa y arma en 0xE57A la lista de casillas animables, guardando distancias en vez de posiciones
	ld hl,0dd79h		;d227
	ld (0db61h),hl		;d22a
	ld de,0e57ah		;d22d
	ld bc,0e57ah		;d230
L_D233:
	inc hl			;d233
	push hl			;d234
	sbc hl,bc		;d235
	pop hl			;d237
	jr nc,L_D255		;d238
	ld a,(hl)		;d23a
	and 03fh		;d23b
	cp 018h			;d23d
	jr nc,L_D233		;d23f
	push de			;d241
	ld de,(0db61h)		;d242
	ld (0db61h),hl		;d246
	and a			;d249
	sbc hl,de		;d24a
	ld a,l			;d24c
	pop de			;d24d
	ld (de),a		;d24e
	inc de			;d24f
	ld hl,(0db61h)		;d250
	jr L_D233		;d253
L_D255:
	ex de,hl		;d255
	ld (hl),0ffh		;d256
	ret			;d258
L_D259:
	xor a			;d259
	call 000d8h		;d25a   ; BIOS GTTRIG - Returns current trigger status
	ld b,a			;d25d
	push bc			;d25e
	ld a,001h		;d25f
	call 000d8h		;d261   ; BIOS GTTRIG - Returns current trigger status
	pop bc			;d264
	or b			;d265
	ld b,a			;d266
	ld hl,0db58h		;d267
	ld a,(hl)		;d26a
	ld (hl),b		;d26b
	cpl			;d26c
	and b			;d26d
	ret			;d26e
L_D26F:
	call LEE_MANDO		;d26f
	ld d,000h		;d272
	dec a			;d274
	ret m			;d275
	ld c,a			;d276
	and 003h		;d277
	ret z			;d279
	inc d			;d27a
	ld a,c			;d27b
	and 004h		;d27c
	ret z			;d27e
	dec d			;d27f
	dec d			;d280
	ret			;d281
APLICA_VELOCIDAD:		; Izquierda/derecha cambian la VELOCIDAD (0xDB60), no la posicion
	call L_D26F		;d282
	ld hl,0db60h		;d285
	ld a,(hl)		;d288
	add a,d			;d289
	ret m			;d28a
	cp 027h			;d28b
	jr nc,L_D291		;d28d
	ld (hl),a		;d28f
	ret			;d290
L_D291:
	dec (hl)		;d291
	dec (hl)		;d292
	ret			;d293
APLICA_ALTURA:		; Arriba/abajo mueven en diagonal
	call L_D17B		;d294
	ld hl,0db56h		;d297
	ld a,(hl)		;d29a
	add a,e			;d29b
	cp 0b0h			;d29c
	ret nc			;d29e
	cp 071h			;d29f
	ret c			;d2a1
	ld (hl),a		;d2a2
	jp L_D2B3		;d2a3
AVANZA_CAMARA:		; Adelanta la columna de camara (0xDB54)
	ld a,(0db60h)		;d2a6
	ld hl,(0db53h)		;d2a9
	call HL_MAS_A		;d2ac
	ld (0db53h),hl		;d2af
	ret			;d2b2
L_D2B3:
	ld a,(0db56h)		;d2b3
	sub 0e0h		;d2b6
	neg			;d2b8
	ld (0db55h),a		;d2ba
	ret			;d2bd
DESCOMPRIME:		; Descompresor RLE de 16 bits. Destino fijo: el buffer 0xDD7A
	ld de,0dd7ah		;d2be
L_D2C1:
	ld c,(hl)		;d2c1
	inc hl			;d2c2
	ld b,(hl)		;d2c3
	inc hl			;d2c4
	bit 7,b			;d2c5
	jr z,L_D2DD		;d2c7
	ld a,0ffh		;d2c9
	cp b			;d2cb
	jr nz,L_D2D0		;d2cc
	cp c			;d2ce
	ret z			;d2cf
L_D2D0:
	res 7,b			;d2d0
	ld a,(hl)		;d2d2
	ld (de),a		;d2d3
	inc de			;d2d4
	dec bc			;d2d5
	ld a,c			;d2d6
	or b			;d2d7
	jr nz,L_D2D0		;d2d8
	inc hl			;d2da
	jr L_D2C1		;d2db
L_D2DD:
	ldir			;d2dd
	jr L_D2C1		;d2df
CLASE_DE_CASILLA:		; Calcula que casilla pisa el jugador y devuelve su clase (0..14)
	ld a,(0db55h)		;d2e1
	sub 030h		;d2e4
	srl a			;d2e6
	srl a			;d2e8
	srl a			;d2ea
	ld h,a			;d2ec
	ld a,(0db54h)		;d2ed
	ld l,a			;d2f0
	ld a,(0db56h)		;d2f1
	srl a			;d2f4
	srl a			;d2f6
	srl a			;d2f8
	add a,l			;d2fa
	ld l,a			;d2fb
	ld de,0dd7ah		;d2fc
	add hl,de		;d2ff
	ld (0db77h),hl		;d300
	ld a,(hl)		;d303
	and 03fh		;d304
	ld hl,0dacdh		;d306
	ld c,0ffh		;d309
L_D30B:
	inc hl			;d30b
	inc c			;d30c
	cp (hl)			;d30d
	jr nc,L_D30B		;d30e
	ld a,c			;d310
	ld hl,(0db77h)		;d311
	ret			;d314
COLISION:		; Despacha segun la clase de casilla: 9 casos distintos
	call CLASE_DE_CASILLA		;d315
	and a			;d318
	jp z,L_D3F7		;d319
	cp 006h			;d31c
	jp z,L_D429		;d31e
	cp 007h			;d321
	jp z,L_D1F3		;d323
	cp 001h			;d326
	jp z,L_D423		;d328
	cp 002h			;d32b
	jp z,L_D4C7		;d32d
	cp 00dh			;d330
	jp z,L_D4F9		;d332
	cp 00bh			;d335
	jp z,L_D526		;d337
	cp 00ah			;d33a
	jp z,L_D58F		;d33c
	cp 003h			;d33f
	jp z,L_D5D5		;d341
	ret			;d344
INTERRUPCION:		; Manejador propio, enganchado en H.TIMI. Cuenta frames y mueve el sonido
	in a,(099h)		;d345   ; Descarta la vuelta al manejador del BIOS y desapila a mano: interrupcion rapida
	pop hl			;d347
	di			;d348
	ld hl,0db75h		;d349
	inc (hl)		;d34c
	call SONIDO_FRAME		;d34d
	pop ix			;d350
	pop iy			;d352
	pop af			;d354
	pop bc			;d355
	pop de			;d356
	pop hl			;d357
	ex af,af'		;d358
	exx			;d359
	pop af			;d35a
	pop bc			;d35b
	pop de			;d35c
	pop hl			;d35d
	ei			;d35e
	ret			;d35f
PATRON_SEGUN_FRAME:		; Elige el fotograma de la animacion del protagonista
	ld a,(0db75h)		;d360
	and 00ch		;d363
	ld (0db67h),a		;d365
	ret			;d368
PINTA_JUGADOR:		; Monta los 3 planos de color del sprite y los escribe en los atributos
	ld iy,0daddh		;d369
	ld hl,0db6eh		;d36d
	ld b,003h		;d370
L_D372:
	ld a,(0db55h)		;d372
	ld c,a			;d375
	ld a,(0db57h)		;d376
	add a,c			;d379
	ld (iy+000h),a		;d37a
	ld a,(0db56h)		;d37d
	ld (iy+001h),a		;d380
	ld a,(0db67h)		;d383
	sub b			;d386
	add a,003h		;d387
	sla a			;d389
	sla a			;d38b
	ld (iy+002h),a		;d38d
	ld a,(hl)		;d390
	ld (iy+003h),a		;d391
	ld a,004h		;d394
	sub b			;d396
	call ESCRIBE_SPRITE		;d397
	inc hl			;d39a
	djnz L_D372		;d39b
	ret			;d39d
VUELVE_AL_TITULO:		; Desengancha la interrupcion, silencia el PSG y salta a 0xC000
	ld hl,0fd9fh		;d39e
	ld (hl),0c9h		;d3a1
	call 00090h		;d3a3   ; BIOS GICINI - Initialises PSG and sets initial value for the PLAY statement
	xor a			;d3a6
	jp 0c000h		;d3a7
PONE_REGISTROS_VDP:		; Escribe los 8 registros del VDP desde la tabla de 0xDAB2
	ld hl,0dab2h		;d3aa
	ld c,000h		;d3ad
L_D3AF:
	push bc			;d3af
	ld b,(hl)		;d3b0
	inc hl			;d3b1
	call 00047h		;d3b2   ; BIOS WRTVDP - Writes data in the VDP-register
	pop bc			;d3b5
	inc c			;d3b6
	ld a,c			;d3b7
	cp 008h			;d3b8
	ret z			;d3ba
	jr L_D3AF		;d3bb
CUENTA_ATRAS:		; Lleva el contador de tiempo de la partida
	ld hl,0db72h		;d3bd
	dec (hl)		;d3c0
	ret nz			;d3c1
	ld (hl),005h		;d3c2
	ld hl,0db5dh		;d3c4
	ld b,003h		;d3c7
	scf			;d3c9
L_D3CA:
	ld a,(hl)		;d3ca
	sbc a,000h		;d3cb
	ld (hl),a		;d3cd
	jr nc,L_D3D8		;d3ce
	ld (hl),009h		;d3d0
	inc hl			;d3d2
	djnz L_D3CA		;d3d3
	jp c,L_D4A3		;d3d5
L_D3D8:
	ld hl,01d12h		;d3d8
	ld (0f3dch),hl		;d3db
	ld hl,0f3ddh		;d3de
	ld de,0db5dh		;d3e1
	ld a,(de)		;d3e4
	call L_D18F		;d3e5
	dec (hl)		;d3e8
	dec (hl)		;d3e9
	dec (hl)		;d3ea
	inc de			;d3eb
	ld a,(de)		;d3ec
	call L_D18F		;d3ed
	dec (hl)		;d3f0
	dec (hl)		;d3f1
	inc de			;d3f2
	ld a,(de)		;d3f3
	jp L_D18F		;d3f4
L_D3F7:
	ld hl,(0db53h)		;d3f7
	ld de,00028h		;d3fa
	sbc hl,de		;d3fd
	ld (0db53h),hl		;d3ff
	ld a,(0db75h)		;d402
	and 002h		;d405
	ld (0db57h),a		;d407
	ld a,02ch		;d40a
	ld (0db67h),a		;d40c
	ld hl,0dae1h		;d40f
	call L_D986		;d412
	ld bc,003e8h		;d415
	call L_DA7B		;d418
	ld a,008h		;d41b
	ld (0db6dh),a		;d41d
	jp PINTA_JUGADOR		;d420
L_D423:
	ld a,(hl)		;d423
	and 03fh		;d424
	cp 00eh			;d426
	ret nz			;d428
L_D429:
	ld hl,020e9h		;d429
	ld (0db69h),hl		;d42c
	ld hl,0db60h		;d42f
	ld (hl),014h		;d432
	ld a,0ebh		;d434
	call L_DA85		;d436
	ld hl,0dae1h		;d439
	call L_D986		;d43c
	ld bc,00100h		;d43f
	call L_DA7B		;d442
	ld a,007h		;d445
	ld (0db6dh),a		;d447
L_D44A:
	ld hl,0db75h		;d44a
	bit 0,(hl)		;d44d
	call z,L_D471	;d44f
	jr z,L_D46A		;d452
	ld hl,0dabah		;d454
	ld a,(0db75h)		;d457
	sra a			;d45a
	and 007h		;d45c
	call HL_MAS_A		;d45e
	ld a,(hl)		;d461
	ld (0db67h),a		;d462
	call FRAME		;d465
	jr L_D44A		;d468
L_D46A:
	ld hl,0db68h		;d46a
	dec (hl)		;d46d
	jp L_D480		;d46e
L_D471:
	ld hl,0db6bh		;d471
	inc (hl)		;d474
	ld a,(hl)		;d475
	sra a			;d476
	sra a			;d478
	ld hl,0db57h		;d47a
	add a,(hl)		;d47d
	ld (hl),a		;d47e
	ret			;d47f
L_D480:
	ld a,(0db68h)		;d480
	cp 0ffh			;d483
	jp z,L_D4A3		;d485
	sla a			;d488
	sla a			;d48a
	neg			;d48c
	add a,013h		;d48e
	sla a			;d490
	sla a			;d492
	ld hl,01b2ah		;d494
	jp 0004dh		;d497   ; BIOS WRTVRM - Writes data in VRAM
L_D49A:
	ld a,(0db54h)		;d49a
	ld hl,01b31h		;d49d
	jp 0004dh		;d4a0   ; BIOS WRTVRM - Writes data in VRAM
L_D4A3:
	ld a,02ch		;d4a3
	ld (0db67h),a		;d4a5
	call PINTA_JUGADOR		;d4a8
	ld b,064h		;d4ab
	call L_D954		;d4ad
	ld hl,01b00h		;d4b0
	ld a,0c0h		;d4b3
	call 0004dh		;d4b5   ; BIOS WRTVRM - Writes data in VRAM
	ld hl,0bd00h		;d4b8
	ld de,01800h		;d4bb
	ld bc,00300h		;d4be
	call 0005ch		;d4c1   ; BIOS LDIRVM - Block transfers to VRAM from memory
	call VUELVE_AL_TITULO		;d4c4
L_D4C7:
	ld a,(hl)		;d4c7
	and 0c0h		;d4c8
	or 018h			;d4ca
	ld (hl),a		;d4cc
	call LISTA_ESPECIALES		;d4cd
	ld hl,0db5eh		;d4d0
	ld a,(hl)		;d4d3
	add a,002h		;d4d4
	daa			;d4d6
	push af			;d4d7
	and 00fh		;d4d8
	ld (hl),a		;d4da
	pop af			;d4db
	inc hl			;d4dc
	srl a			;d4dd
	srl a			;d4df
	srl a			;d4e1
	srl a			;d4e3
	add a,(hl)		;d4e5
	ld (hl),a		;d4e6
	ld hl,0dae1h		;d4e7
	call L_D986		;d4ea
	ld bc,00032h		;d4ed
	call L_DA7B		;d4f0
	ld a,001h		;d4f3
	ld (0db6dh),a		;d4f5
	ret			;d4f8
L_D4F9:
	ld a,028h		;d4f9
	ld (0db67h),a		;d4fb
	ld a,028h		;d4fe
	ld (0db60h),a		;d500
	ld a,(0db6dh)		;d503
	cp 006h			;d506
	jp z,PINTA_JUGADOR		;d508
	ld hl,0dae1h		;d50b
	call L_D986		;d50e
	ld bc,00046h		;d511
	call L_DA7B		;d514
	ld e,00ah		;d517
	ld a,008h		;d519
	call 00093h		;d51b   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,006h		;d51e
	ld (0db6dh),a		;d520
	jp PINTA_JUGADOR		;d523
L_D526:
	push hl			;d526
	ld hl,0dae1h		;d527
	call L_D986		;d52a
	ld bc,00200h		;d52d
	call L_DA7B		;d530
	ld a,001h		;d533
	ld (0db6dh),a		;d535
	pop hl			;d538
	ld a,(hl)		;d539
	and 001h		;d53a
	jr z,L_D53F		;d53c
	dec hl			;d53e
L_D53F:
	ld b,000h		;d53f
	ld (0db77h),hl		;d541
	call L_D56A		;d544
	ld a,0e6h		;d547
	call L_DA85		;d549
	ld a,03ch		;d54c
	ld (0db60h),a		;d54e
	call L_D471		;d551
	ld b,004h		;d554
	call L_D56A		;d556
	call L_D471		;d559
	ld a,028h		;d55c
	ld (0db67h),a		;d55e
	ld hl,020e9h		;d561
	ld (0db69h),hl		;d564
	jp L_D08B		;d567
L_D56A:
	ld hl,(0db77h)		;d56a
	dec h			;d56d
	ld a,(hl)		;d56e
	and 0c0h		;d56f
	or 02ah			;d571
	add a,b			;d573
	ld (hl),a		;d574
	inc hl			;d575
	inc a			;d576
	ld (hl),a		;d577
	dec l			;d578
	inc h			;d579
	inc a			;d57a
	ld (hl),a		;d57b
	inc hl			;d57c
	inc a			;d57d
	ld (hl),a		;d57e
	ld hl,020e1h		;d57f
	ld (0db69h),hl		;d582
	ld b,004h		;d585
L_D587:
	push bc			;d587
	call FRAME		;d588
	pop bc			;d58b
	djnz L_D587		;d58c
	ret			;d58e
L_D58F:
	ld hl,020edh		;d58f
	ld (0db69h),hl		;d592
	ld a,019h		;d595
	ld (0db75h),a		;d597
	ld a,038h		;d59a
	ld (0db67h),a		;d59c
	ld a,064h		;d59f
	ld (0db60h),a		;d5a1
	xor a			;d5a4
	ld (0db6dh),a		;d5a5
	ld hl,0db0ah		;d5a8
	call L_D986		;d5ab
L_D5AE:
	call FRAME		;d5ae
	ld bc,0ec01h		;d5b1
	call L_D8A0		;d5b4
	ld a,(0db75h)		;d5b7
	and a			;d5ba
	jr z,L_D5CA		;d5bb
	call CLASE_DE_CASILLA		;d5bd
	cp 001h			;d5c0
	jr z,L_D5CA		;d5c2
	cp 006h			;d5c4
	jr z,L_D5CA		;d5c6
	jr L_D5AE		;d5c8
L_D5CA:
	ld hl,01b00h		;d5ca
	ld a,0c0h		;d5cd
	call 0004dh		;d5cf   ; BIOS WRTVRM - Writes data in VRAM
	jp 00090h		;d5d2   ; BIOS GICINI - Initialises PSG and sets initial value for the PLAY statement
L_D5D5:
	ld a,(hl)		;d5d5
	and 0c0h		;d5d6
	or 019h			;d5d8
	ld (hl),a		;d5da
	call LISTA_ESPECIALES		;d5db
	ld hl,0dae1h		;d5de
	call L_D986		;d5e1
	ld bc,000ffh		;d5e4
	call L_DA7B		;d5e7
	ld a,005h		;d5ea
	ld (0db6dh),a		;d5ec
	ld a,(0db68h)		;d5ef
	cp 004h			;d5f2
	ret z			;d5f4
	inc a			;d5f5
	ld (0db68h),a		;d5f6
	jp L_D480		;d5f9
CARGA_GRAFICOS:		; Recorre una tabla de pares (origen comprimido, destino VRAM) hasta el 0x0000
	nop			;d5fc
	ld e,(hl)		;d5fd
	inc hl			;d5fe
	ld d,(hl)		;d5ff
	inc hl			;d600
	ld a,d			;d601
	or e			;d602
	ret z			;d603
	push hl			;d604
	ex de,hl		;d605
	call DESCOMPRIME		;d606
	pop hl			;d609
	ld e,(hl)		;d60a
	inc hl			;d60b
	ld d,(hl)		;d60c
	inc hl			;d60d
	push hl			;d60e
	ld bc,00800h		;d60f
	ld hl,0dd7ah		;d612
	di			;d615
	call 0005ch		;d616   ; BIOS LDIRVM - Block transfers to VRAM from memory
	pop hl			;d619
	jr CARGA_GRAFICOS		;d61a
CARGA_NIVEL:		; Trae mapa y fondo desde la pagina 0. Con el nivel 6 se acaba el juego
	ld a,(0db5ch)		;d61c
	cp 006h			;d61f
	jp z,0c000h		;d621   ; Nivel 6 = fin del juego: se vuelve a la pantalla de titulo
	ld l,000h		;d624   ; HL = nivel * 0x800: cada mapa ocupa 2048 bytes
	ld h,a			;d626
	sla h			;d627
	sla h			;d629
	sla h			;d62b
	push hl			;d62d
	call 0f00fh		;d62e   ; Conmuta la pagina 0 a RAM: los mapas estan debajo de la ROM del BIOS
	ld de,0dd7ah		;d631
	ld bc,00800h		;d634
	pop hl			;d637
	nop			;d638
	ldir			;d639
	ld a,(0db5ch)		;d63b
	add a,018h		;d63e
	ld h,a			;d640
	sla h			;d641
	ld l,000h		;d643
	ld de,0db7ah		;d645
	ld bc,00200h		;d648
	ldir			;d64b
	call 0f000h		;d64d   ; Devuelve la ROM del BIOS a la pagina 0
	nop			;d650
	nop			;d651
	nop			;d652
	nop			;d653
	ei			;d654
	xor a			;d655
	ld (0db57h),a		;d656
	ld (0db60h),a		;d659
	ld (0db6bh),a		;d65c
	ld a,050h		;d65f
	ld (0db55h),a		;d661
	ld a,004h		;d664
	ld (0db68h),a		;d666
	call L_D480		;d669
	call L_D958		;d66c
	ld hl,L_D000		;d66f
	ld (0db53h),hl		;d672
	call L_DA8D		;d675
	jp LISTA_ESPECIALES		;d678
EMPIEZA_PARTIDA:		; Inicializacion de la fase: pila, paginacion, interrupcion, graficos y marcador
	ld sp,0f37fh		;d67b
	push af			;d67e
	push hl			;d67f
	push de			;d680
	push bc			;d681
	call 0f000h		;d682
	pop bc			;d685
	pop de			;d686
	pop hl			;d687
	pop af			;d688
	nop			;d689
	nop			;d68a
	nop			;d68b
	nop			;d68c
	nop			;d68d
	nop			;d68e
	nop			;d68f
	nop			;d690
	nop			;d691
	nop			;d692
	nop			;d693
	nop			;d694
	nop			;d695
	nop			;d696
	nop			;d697
	nop			;d698
	nop			;d699
	nop			;d69a
	nop			;d69b
	nop			;d69c
	nop			;d69d
	nop			;d69e
	nop			;d69f
	nop			;d6a0
	nop			;d6a1
	nop			;d6a2
	nop			;d6a3
	nop			;d6a4
	nop			;d6a5
	nop			;d6a6
	nop			;d6a7
	nop			;d6a8
	nop			;d6a9
	nop			;d6aa
	nop			;d6ab
	nop			;d6ac
	nop			;d6ad
	nop			;d6ae
	ld hl,INTERRUPCION		;d6af
	ld (0fda0h),hl		;d6b2
	ld a,0c3h		;d6b5
	ld (0fd9fh),a		;d6b7
	call PONE_REGISTROS_VDP		;d6ba
	ld hl,01b00h		;d6bd
	ld a,0c0h		;d6c0
	call 0004dh		;d6c2   ; BIOS WRTVRM - Writes data in VRAM
	ld hl,0db17h		;d6c5
	call CARGA_GRAFICOS		;d6c8
	ld hl,04500h		;d6cb
	ld bc,00100h		;d6ce
	ld de,01a00h		;d6d1
	call 0005ch		;d6d4   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld hl,01b00h		;d6d7
	ld bc,00080h		;d6da
	ld a,0c0h		;d6dd
	call 00056h		;d6df   ; BIOS FILVRM - Fills VRAM with value
	ld hl,0dac2h		;d6e2
	ld de,01b28h		;d6e5
	ld bc,0000ch		;d6e8
	call 0005ch		;d6eb   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld ix,0db59h		;d6ee
	ld (ix+000h),000h	;d6f2
	ld (ix+001h),000h	;d6f6
	ld (ix+002h),000h	;d6fa
	ld a,090h		;d6fe
	ld (0db56h),a		;d700
	xor a			;d703
	ld (0db5ch),a		;d704
	call CARGA_NIVEL		;d707
BUCLE_PRINCIPAL:		; Tres instrucciones: reponer la pila, llamar a FRAME y rearmar la mascara
	ld sp,0f37fh		;d70a   ; La pila se repone en cada vuelta: los manejadores de colision saltan sin limpiarla
	call FRAME		;d70d
	ld hl,0e0ffh		;d710
	ld (0db69h),hl		;d713
	jr BUCLE_PRINCIPAL		;d716
L_D718:
	ld hl,0dd7bh		;d718
	ld de,0dd7ah		;d71b
	ld a,010h		;d71e
L_D720:
	ld (0db73h),a		;d720
	push bc			;d723
	push hl			;d724
	push de			;d725
	ldir			;d726
	ld a,0ffh		;d728
	bit 0,(ix+001h)		;d72a
	jr z,L_D73E		;d72e
	push de			;d730
	ld de,0979ah		;d731
	ld a,(0db74h)		;d734
	sbc hl,de		;d737
	call HL_MAS_A		;d739
	ld a,(hl)		;d73c
	pop de			;d73d
L_D73E:
	ld (de),a		;d73e
	pop hl			;d73f
	pop de			;d740
	pop bc			;d741
	ld a,020h		;d742
	call HL_MAS_A		;d744
	ex de,hl		;d747
	call HL_MAS_A		;d748
	ld a,(0db73h)		;d74b
	dec a			;d74e
	jr nz,L_D720		;d74f
	ld hl,0db74h		;d751
	inc (hl)		;d754
	ld hl,0dd7ah		;d755
	ld de,01800h		;d758
	ld bc,00200h		;d75b
	jp 0005ch		;d75e   ; BIOS LDIRVM - Block transfers to VRAM from memory
L_D761:
	ld sp,0f37fh		;d761
	ld a,(0db57h)		;d764
	and a			;d767
	jr z,L_D777		;d768
	halt			;d76a
	ld hl,0db56h		;d76b
	inc (hl)		;d76e
	call PINTA_JUGADOR		;d76f
	call L_D471		;d772
	jr L_D761		;d775
L_D777:
	halt			;d777
	call PATRON_SEGUN_FRAME		;d778
	call PINTA_JUGADOR		;d77b
	ld hl,0db56h		;d77e
	inc (hl)		;d781
	jr nz,L_D777		;d782
	call L_D964		;d784
	ld hl,04300h		;d787
	ld de,01800h		;d78a
	ld bc,00200h		;d78d
	call 0005ch		;d790   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld hl,0db35h		;d793
	call CARGA_GRAFICOS		;d796
	ld a,04fh		;d799
	ld (0db55h),a		;d79b
	xor a			;d79e
	ld (0db57h),a		;d79f
	ld hl,0daeeh		;d7a2
	call L_D986		;d7a5
L_D7A8:
	call PATRON_SEGUN_FRAME		;d7a8
	call PINTA_JUGADOR		;d7ab
	ld bc,07c05h		;d7ae
	call L_D8A0		;d7b1
	ld hl,0db56h		;d7b4
	inc (hl)		;d7b7
	halt			;d7b8
	ld a,(hl)		;d7b9
	cp 029h			;d7ba
	jr c,L_D7A8		;d7bc
	xor a			;d7be
	ld (0db67h),a		;d7bf
	ld a,0e8h		;d7c2
	ld (0db6bh),a		;d7c4
	ld a,003h		;d7c7
	ld (0db53h),a		;d7c9
	call L_D8BF		;d7cc
	ld a,004h		;d7cf
	ld (0db6dh),a		;d7d1
	ld hl,04300h		;d7d4
	ld de,0dd7ah		;d7d7
	ld bc,00200h		;d7da
	ldir			;d7dd
	xor a			;d7df
	ld (0db74h),a		;d7e0
L_D7E3:
	ld a,(0db74h)		;d7e3
	sub 010h		;d7e6
	jr z,L_D7FC		;d7e8
	neg			;d7ea
	ld b,a			;d7ec
	call L_D954		;d7ed
	ld bc,0000bh		;d7f0
	res 0,(ix+001h)		;d7f3
	call L_D718		;d7f7
	jr L_D7E3		;d7fa
L_D7FC:
	call L_D8D9		;d7fc
	ld hl,0dafdh		;d7ff
	call L_D986		;d802
	xor a			;d805
	ld (0db74h),a		;d806
	ld a,0f0h		;d809
	ld (0db6bh),a		;d80b
L_D80E:
	ld bc,0001fh		;d80e
	ld ix,0db69h		;d811
	set 0,(ix+001h)		;d815
	halt			;d819
	call L_D718		;d81a
	call L_D471		;d81d
	call PINTA_JUGADOR		;d820
	ld bc,07c05h		;d823
	call L_D8A0		;d826
	ld hl,01b11h		;d829
	call L_DA9B		;d82c
	ld a,(0db74h)		;d82f
	cp 00ch			;d832
	jr nz,L_D80E		;d834
	ld a,001h		;d836
	ld (0db53h),a		;d838
	call L_D8BF		;d83b
L_D83E:
	call PATRON_SEGUN_FRAME		;d83e
	call PINTA_JUGADOR		;d841
	ld bc,07c05h		;d844
	call L_D8A0		;d847
	ld hl,0db56h		;d84a
	inc (hl)		;d84d
	halt			;d84e
	jr nz,L_D83E		;d84f
	call L_DA74		;d851
	ld hl,01b10h		;d854
	ld bc,00010h		;d857
	xor a			;d85a
	call 00056h		;d85b   ; BIOS FILVRM - Fills VRAM with value
	ld hl,0db17h		;d85e
	call CARGA_GRAFICOS		;d861
	ld hl,0db5ch		;d864
	inc (hl)		;d867
	call CARGA_NIVEL		;d868
	halt			;d86b
	call VUELCA_FONDO		;d86c
	call VUELCA_MAPA		;d86f
L_D872:
	call PATRON_SEGUN_FRAME		;d872
	call PINTA_JUGADOR		;d875
	ld hl,0db56h		;d878
	inc (hl)		;d87b
	halt			;d87c
	ld a,(hl)		;d87d
	cp 090h			;d87e
	jr c,L_D872		;d880
	jp BUCLE_PRINCIPAL		;d882
ESCRIBE_SPRITE:		; Vuelca 4 bytes de atributo al sprite n
	push hl			;d885
	push bc			;d886
	push de			;d887
	sla a			;d888
	sla a			;d88a
	ld hl,01b00h		;d88c
	call HL_MAS_A		;d88f
	ex de,hl		;d892
	ld hl,0daddh		;d893
	ld bc,00004h		;d896
	call 0005ch		;d899   ; BIOS LDIRVM - Block transfers to VRAM from memory
	pop de			;d89c
	pop bc			;d89d
	pop hl			;d89e
	ret			;d89f
L_D8A0:
	ld a,(0db55h)		;d8a0
	ld d,a			;d8a3
	ld a,(0db57h)		;d8a4
	add a,d			;d8a7
	ld iy,0daddh		;d8a8
	ld (iy+000h),a		;d8ac
	ld a,(0db56h)		;d8af
	ld (iy+001h),a		;d8b2
	ld (iy+002h),b		;d8b5
	ld (iy+003h),c		;d8b8
	xor a			;d8bb
	jp ESCRIBE_SPRITE		;d8bc
L_D8BF:
	ld hl,0db56h		;d8bf
	ld a,(0db53h)		;d8c2
	add a,(hl)		;d8c5
	ld (hl),a		;d8c6
	call L_D471		;d8c7
	push af			;d8ca
	call PINTA_JUGADOR		;d8cb
	ld bc,07c05h		;d8ce
	call L_D8A0		;d8d1
	pop af			;d8d4
	ret z			;d8d5
	halt			;d8d6
	jr L_D8BF		;d8d7
L_D8D9:
	ld ix,0daddh		;d8d9
	ld (ix+001h),000h	;d8dd
	ld (ix+002h),06ch	;d8e1
	ld (ix+003h),005h	;d8e5
	ld (ix+000h),00ah	;d8e9
	ld a,004h		;d8ed
	call ESCRIBE_SPRITE		;d8ef
	ld (ix+000h),025h	;d8f2
	ld a,005h		;d8f6
	call ESCRIBE_SPRITE		;d8f8
	ld (ix+000h),02dh	;d8fb
	ld a,006h		;d8ff
	call ESCRIBE_SPRITE		;d901
	ld (ix+000h),016h	;d904
	ld a,007h		;d908
	call ESCRIBE_SPRITE		;d90a
L_D90D:
	ld b,004h		;d90d
	halt			;d90f
L_D910:
	push bc			;d910
	ld a,008h		;d911
	sub b			;d913
	call L_D920		;d914
	pop bc			;d917
	djnz L_D910		;d918
	call L_D259		;d91a
	ret nz			;d91d
	jr L_D90D		;d91e
L_D920:
	ld hl,01b00h		;d920
	push af			;d923
	sla a			;d924
	sla a			;d926
	call HL_MAS_A		;d928
	inc hl			;d92b
	push hl			;d92c
	ld a,006h		;d92d
	call 00096h		;d92f   ; BIOS RDPSG - Reads value from PSG-register
	pop hl			;d932
	sub 00fh		;d933
	ld e,a			;d935
	pop af			;d936
	sub 005h		;d937
	neg			;d939
	add a,e			;d93b
	ld e,a			;d93c
	call 0004ah		;d93d   ; BIOS RDVRM - Reads the content of VRAM
	add a,e			;d940
	jp c,0004dh		;d941   ; BIOS WRTVRM - Writes data in VRAM
	call 0004dh		;d944   ; BIOS WRTVRM - Writes data in VRAM
	ld a,r			;d947
	rrc a			;d949
	and 081h		;d94b
	add a,004h		;d94d
	inc hl			;d94f
	inc hl			;d950
	jp 0004dh		;d951   ; BIOS WRTVRM - Writes data in VRAM
L_D954:
	halt			;d954
	djnz L_D954		;d955
	ret			;d957
L_D958:
	ld hl,0db5dh		;d958
	ld (hl),000h		;d95b
	inc hl			;d95d
	ld (hl),000h		;d95e
	inc hl			;d960
	ld (hl),003h		;d961
	ret			;d963
L_D964:
	call CUENTA_ATRAS		;d964
	ld a,(0db5dh)		;d967
	and a			;d96a
	jr nz,L_D964		;d96b
	ld hl,00000h		;d96d
	call L_D1F3		;d970
	xor a			;d973
	ld ix,0db5dh		;d974
	or (ix+000h)		;d978
	or (ix+001h)		;d97b
	or (ix+002h)		;d97e
	ret z			;d981
	halt			;d982
	halt			;d983
	jr L_D964		;d984
L_D986:
	ld a,(hl)		;d986
	cp 0ffh			;d987
	ret z			;d989
	inc hl			;d98a
	ld e,(hl)		;d98b
	inc hl			;d98c
	call 00093h		;d98d   ; BIOS WRTPSG - Writes data to PSG-register
	jr L_D986		;d990
SONIDO_FRAME:		; Motor de efectos del PSG, llamado desde la interrupcion
	ld a,(0db6dh)		;d992
	and a			;d995
	ret z			;d996
	cp 001h			;d997
	jp z,L_D9C0		;d999
	cp 002h			;d99c
	jp z,L_D9E2		;d99e
	cp 003h			;d9a1
	jp z,L_D9F4		;d9a3
	cp 004h			;d9a6
	jp z,L_DA0A		;d9a8
	cp 005h			;d9ab
	jp z,L_DA28		;d9ad
	cp 006h			;d9b0
	jp z,L_DA37		;d9b2
	cp 007h			;d9b5
	jp z,L_DA56		;d9b7
	cp 008h			;d9ba
	jp z,L_DA63		;d9bc
	ret			;d9bf
L_D9C0:
	ld a,(0db75h)		;d9c0
	xor a			;d9c3
	call 00096h		;d9c4   ; BIOS RDPSG - Reads value from PSG-register
	ld l,a			;d9c7
	ld a,001h		;d9c8
	call 00096h		;d9ca   ; BIOS RDPSG - Reads value from PSG-register
	ld h,a			;d9cd
	and a			;d9ce
	ld de,00014h		;d9cf
	sbc hl,de		;d9d2
	jp c,L_DA74		;d9d4
	xor a			;d9d7
	ld e,l			;d9d8
	call 00093h		;d9d9   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,001h		;d9dc
	ld e,h			;d9de
	jp 00093h		;d9df   ; BIOS WRTPSG - Writes data to PSG-register
L_D9E2:
	xor a			;d9e2
	call 00096h		;d9e3   ; BIOS RDPSG - Reads value from PSG-register
	ld b,a			;d9e6
	srl b			;d9e7
	sub b			;d9e9
	cp 001h			;d9ea
	jp z,L_DA74		;d9ec
	ld e,a			;d9ef
	xor a			;d9f0
	jp 00093h		;d9f1   ; BIOS WRTPSG - Writes data to PSG-register
L_D9F4:
	ld a,(0db57h)		;d9f4
	sla a			;d9f7
	ld hl,04000h		;d9f9
	call HL_MAS_A		;d9fc
	ld e,l			;d9ff
	xor a			;da00
	call 00093h		;da01   ; BIOS WRTPSG - Writes data to PSG-register
	ld e,h			;da04
	inc a			;da05
	ld e,h			;da06
	jp 00093h		;da07   ; BIOS WRTPSG - Writes data to PSG-register
L_DA0A:
	ld a,(0db75h)		;da0a
	and 007h		;da0d
	ret nz			;da0f
	xor a			;da10
	call 00096h		;da11   ; BIOS RDPSG - Reads value from PSG-register
	dec a			;da14
	cp 032h			;da15
	ret c			;da17
	ld e,a			;da18
	xor a			;da19
	call 00093h		;da1a   ; BIOS WRTPSG - Writes data to PSG-register
	sra e			;da1d
	sra e			;da1f
	sra e			;da21
	ld a,006h		;da23
	jp 00093h		;da25   ; BIOS WRTPSG - Writes data to PSG-register
L_DA28:
	ld a,000h		;da28
	call 00096h		;da2a   ; BIOS RDPSG - Reads value from PSG-register
	sub 01eh		;da2d
	jp c,L_DA74		;da2f
	ld e,a			;da32
	xor a			;da33
	jp 00093h		;da34   ; BIOS WRTPSG - Writes data to PSG-register
L_DA37:
	call CLASE_DE_CASILLA		;da37
	cp 00dh			;da3a
	jp nz,L_DA74		;da3c
	xor a			;da3f
	call 00096h		;da40   ; BIOS RDPSG - Reads value from PSG-register
	ld e,a			;da43
	inc e			;da44
	inc e			;da45
	xor a			;da46
	ld hl,0db75h		;da47
	bit 2,(hl)		;da4a
	jp z,00093h		;da4c   ; BIOS WRTPSG - Writes data to PSG-register
	dec e			;da4f
	dec e			;da50
	dec e			;da51
	dec e			;da52
	jp 00093h		;da53   ; BIOS WRTPSG - Writes data to PSG-register
L_DA56:
	ld a,r			;da56
	ld b,a			;da58
	xor a			;da59
	call 00096h		;da5a   ; BIOS RDPSG - Reads value from PSG-register
	sub b			;da5d
	ld e,a			;da5e
	xor a			;da5f
	jp 00093h		;da60   ; BIOS WRTPSG - Writes data to PSG-register
L_DA63:
	call CLASE_DE_CASILLA		;da63
	and a			;da66
	jp nz,L_DA74		;da67
	ld a,r			;da6a
	and 00fh		;da6c
	ld e,a			;da6e
	ld a,008h		;da6f
	jp 00093h		;da71   ; BIOS WRTPSG - Writes data to PSG-register
L_DA74:
	xor a			;da74
	ld (0db6dh),a		;da75
	jp 00090h		;da78   ; BIOS GICINI - Initialises PSG and sets initial value for the PLAY statement
L_DA7B:
	xor a			;da7b
	ld e,c			;da7c
	call 00093h		;da7d   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;da80
	ld e,b			;da81
	jp 00093h		;da82   ; BIOS WRTPSG - Writes data to PSG-register
L_DA85:
	ld (0db6bh),a		;da85
	xor a			;da88
	ld (0db57h),a		;da89
	ret			;da8c
L_DA8D:
	ld hl,0db54h		;da8d
	dec (hl)		;da90
	ret z			;da91
	halt			;da92
	call VUELCA_MAPA		;da93
	call VUELCA_FONDO		;da96
	jr L_DA8D		;da99
L_DA9B:
	call 0004ah		;da9b   ; BIOS RDVRM - Reads the content of VRAM
	sub 008h		;da9e
	call 0004dh		;daa0   ; BIOS WRTVRM - Writes data in VRAM
	ld a,004h		;daa3
	call HL_MAS_A		;daa5
	ld de,01b20h		;daa8
	and a			;daab
	sbc hl,de		;daac
	ret nc			;daae
	add hl,de		;daaf
	jr L_DA9B		;dab0

; ----------------------------------------------------------------------
; DATOS registros_vdp: Los 8 registros del VDP: 02 62 06 ff 03 36 07 01. R0/R1 = SCREEN 2 con sprites de 16x16; R2 = nombres en 0x1800; R5 = atributos de sprite en 0x1B00; R6 = patrones de sprite en 0x3800
;   0xdab2..0xdaba  (8 bytes)
; DATOS tabla_DABA: 8 bytes (10 10 10 10 14 18 1C 20) que lee 0xD454. Van creciendo: tiene pinta de tabla de tiempos o de fuerza del salto
;   0xdaba..0xdac2  (8 bytes)
; DATOS sprites_fijos: 12 bytes que 0xD6E2 vuelca a VRAM 0x1B28: los atributos de los sprites 10, 11 y 12 (Y, X, patron, color cada uno)
;   0xdac2..0xdace  (12 bytes)
; DATOS umbrales_casilla: Los 15 umbrales que convierten los 6 bits bajos de una casilla en su clase de terreno: 0C 10 14 18 19 1A 20 22 24 26 28 32 38 3E FF. El puntero se carga en 0xDACD y la comparacion empieza con un `inc hl`, por eso el primer umbral util es este
;   0xdace..0xdadd  (15 bytes)
; DATOS buffer_sprite: Los 4 bytes de atributo que PINTA_JUGADOR monta y ESCRIBE_SPRITE vuelca: Y, X, patron y color
;   0xdadd..0xdae1  (4 bytes)
; DATOS tabla_DAE1: 13 bytes, la tabla mas usada de la zona (8 referencias, desde 0xD067 y 0xD20C entre otras)
;   0xdae1..0xdaee  (13 bytes)
; DATOS tabla_DAEE: 15 bytes que lee 0xD7A2, dentro de la secuencia de intro
;   0xdaee..0xdafd  (15 bytes)
; DATOS tabla_DAFD: 13 bytes que lee 0xD7FF, tambien en la intro
;   0xdafd..0xdb0a  (13 bytes)
; DATOS tabla_DB0A: 13 bytes que lee 0xD5A8
;   0xdb0a..0xdb17  (13 bytes)
; DATOS tabla_graficos_A: Juego de graficos del JUEGO: pares (origen comprimido, destino VRAM), terminados en 0x0000
;   0xdb17..0xdb35  (30 bytes)
; DATOS tabla_graficos_B: Juego de graficos de la PRESENTACION. Comparte con el A el tercio 2 y los sprites
;   0xdb35..0xdb53  (30 bytes)
; DATOS variables_partida: Las variables de la partida, 39 bytes. Identificadas por quien las toca: 0xDB53 puntero de 16 bits; 0xDB54 COLUMNA DE CAMARA (el scroll); 0xDB55 Y del jugador; 0xDB56 X del jugador; 0xDB57 desplazamiento vertical del salto; 0xDB59 marcador; 0xDB5C NIVEL en curso (0..5); 0xDB5D cuenta atras; 0xDB60 VELOCIDAD (0..0x26); 0xDB61 y 0xDB63 punteros de volcado a VRAM; 0xDB67 fotograma del sprite; 0xDB68 VIDAS (empieza en 4); 0xDB69 MASCARA DE TAREAS de 16 bits que gobierna la rutina de frame; 0xDB6E-0xDB70 los tres colores del sprite (01 0F 0B: negro, blanco y amarillo claro); 0xDB75 contador de frames que lleva la interrupcion; 0xDB77 direccion de la casilla que pisa el jugador
;   0xdb53..0xdb7a  (39 bytes)
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; ############################################################
; DATOS DEL MOTOR (200 bytes, no se ejecutan nunca)
; ############################################################
; ----------------------------------------------------------------------
	defb 002h,062h,006h,0ffh,003h,036h,007h,001h,010h,010h,010h,010h,014h,018h,01ch,020h	; dab2  .b...6......... 
	defb 098h,08ch,00ch,001h,093h,090h,05ch,009h,0b3h,000h,06ch,00fh,00ch,010h,014h,018h	; dac2  ......\...l.....
	defb 019h,01ah,020h,022h,024h,026h,028h,032h,038h,03eh,0ffh,000h,000h,000h,000h,007h	; dad2  .. "$&(28>......
	defb 0fch,001h,004h,008h,010h,00dh,009h,00ch,046h,000h,001h,0ffh,007h,0f6h,008h,010h	; dae2  ........F.......
	defb 000h,07fh,001h,000h,006h,00fh,00dh,00dh,00ch,046h,0ffh,007h,0f7h,006h,01fh,001h	; daf2  .........F......
	defb 00ah,008h,010h,00ch,028h,00dh,009h,0ffh,007h,0feh,001h,028h,008h,010h,00bh,0c8h	; db02  ....(......(....
	defb 00ch,000h,00dh,008h,0ffh,000h,048h,000h,000h,0e2h,04ch,000h,020h,048h,051h,000h	; db12  ......H...L. HQ.
	defb 008h,0e9h,058h,000h,028h,0eeh,05fh,000h,010h,0c9h,066h,000h,030h,093h,082h,000h	; db22  ..X.(._...f.0...
	defb 038h,000h,000h,035h,06dh,000h,000h,037h,071h,000h,020h,0cfh,074h,000h,008h,0e9h	; db32  8..5m..7q. .t...
	defb 07bh,000h,028h,0eeh,05fh,000h,010h,0c9h,066h,000h,030h,093h,082h,000h,038h,000h	; db42  {.(._...f.0...8.
	defb 000h,000h,000h,060h,080h,000h,000h,000h,000h,000h,000h,000h,005h,004h,000h,000h	; db52  ...`............
	defb 000h,000h,000h,000h,000h,000h,004h,000h,000h,000h,000h,000h,001h,00fh,00bh,000h	; db62  ................
	defb 001h,000h,000h,000h,000h,000h,000h,0ffh	; db72  ........
