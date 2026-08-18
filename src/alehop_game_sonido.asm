; ==========================================================================
; ALE HOP! - MSX - juego, trozo 'sonido' (se ejecuta en 0xB000)
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0b000


; ----------------------------------------------------------------------
; DATOS isr_sin_usar: Manejador de interrupcion de la libreria de sonido,
;   inalcanzable
;   0xb000..0xb015  (21 bytes)

; ----------------------------------------------------------------------
; ------------------------------------------------------------
; CODIGO MUERTO: manejador de interrupcion de la libreria de
; sonido, 21 bytes que no ejecuta nadie.
; Desensambla limpiamente y tiene toda la pinta de ser el bueno:
; di / pop hl / call 0xB036 / pop ix / pop iy / pop af /
; pop bc / pop de / pop hl / ex af,af' / exx /
; pop af / pop bc / pop de / pop hl / ei / ret
; Es la misma "interrupcion rapida" que usan 0xC105 y 0xD345.
; Pero este juego no lo usa: engancha sus propios manejadores,
; que llaman a 0xB036 por su cuenta. Buscado en todo el binario
; el puntero 00 B0 y no aparece ni una vez en zona de codigo o
; de tablas. Es la entrada estandar de la libreria, que aqui se
; quedo sin usar.
; NO se integra como codigo a proposito: que algo desensamble
; bien no prueba que se ejecute.
; ------------------------------------------------------------
; ----------------------------------------------------------------------
DATA_isr_sin_usar:
	defb 0f3h,0e1h,0cdh,036h,0b0h,0ddh,0e1h,0fdh,0e1h,0f1h,0c1h,0d1h,0e1h,008h,0d9h,0f1h	; b000  ...6............
	defb 0c1h,0d1h,0e1h,0fbh,0c9h	; b010

; ======================================================================
; CODIGO 0xb015..0xb3c6  (945 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; REPRODUCTOR DE MUSICA
; ############################################################
; Cada canal lleva su puntero dentro de la melodia en un bloque
; de variables indexado por IX. Se lee un byte:
; < 0x80  -> es una NOTA: se busca su periodo en la tabla de
; 0xB3C6 y se programa el canal
; >= 0x80 -> es un COMANDO: se le resta 0x80 y se salta al
; manejador que diga la tabla de 0xB486
; ----------------------------------------------------------------------
ASIGNA_MELODIA:		; Pone la melodia DE en el canal A: le busca su bloque de 46 bytes, lo borra y guarda el puntero
	di			;b015
	push af			;b016
	push de			;b017
	ld de,0002eh		;b018   ; 46 bytes por canal: es el tamano del bloque de estado
	call MULTIPLICA		;b01b
	ld de,0b4abh		;b01e   ; Los tres bloques empiezan en 0xB4AB
	add hl,de			;b021
	push hl			;b022
	xor a			;b023
	ld b,02eh		;b024   ; Borra el bloque entero antes de empezar la melodia
L_B026:
	ld (hl),a			;b026
	inc hl			;b027
	djnz L_B026		;b028
	pop hl			;b02a
	pop de			;b02b
	ld (hl),e			;b02c   ; Guarda el puntero de la melodia por duplicado: uno avanza y el otro sirve para repetir
	inc hl			;b02d
	ld (hl),d			;b02e
	inc hl			;b02f
	ld (hl),e			;b030
	inc hl			;b031
	ld (hl),d			;b032
	pop af			;b033
	ei			;b034
	ret			;b035
SONIDO_FRAME:		; Una vuelta del reproductor, para los 3 canales; la llama la interrupcion
	push af			;b036
	ld b,003h		;b037   ; Los tres canales del PSG
	xor a			;b039
	ld ix,0b4abh		;b03a   ; Bloque de estado del canal 0; se avanza de 46 en 46 bytes
	ld de,0b4a0h		;b03e   ; En el buffer, la parte de los periodos (registros 0 a 5)
	ld hl,0b4a8h		;b041   ; Y aqui la de los volumenes (registros 8 a 10)
L_B044:
	push af			;b044   ; Vuelta por canal: se entra tres veces, con A = 0, 1 y 2
	push hl			;b045
	push de			;b046
	push bc			;b047
	ld (0b49eh),a		;b048
	ld a,(ix+004h)		;b04b   ; Si al canal le queda duracion pendiente no se lee nota nueva
	or (ix+005h)		;b04e
	jp nz,L_B0A9		;b051
	xor a			;b054
	call PSG_ESCRIBE		;b055
	ld c,(ix+002h)		;b058   ; El puntero de la melodia, en el bloque del canal
	ld b,(ix+003h)		;b05b
	ld a,b			;b05e
	or c			;b05f
	jp z,L_B162		;b060   ; Puntero a cero: este canal esta parado
L_B063:
	ld a,(bc)			;b063   ; Lee el siguiente byte de la melodia
	cp 080h		;b064   ; Menos de 0x80 es nota; 0x80 o mas es comando
	jp c,L_B072		;b066
	sub 080h		;b069
	ld hl,0b486h		;b06b   ; Tabla de saltos de los 12 comandos
	call INDEXA_TABLA		;b06e
	jp (hl)			;b071   ; Salto indirecto: aqui es donde se despacha cada comando
L_B072:
	ld hl,0b3c6h		;b072   ; Tabla de periodos de las notas
	call INDEXA_TABLA		;b075
	ld (ix+00ah),l		;b078
	ld (ix+00bh),h		;b07b
	inc bc			;b07e
L_B07F:
	ld a,(ix+008h)		;b07f
	call PSG_ESCRIBE		;b082
	call L_B1DE		;b085
	ld (ix+02ah),000h		;b088
	call L_B1F6		;b08c
	ld (ix+02bh),000h		;b08f
	ld (ix+02ch),000h		;b093
L_B097:
	ld (ix+002h),c		;b097
	ld (ix+003h),b		;b09a
	ld l,(ix+006h)		;b09d
	ld h,(ix+007h)		;b0a0
	ld (ix+004h),l		;b0a3
	ld (ix+005h),h		;b0a6
L_B0A9:
	ld l,(ix+004h)		;b0a9
	ld h,(ix+005h)		;b0ac
	dec hl			;b0af
	ld (ix+004h),l		;b0b0
	ld (ix+005h),h		;b0b3
	push ix		;b0b6
	pop iy		;b0b8
	ld d,002h		;b0ba
	ld c,000h		;b0bc
L_B0BE:
	ld a,(iy+00ch)		;b0be
	or a			;b0c1
	jr z,L_B0CB		;b0c2
	dec a			;b0c4
	ld (iy+00ch),a		;b0c5
	inc c			;b0c8
	jr L_B0EC		;b0c9
L_B0CB:
	ld a,(iy+00eh)		;b0cb
	or a			;b0ce
	jr z,L_B0E7		;b0cf
	dec a			;b0d1
	ld (iy+00eh),a		;b0d2
	ld a,(ix+02ah)		;b0d5
	add a,(iy+01bh)		;b0d8
	ld (ix+02ah),a		;b0db
	ld a,(iy+020h)		;b0de
	ld (iy+00ch),a		;b0e1
	inc c			;b0e4
	jr L_B0EC		;b0e5
L_B0E7:
	inc iy		;b0e7
	dec d			;b0e9
	jr nz,L_B0BE		;b0ea
L_B0EC:
	ld a,c			;b0ec
	or a			;b0ed
	jr nz,L_B0F7		;b0ee
	bit 0,(ix+02dh)		;b0f0
	call nz,L_B1DE		;b0f4
L_B0F7:
	push ix		;b0f7
	pop iy		;b0f9
	ld d,003h		;b0fb
	ld c,000h		;b0fd
L_B0FF:
	ld a,(iy+010h)		;b0ff
	or a			;b102
	jr z,L_B10C		;b103
	dec a			;b105
	ld (iy+010h),a		;b106
	inc c			;b109
	jr L_B157		;b10a
L_B10C:
	ld a,(iy+013h)		;b10c
	or a			;b10f
	jr z,L_B152		;b110
	dec a			;b112
	ld (iy+013h),a		;b113
	ld a,(iy+01dh)		;b116
	or a			;b119
	jp p,L_B136		;b11a
	ld a,(iy+01dh)		;b11d
	cpl			;b120
	inc a			;b121
	ld e,a			;b122
	ld a,(ix+02bh)		;b123
	sub e			;b126
	ld (ix+02bh),a		;b127
	ld a,(ix+02ch)		;b12a
	sbc a,000h		;b12d
	and 00fh		;b12f
	ld (ix+02ch),a		;b131
	jr L_B149		;b134
L_B136:
	ld a,(ix+02bh)		;b136
	add a,(iy+01dh)		;b139
	ld (ix+02bh),a		;b13c
	ld a,(ix+02ch)		;b13f
	adc a,000h		;b142
	and 00fh		;b144
	ld (ix+02ch),a		;b146
L_B149:
	ld a,(iy+022h)		;b149
	ld (iy+010h),a		;b14c
	inc c			;b14f
	jr L_B157		;b150
L_B152:
	inc iy		;b152
	dec d			;b154
	jr nz,L_B0FF		;b155
L_B157:
	ld a,c			;b157
	or a			;b158
	jr nz,L_B162		;b159
	bit 1,(ix+02dh)		;b15b
	call nz,L_B1F6		;b15f
L_B162:
	pop bc			;b162
	pop de			;b163
	pop hl			;b164
	ld a,(ix+009h)		;b165   ; Volumen del canal mas su ajuste, recortado a 4 bits
	add a,(ix+02ah)		;b168
	and 00fh		;b16b
	ld (hl),a			;b16d
	ld a,(ix+00ah)		;b16e   ; Periodo del tono, 16 bits, con su ajuste sumado con acarreo
	add a,(ix+02bh)		;b171
	ld (de),a			;b174
	inc de			;b175
	ld a,(ix+00bh)		;b176
	adc a,(ix+02ch)		;b179
	ld (de),a			;b17c
	inc de			;b17d
	push de			;b17e
	ld de,0002eh		;b17f   ; Salta al bloque del canal siguiente
	add ix,de		;b182
	pop de			;b184
	pop af			;b185
	inc a			;b186
	inc hl			;b187
	dec b			;b188
	jp nz,L_B044		;b189
	ld iy,0b535h		;b18c   ; Ya estan los tres canales; ahora los efectos globales
	ld d,002h		;b190
	ld c,000h		;b192
L_B194:
	ld a,(iy+000h)		;b194
	or a			;b197
	jr z,L_B1A1		;b198
	dec a			;b19a
	ld (iy+000h),a		;b19b
	inc c			;b19e
	jr L_B1C2		;b19f
L_B1A1:
	ld a,(iy+002h)		;b1a1
	or a			;b1a4
	jr z,L_B1BD		;b1a5
	dec a			;b1a7
	ld (iy+002h),a		;b1a8
	ld a,(0b541h)		;b1ab
	add a,(iy+006h)		;b1ae
	ld (0b541h),a		;b1b1
	ld a,(iy+008h)		;b1b4
	ld (iy+000h),a		;b1b7
	inc c			;b1ba
	jr L_B1C2		;b1bb
L_B1BD:
	inc iy		;b1bd
	dec d			;b1bf
	jr nz,L_B194		;b1c0
L_B1C2:
	ld a,c			;b1c2
	or a			;b1c3
	jr nz,L_B1CE		;b1c4
	ld a,(0b53fh)		;b1c6
	bit 2,a		;b1c9
	call nz,L_B20E		;b1cb
L_B1CE:
	ld a,(0b540h)		;b1ce
	ld e,a			;b1d1
	ld a,(0b541h)		;b1d2
	add a,e			;b1d5
	ld (0b4a6h),a		;b1d6
	call VUELCA_PSG		;b1d9
	pop af			;b1dc
	ret			;b1dd
L_B1DE:
	push ix		;b1de
	ld d,002h		;b1e0
L_B1E2:
	ld a,(ix+020h)		;b1e2
	ld (ix+00ch),a		;b1e5
	ld a,(ix+016h)		;b1e8
	ld (ix+00eh),a		;b1eb
	inc ix		;b1ee
	dec d			;b1f0
	jr nz,L_B1E2		;b1f1
	pop ix		;b1f3
	ret			;b1f5
L_B1F6:
	ld d,003h		;b1f6
	push ix		;b1f8
L_B1FA:
	ld a,(ix+022h)		;b1fa
	ld (ix+010h),a		;b1fd
	ld a,(ix+018h)		;b200
	ld (ix+013h),a		;b203
	inc ix		;b206
	dec d			;b208
	jr nz,L_B1FA		;b209
	pop ix		;b20b
	ret			;b20d
L_B20E:
	ld d,002h		;b20e
	push iy		;b210
	ld iy,0b535h		;b212
L_B216:
	ld a,(iy+008h)		;b216
	ld (iy+000h),a		;b219
	ld a,(iy+004h)		;b21c
	ld (iy+002h),a		;b21f
	inc iy		;b222
	dec d			;b224
	jr nz,L_B216		;b225
	pop iy		;b227
	ret			;b229
L_B22A:
	inc bc			;b22a
	ld a,(bc)			;b22b
	ld (ix+009h),a		;b22c
	inc bc			;b22f
	jp L_B063		;b230
L_B233:
	inc bc			;b233
	ld a,(bc)			;b234
	ld de,(0b49fh)		;b235
	ld d,000h		;b239
	call MULTIPLICA		;b23b
	ld (ix+006h),l		;b23e
	ld (ix+007h),h		;b241
	inc bc			;b244
	jp L_B063		;b245
L_B248:
	inc bc			;b248
	ld a,(bc)			;b249
	and 009h		;b24a
	ld (ix+008h),a		;b24c
	inc bc			;b24f
	jp L_B063		;b250
L_B253:
	push bc			;b253
	push ix		;b254
	pop hl			;b256
	xor a			;b257
	ld b,02eh		;b258
L_B25A:
	ld (hl),a			;b25a
	inc hl			;b25b
	djnz L_B25A		;b25c
	pop bc			;b25e
	jp L_B162		;b25f
L_B262:
	inc bc			;b262
	ld a,(bc)			;b263
	push bc			;b264
	ld de,00010h		;b265
	call MULTIPLICA		;b268
	ld bc,00bb8h		;b26b
	push hl			;b26e
	pop de			;b26f
	call L_B38A		;b270
	ld a,c			;b273
	ld (0b49fh),a		;b274
	pop bc			;b277
	inc bc			;b278
	jp L_B063		;b279
L_B27C:
	inc bc			;b27c
	ld a,(bc)			;b27d
	push af			;b27e
	and 01fh		;b27f
	ld (0b540h),a		;b281
	call L_B20E		;b284
	pop af			;b287
	inc bc			;b288
	or a			;b289
	jp m,L_B063		;b28a
	jp L_B07F		;b28d
L_B290:
	inc bc			;b290
	jp L_B097		;b291
L_B294:
	ld c,(ix+000h)		;b294
	ld b,(ix+001h)		;b297
	ld (ix+002h),c		;b29a
	ld (ix+003h),b		;b29d
	jp L_B063		;b2a0
L_B2A3:
	inc bc			;b2a3
	ld a,(bc)			;b2a4
	inc bc			;b2a5
	ld de,00000h		;b2a6
L_B2A9:
	push af			;b2a9
	ld a,(bc)			;b2aa
	push de			;b2ab
	ld de,(0b49fh)		;b2ac
	ld d,000h		;b2b0
	call MULTIPLICA		;b2b2
	pop de			;b2b5
	add hl,de			;b2b6
	ex de,hl			;b2b7
	inc bc			;b2b8
	pop af			;b2b9
	dec a			;b2ba
	jr nz,L_B2A9		;b2bb
	ld (ix+006h),l		;b2bd
	ld (ix+007h),h		;b2c0
	jp L_B063		;b2c3
L_B2C6:
	inc bc			;b2c6
	ld a,(bc)			;b2c7
	ld e,a			;b2c8
	or (ix+02dh)		;b2c9
	ld (ix+02dh),a		;b2cc
	ld a,(0b53fh)		;b2cf
	or e			;b2d2
	ld (0b53fh),a		;b2d3
	inc bc			;b2d6
	jp L_B063		;b2d7
L_B2DA:
	inc bc			;b2da
	res 0,(ix+02dh)		;b2db
	res 1,(ix+02dh)		;b2df
	ld a,(bc)			;b2e3
	ld de,0000fh		;b2e4
	call MULTIPLICA		;b2e7
	ld de,0b542h		;b2ea
	add hl,de			;b2ed
	push ix		;b2ee
	ld d,00fh		;b2f0
L_B2F2:
	ld a,(hl)			;b2f2
	ld (ix+016h),a		;b2f3
	inc hl			;b2f6
	inc ix		;b2f7
	dec d			;b2f9
	jp nz,L_B2F2		;b2fa
	pop ix		;b2fd
	inc bc			;b2ff
	ld (ix+00ch),000h		;b300
	ld (ix+00dh),000h		;b304
	ld (ix+010h),000h		;b308
	ld (ix+011h),000h		;b30c
	ld (ix+012h),000h		;b310
	ld (ix+02ah),000h		;b314
	ld (ix+02bh),000h		;b318
	ld (ix+02ch),000h		;b31c
	jp L_B063		;b320
L_B323:
	inc bc			;b323
	ld a,(0b53fh)		;b324
	res 2,a		;b327
	ld (0b53fh),a		;b329
	ld a,(bc)			;b32c
	ld de,00006h		;b32d
	call MULTIPLICA		;b330
	ld de,0b58dh		;b333
	add hl,de			;b336
	ld iy,0b535h		;b337
	ld (iy+000h),000h		;b33b
	ld (iy+001h),000h		;b33f
	ld d,006h		;b343
L_B345:
	ld a,(hl)			;b345
	ld (iy+004h),a		;b346
	inc hl			;b349
	inc iy		;b34a
	dec d			;b34c
	jr nz,L_B345		;b34d
	xor a			;b34f
	ld (0b541h),a		;b350
	inc bc			;b353
	jp L_B063		;b354
PSG_ESCRIBE:		; Escribe un registro del PSG
	push de			;b357
	cpl			;b358
	ld e,a			;b359
	ld d,009h		;b35a
	ld a,(0b49eh)		;b35c
L_B35F:
	dec a			;b35f
	jp m,L_B36A		;b360
	scf			;b363
	rl e		;b364
	sla d		;b366
	jr L_B35F		;b368
L_B36A:
	ld a,(0b4a7h)		;b36a
	or d			;b36d
	and e			;b36e
	ld (0b4a7h),a		;b36f
	pop de			;b372
	ret			;b373
MULTIPLICA:		; HL = A * DE. Se usa para saltar al bloque del canal (A * 46)
	ld hl,00000h		;b374
	cp 000h		;b377
	ret z			;b379
	push bc			;b37a
	ld b,008h		;b37b
L_B37D:
	srl a		;b37d
	jr nc,L_B382		;b37f
	add hl,de			;b381
L_B382:
	sla e		;b382
	rl d		;b384
	djnz L_B37D		;b386
	pop bc			;b388
	ret			;b389
L_B38A:
	push af			;b38a
	ld hl,00000h		;b38b
	ld a,b			;b38e
	ld b,010h		;b38f
L_B391:
	rl c		;b391
	rla			;b393
	adc hl,hl		;b394
	sbc hl,de		;b396
	jr nc,L_B39B		;b398
	add hl,de			;b39a
L_B39B:
	ccf			;b39b
	djnz L_B391		;b39c
	rl c		;b39e
	rla			;b3a0
	ld b,a			;b3a1
	pop af			;b3a2
	ret			;b3a3
INDEXA_TABLA:		; HL = palabra que hay en (HL + A*2). Sirve para las dos tablas
	push af			;b3a4
	add a,a			;b3a5
	add a,l			;b3a6
	ld l,a			;b3a7
	jr nc,L_B3AB		;b3a8
	inc h			;b3aa
L_B3AB:
	ld a,(hl)			;b3ab
	inc hl			;b3ac
	ld h,(hl)			;b3ad
	ld l,a			;b3ae
	pop af			;b3af
	ret			;b3b0
VUELCA_PSG:		; Manda los 11 registros del PSG de una tacada desde el buffer 0xB4A0
	ld hl,0b4a0h		;b3b1
	ld a,000h		;b3b4
	ld d,00bh		;b3b6
L_B3B8:
	push af			;b3b8
	ld c,(hl)			;b3b9
	out (0a0h),a		;b3ba   ; Puerto de direccion del PSG
	ld a,c			;b3bc
	out (0a1h),a		;b3bd   ; Puerto de dato del PSG
	pop af			;b3bf
	inc a			;b3c0
	inc hl			;b3c1
	dec d			;b3c2
	jr nz,L_B3B8		;b3c3
	ret			;b3c5

; ----------------------------------------------------------------------
; DATOS tabla_notas: Periodos de las notas, indexada por el byte de melodia
;   0xb3c6..0xb486  (192 bytes)

; ----------------------------------------------------------------------
; ############################################################
; DATOS DEL SONIDO
; ############################################################
; ----------------------------------------------------------------------
DATA_tabla_notas:
	defw 00d5dh,00c9dh,00be7h,00b3ch,00a9bh,00a03h,00973h,008ebh	; b3c6
	defw 0086bh,007f2h,00780h,00714h,006aeh,0064eh,005f4h,0059eh	; b3d6
	defw 0054dh,00501h,004b9h,00475h,00435h,003f9h,003c0h,0038ah	; b3e6
	defw 00357h,00327h,002fah,002cfh,002a7h,00281h,0025dh,0023bh	; b3f6
	defw 0021bh,001fch,001e0h,001c5h,001ach,00194h,0017dh,00168h	; b406
	defw 00153h,00140h,0012eh,0011dh,0010dh,000feh,000f0h,000e2h	; b416
	defw 000d6h,000cah,000beh,000b4h,000aah,000a0h,00097h,0008fh	; b426
	defw 00087h,0007fh,00078h,00071h,0006bh,00065h,0005fh,0005ah	; b436
	defw 00055h,00050h,0004ch,00047h,00043h,00040h,0003ch,00039h	; b446
	defw 00035h,00032h,00030h,0002dh,0002ah,00028h,00026h,00024h	; b456
	defw 00022h,00020h,0001eh,0001ch,0001bh,00019h,00018h,00016h	; b466
	defw 00015h,00014h,00013h,00012h,00011h,00010h,0000fh,0000eh	; b476

; ----------------------------------------------------------------------
; DATOS tabla_comandos: 12 punteros a los manejadores de comando. La entrada
;   13 apuntaria a 0x0102, o sea que la tabla se acaba justo ahi
;   0xb486..0xb49e  (24 bytes)
DATA_tabla_comandos:
	defw 0b22ah	; b486  -> L_B22A
	defw 0b248h	; b488  -> L_B248
	defw 0b294h	; b48a  -> L_B294
	defw 0b233h	; b48c  -> L_B233
	defw 0b290h	; b48e  -> L_B290
	defw 0b262h	; b490  -> L_B262
	defw 0b2a3h	; b492  -> L_B2A3
	defw 0b2dah	; b494  -> L_B2DA
	defw 0b27ch	; b496  -> L_B27C
	defw 0b323h	; b498  -> L_B323
	defw 0b2c6h	; b49a  -> L_B2C6
	defw 0b253h	; b49c  -> L_B253

; ----------------------------------------------------------------------
; DATOS var_B49E: Dos variables sueltas del reproductor: 0xB49E (canal en
;   curso) y 0xB49F (palabra de trabajo)
;   0xb49e..0xb4a0  (2 bytes)
DATA_var_B49E:
	defb 002h,001h	; b49e

; ----------------------------------------------------------------------
; DATOS buffer_psg: Sombra de los 11 registros del PSG, en el orden del chip:
;   0xB4A0-0xB4A5 los periodos de tono de los tres canales (registros 0-5),
;   0xB4A6 el periodo del ruido (registro 6, lo escribe 0xB1D6), 0xB4A7 el
;   mezclador (registro 7, lo lleva 0xB36A) y 0xB4A8-0xB4AA los volumenes
;   (registros 8-10). VUELCA_PSG los manda los once de golpe cada frame
;   0xb4a0..0xb4ab  (11 bytes)
DATA_buffer_psg:
	defb 000h,000h,000h,000h,000h,000h,000h,03fh,000h,000h,000h	; b4a0  .......?...

; ----------------------------------------------------------------------
; DATOS estado_canales: Los TRES bloques de estado, 46 bytes cada uno (0x2E,
;   tamano dicho por el propio codigo en 0xB018 y 0xB024). Canal 0 en 0xB4AB,
;   canal 1 en 0xB4D9, canal 2 en 0xB507. Dentro de cada bloque, deducido de
;   como lo indexa IX: +0/+1 puntero al principio de la melodia (para
;   repetirla), +2/+3 puntero de lectura, +4/+5 duracion que le queda a la
;   nota, +9 volumen, +0x0A/+0x0B periodo del tono, y +0x2A/+0x2B/+0x2C los
;   ajustes que se suman al volumen y al periodo (lo que da el vibrato y la
;   envolvente)
;   0xb4ab..0xb535  (138 bytes)
DATA_estado_canales:
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; b4ab  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; b4bb  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; b4cb  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; b4db  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; b4eb  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; b4fb  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; b50b  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; b51b  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; b52b  ..........

; ----------------------------------------------------------------------
; DATOS estado_global: Bloque de 10 bytes al que apunta IY, mas las variables
;   0xB53F, 0xB540 y 0xB541
;   0xb535..0xb542  (13 bytes)
DATA_estado_global:
	defb 000h,000h,000h,000h,001h,00ah,00ah,0fdh,001h,003h,000h,000h,000h	; b535  .............

; ----------------------------------------------------------------------
; DATOS tabla_B542: Tabla de 75 bytes que se carga con `ld de,0xB542` desde
;   0xB2EA (manejador del comando 0x86)
;   0xb542..0xb58d  (75 bytes)
DATA_tabla_B542:
	defb 001h,00dh,000h,000h,000h,001h,0ffh,000h,000h,000h,000h,001h,000h,000h,000h,002h	; b542  ................
	defb 002h,001h,001h,000h,000h,000h,001h,0ffh,000h,000h,000h,001h,001h,000h,001h,00ch	; b552  ................
	defb 000h,000h,000h,00ch,0ffh,000h,000h,000h,000h,001h,000h,000h,000h,000h,000h,001h	; b562  ................
	defb 003h,000h,000h,000h,0fdh,001h,000h,000h,000h,000h,001h,000h,002h,00bh,001h,003h	; b572  ................
	defb 000h,001h,0ffh,0fdh,001h,000h,009h,009h,001h,001h,000h	; b582  ...........

; ----------------------------------------------------------------------
; DATOS tabla_B58D: Tabla de 6 bytes, se carga desde 0xB333 (manejador del
;   comando 0x89)
;   0xb58d..0xb593  (6 bytes)
DATA_tabla_B58D:
	defb 001h,00ah,00ah,0fdh,001h,003h	; b58d

; ----------------------------------------------------------------------
; DATOS melodia_canal_0: Voz del canal 0, 173 bytes
;   0xb593..0xb640  (173 bytes)

; ----------------------------------------------------------------------
; ############################################################
; LAS TRES MELODIAS DE LA PANTALLA DE TITULO
; ############################################################
; Las arranca de una tacada la rutina 0xC3B9, que hace tres
; llamadas seguidas a ASIGNA_MELODIA con A = 0, 1 y 2:
; ld de,0xB593 / xor a / call 0xB015
; ld de,0xB640 / inc a / call 0xB015
; ld de,0xB877 / inc a / jp   0xB015
; O sea que son las voces de una misma pieza, una por canal del
; PSG. Que la tercera sea tan corta encaja con que lleve el bajo
; o la percusion.
; ----------------------------------------------------------------------
DATA_melodia_canal_0:
	defb 085h,064h,081h,001h,087h,000h,080h,009h,083h,008h,024h,024h,027h,028h,02bh,02bh	; b593  .d........$$'(++
	defb 02dh,02bh,024h,024h,027h,028h,02bh,02bh,02dh,030h,024h,024h,027h,028h,02bh,02bh	; b5a3  -+$$'(++-0$$'(++
	defb 02dh,02bh,024h,024h,027h,028h,02bh,02bh,02dh,030h,024h,024h,027h,028h,02bh,02bh	; b5b3  -+$$'(++-0$$'(++
	defb 02dh,02bh,024h,024h,027h,028h,02bh,02bh,02dh,030h,024h,024h,027h,028h,02bh,02bh	; b5c3  -+$$'(++-0$$'(++
	defb 02dh,02bh,024h,024h,027h,028h,02bh,02bh,02dh,030h,01dh,01dh,020h,021h,024h,024h	; b5d3  -+$$'(++-0.. !$$
	defb 026h,024h,01dh,01dh,020h,021h,024h,024h,026h,024h,024h,024h,028h,028h,02bh,02bh	; b5e3  &$.. !$$&$$$((++
	defb 02dh,02dh,02eh,02eh,02dh,02dh,02bh,02bh,028h,028h,01dh,01dh,020h,021h,024h,024h	; b5f3  --..--++((.. !$$
	defb 026h,024h,01dh,01dh,020h,021h,024h,024h,026h,024h,024h,024h,028h,028h,02bh,02bh	; b603  &$.. !$$&$$$((++
	defb 02dh,02dh,02eh,02eh,02dh,02dh,02bh,02bh,028h,028h,02bh,02bh,02fh,02bh,031h,02bh	; b613  --..--++((++/+1+
	defb 032h,02bh,029h,029h,02dh,029h,02fh,029h,030h,029h,080h,00ch,024h,024h,028h,028h	; b623  2+))-)/)0)..$$((
	defb 029h,029h,02ah,02ah,02bh,02bh,01fh,02bh,01fh,02bh,01fh,02bh,082h	; b633  ))**++.+.+.+.

; ----------------------------------------------------------------------
; DATOS melodia_canal_1: Voz del canal 1, 567 bytes
;   0xb640..0xb877  (567 bytes)
DATA_melodia_canal_1:
	defb 081h,001h,087h,001h,080h,00bh,083h,0a0h,084h,084h,084h,084h,084h,084h,084h,084h	; b640  ................
	defb 083h,008h,048h,048h,046h,045h,043h,045h,03fh,03eh,03ch,037h,03eh,03ch,084h,037h	; b650  ..HHFECE?><7><.7
	defb 039h,03ch,03fh,084h,03fh,084h,03fh,03eh,03ch,037h,039h,03ch,039h,037h,083h,020h	; b660  9<?.?.?><79<97. 
	defb 084h,083h,008h,048h,048h,046h,045h,043h,045h,03fh,03eh,03ch,037h,03eh,03ch,084h	; b670  ...HHFECE?><7><.
	defb 080h,00dh,037h,039h,03ch,040h,084h,040h,03eh,03ch,037h,039h,037h,033h,032h,030h	; b680  ..79<@.@><797320
	defb 02dh,030h,083h,018h,080h,00bh,084h,083h,008h,045h,044h,045h,044h,045h,043h,041h	; b690  -0.......EDEDECA
	defb 045h,084h,045h,046h,047h,048h,083h,010h,04dh,083h,008h,04fh,083h,002h,04bh,083h	; b6a0  E.EFGH..M..O..K.
	defb 00eh,04ch,083h,002h,04bh,083h,00eh,04ch,083h,008h,04ah,048h,043h,083h,002h,04bh	; b6b0  .L..K..L..JHC..K
	defb 083h,00eh,04ch,083h,002h,04eh,083h,00eh,04fh,083h,002h,051h,083h,006h,04ch,083h	; b6c0  ..L..N..O..Q..L.
	defb 008h,04ah,048h,048h,084h,080h,00bh,039h,084h,039h,038h,039h,083h,010h,03ch,083h	; b6d0  .JHH...9.989..<.
	defb 008h,038h,039h,038h,039h,083h,028h,03ch,083h,008h,037h,084h,037h,036h,037h,03ch	; b6e0  .8989.(<..7.767<
	defb 084h,037h,083h,008h,040h,040h,03eh,083h,028h,03ch,080h,00bh,083h,008h,047h,047h	; b6f0  .7..@@>.(<....GG
	defb 048h,049h,04ah,043h,042h,043h,041h,041h,083h,010h,045h,083h,008h,048h,083h,010h	; b700  HIJCBCAA..E..H..
	defb 04ah,083h,008h,043h,048h,048h,046h,046h,045h,045h,044h,044h,043h,041h,042h,083h	; b710  J..CHHFFEEDDCAB.
	defb 010h,043h,083h,008h,087h,003h,043h,048h,04ch,083h,010h,04fh,04fh,083h,008h,051h	; b720  .C....CHL..OO..Q
	defb 083h,010h,04fh,083h,008h,043h,048h,04ch,051h,083h,010h,04fh,083h,008h,043h,048h	; b730  ..O..CHLQ..O..CH
	defb 04ch,083h,010h,04fh,04fh,083h,008h,051h,04fh,083h,010h,04fh,083h,008h,051h,054h	; b740  L..OO..QO..O..QT
	defb 051h,083h,010h,054h,083h,008h,037h,03ch,040h,083h,010h,043h,083h,008h,040h,045h	; b750  Q..T..7<@..C..@E
	defb 083h,010h,043h,040h,083h,008h,043h,043h,040h,045h,083h,010h,043h,040h,043h,083h	; b760  ..C@..CC@E..C@C.
	defb 008h,040h,045h,043h,043h,045h,043h,040h,03ah,03eh,083h,010h,03ch,083h,018h,084h	; b770  .@ECCEC@:>..<...
	defb 083h,008h,04dh,048h,04ah,04ah,045h,043h,041h,045h,048h,084h,048h,045h,083h,010h	; b780  ..MHJJECAEH.HE..
	defb 04ah,048h,080h,000h,087h,002h,083h,008h,048h,084h,046h,043h,046h,084h,043h,041h	; b790  JH......H.FCF.CA
	defb 042h,043h,03fh,03eh,03ch,083h,018h,084h,083h,008h,080h,00bh,087h,003h,04dh,048h	; b7a0  BC?><.........MH
	defb 04ah,04ah,045h,043h,041h,045h,048h,084h,048h,045h,083h,010h,04ah,048h,080h,00ch	; b7b0  JJECAEH.HE..JH..
	defb 087h,000h,083h,008h,03ch,037h,039h,045h,084h,043h,084h,037h,03ch,040h,045h,043h	; b7c0  ....<79E.C.7<@EC
	defb 083h,020h,084h,080h,00bh,087h,004h,083h,010h,04ah,04ah,083h,008h,047h,083h,010h	; b7d0  . .......JJ..G..
	defb 043h,083h,008h,045h,083h,010h,048h,083h,008h,048h,045h,04ah,04ah,083h,010h,048h	; b7e0  C..E..H..HEJJ..H
	defb 081h,009h,080h,000h,087h,002h,083h,008h,048h,084h,046h,084h,045h,084h,044h,084h	; b7f0  ........H.F.E.D.
	defb 043h,043h,043h,083h,010h,043h,083h,008h,04dh,04ch,04ah,081h,001h,080h,009h,087h	; b800  CCC..C..MLJ.....
	defb 004h,083h,048h,03ch,083h,008h,03ah,037h,036h,035h,033h,030h,02eh,083h,080h,030h	; b810  ..H<..:76530...0
	defb 083h,048h,043h,083h,008h,043h,046h,043h,048h,046h,043h,046h,083h,080h,03ch,083h	; b820  .HC..CFCHFCF..<.
	defb 008h,041h,084h,041h,03fh,041h,03fh,084h,084h,083h,008h,041h,084h,045h,048h,04dh	; b830  .A.A?A?....A.EHM
	defb 04dh,04ah,048h,083h,080h,043h,083h,008h,03fh,03eh,03ch,03fh,03eh,03ch,03fh,03eh	; b840  MJH..C..?><?><?>
	defb 03ch,03fh,03eh,03ch,03fh,03eh,03ch,039h,083h,080h,037h,083h,008h,043h,084h,043h	; b850  <?><?><9..7..C.C
	defb 084h,045h,043h,084h,084h,041h,084h,041h,084h,048h,045h,083h,010h,084h,048h,046h	; b860  .EC..A.A.HE...HF
	defb 045h,044h,043h,045h,043h,045h,082h	; b870

; ----------------------------------------------------------------------
; DATOS melodia_canal_2: Voz del canal 2, 34 bytes
;   0xb877..0xb899  (34 bytes)
DATA_melodia_canal_2:
	defb 081h,001h,087h,002h,080h,000h,08ah,000h,089h,000h,083h,008h,018h,084h,081h,008h	; b877  ................
	defb 01eh,081h,001h,018h,018h,081h,008h,083h,008h,084h,01eh,084h,082h,0c9h,000h,000h	; b887  ................
	defb 000h,000h	; b897
