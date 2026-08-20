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
	di			;b015   ; Entra con A = canal (0, 1 o 2) y DE = melodia
	push af			;b016
	push de			;b017
	ld de,0002eh		;b018   ; 46 bytes por canal: es el tamano del bloque de estado
	call MULTIPLICA		;b01b   ; HL = canal * 46
	ld de,0b4abh		;b01e   ; Los tres bloques empiezan en 0xB4AB
	add hl,de			;b021   ; HL ya apunta al bloque de este canal
	push hl			;b022
	xor a			;b023
	ld b,02eh		;b024   ; Borra el bloque entero antes de empezar la melodia
L_B026:
	ld (hl),a			;b026   ; Deja a cero duracion, envolventes y ajustes
	inc hl			;b027
	djnz L_B026		;b028
	pop hl			;b02a
	pop de			;b02b
	ld (hl),e			;b02c   ; Guarda el puntero de la melodia por duplicado: uno avanza y el otro sirve para repetir
	inc hl			;b02d
	ld (hl),d			;b02e
	inc hl			;b02f
	ld (hl),e			;b030   ; +2/+3 es el puntero que avanza; +0/+1 se queda para el comando 0x82
	inc hl			;b031
	ld (hl),d			;b032
	pop af			;b033
	ei			;b034   ; La interrupcion vuelve a estar donde estaba
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
	ld (0b49eh),a		;b048   ; Deja el numero de canal donde lo lee PSG_ESCRIBE
	ld a,(ix+004h)		;b04b   ; Si al canal le queda duracion pendiente no se lee nota nueva
	or (ix+005h)		;b04e
	jp nz,CORRE_CANAL		;b051
	xor a			;b054
	call PSG_ESCRIBE		;b055   ; A = 0: cierra tono y ruido del canal antes de leer nota nueva
	ld c,(ix+002h)		;b058   ; El puntero de la melodia, en el bloque del canal
	ld b,(ix+003h)		;b05b
	ld a,b			;b05e
	or c			;b05f
	jp z,CIERRA_CANAL		;b060   ; Puntero a cero: este canal esta parado
LEE_MELODIA:		; Lee el siguiente byte del flujo del canal: nota o comando
	ld a,(bc)			;b063   ; Lee el siguiente byte de la melodia
	cp 080h		;b064   ; Menos de 0x80 es nota; 0x80 o mas es comando
	jp c,PONE_NOTA		;b066
	sub 080h		;b069   ; Quitado el 0x80 queda el numero de comando, de 0 a 11
	ld hl,0b486h		;b06b   ; Tabla de saltos de los 12 comandos
	call INDEXA_TABLA		;b06e
	jp (hl)			;b071   ; Salto indirecto: aqui es donde se despacha cada comando
PONE_NOTA:		; Nota: le busca el periodo en la tabla y lo deja en el bloque del canal
	ld hl,0b3c6h		;b072   ; Tabla de periodos de las notas
	call INDEXA_TABLA		;b075
	ld (ix+00ah),l		;b078   ; El periodo de la nota, a +0x0A/+0x0B del bloque
	ld (ix+00bh),h		;b07b
	inc bc			;b07e   ; Deja el puntero detras del byte de la nota
ARRANCA_NOTA:		; Abre el canal en el mezclador y rearranca las dos envolventes
	ld a,(ix+008h)		;b07f   ; Reabre el canal con lo que dijera el ultimo comando 0x81
	call PSG_ESCRIBE		;b082
	call ARRANCA_ENV_VOL		;b085   ; Arranca la envolvente de volumen del instrumento
	ld (ix+02ah),000h		;b088   ; Y borra el ajuste de volumen que llevara acumulado
	call ARRANCA_ENV_PER		;b08c   ; Lo mismo con la envolvente de periodo
	ld (ix+02bh),000h		;b08f   ; El ajuste de periodo son 16 bits
	ld (ix+02ch),000h		;b093
CUENTA_DURACION:		; Guarda el puntero ya avanzado y carga la duracion de la nota
	ld (ix+002h),c		;b097   ; Guarda el puntero ya avanzado
	ld (ix+003h),b		;b09a
	ld l,(ix+006h)		;b09d   ; La duracion que dejo el ultimo 0x83 o 0x86
	ld h,(ix+007h)		;b0a0
	ld (ix+004h),l		;b0a3   ; Y empieza a contarla
	ld (ix+005h),h		;b0a6
CORRE_CANAL:		; Descuenta un frame a la nota y hace correr las envolventes del canal
	ld l,(ix+004h)		;b0a9   ; Un frame menos de la nota en curso
	ld h,(ix+005h)		;b0ac
	dec hl			;b0af
	ld (ix+004h),l		;b0b0
	ld (ix+005h),h		;b0b3
	push ix		;b0b6   ; IY recorre el bloque del canal, una fase por vuelta
	pop iy		;b0b8
	ld d,002h		;b0ba   ; Dos fases tiene la envolvente de volumen
	ld c,000h		;b0bc
ENV_VOL:		; Envolvente de volumen: dos fases, cada una con su espera, sus pasos y su incremento
	ld a,(iy+00ch)		;b0be   ; +0x0C/+0x0D: frames que faltan para el siguiente paso
	or a			;b0c1
	jr z,L_B0CB		;b0c2
	dec a			;b0c4   ; Sigue esperando: el volumen no se toca
	ld (iy+00ch),a		;b0c5
	inc c			;b0c8   ; C cuenta las fases que siguen vivas
	jr L_B0EC		;b0c9
L_B0CB:
	ld a,(iy+00eh)		;b0cb   ; +0x0E/+0x0F: pasos que le quedan a la fase
	or a			;b0ce
	jr z,L_B0E7		;b0cf
	dec a			;b0d1
	ld (iy+00eh),a		;b0d2
	ld a,(ix+02ah)		;b0d5   ; Ajuste de volumen mas el incremento de la fase (+0x1B/+0x1C)
	add a,(iy+01bh)		;b0d8
	ld (ix+02ah),a		;b0db
	ld a,(iy+020h)		;b0de   ; Recarga la espera desde +0x20/+0x21
	ld (iy+00ch),a		;b0e1
	inc c			;b0e4
	jr L_B0EC		;b0e5
L_B0E7:
	inc iy		;b0e7   ; Fase agotada: se prueba con la siguiente
	dec d			;b0e9
	jr nz,ENV_VOL		;b0ea
L_B0EC:
	ld a,c			;b0ec   ; Si ninguna fase hizo nada, la envolvente se acabo
	or a			;b0ed
	jr nz,L_B0F7		;b0ee
	bit 0,(ix+02dh)		;b0f0   ; Bit 0 de +0x2D: repetirla desde el principio
	call nz,ARRANCA_ENV_VOL		;b0f4
L_B0F7:
	push ix		;b0f7
	pop iy		;b0f9
	ld d,003h		;b0fb   ; Y tres fases tiene la de periodo
	ld c,000h		;b0fd
ENV_PER:		; Envolvente de periodo: lo mismo con tres fases, y el incremento con signo
	ld a,(iy+010h)		;b0ff   ; +0x10..+0x12: espera de cada fase del periodo
	or a			;b102
	jr z,L_B10C		;b103
	dec a			;b105   ; Sigue esperando
	ld (iy+010h),a		;b106
	inc c			;b109   ; Fase viva
	jr L_B157		;b10a
L_B10C:
	ld a,(iy+013h)		;b10c   ; +0x13..+0x15: pasos que le quedan a la fase
	or a			;b10f
	jr z,L_B152		;b110
	dec a			;b112
	ld (iy+013h),a		;b113
	ld a,(iy+01dh)		;b116   ; El incremento (+0x1D..+0x1F) viene con signo
	or a			;b119
	jp p,L_B136		;b11a   ; De 0x80 arriba es negativo y hay que restar
	ld a,(iy+01dh)		;b11d
	cpl			;b120   ; Complemento a dos: el valor absoluto del paso
	inc a			;b121
	ld e,a			;b122
	ld a,(ix+02bh)		;b123   ; Resta el paso al ajuste de periodo, 16 bits
	sub e			;b126
	ld (ix+02bh),a		;b127
	ld a,(ix+02ch)		;b12a
	sbc a,000h		;b12d
	and 00fh		;b12f   ; El periodo del PSG son 12 bits, y el ajuste se recorta igual
	ld (ix+02ch),a		;b131
	jr L_B149		;b134
L_B136:
	ld a,(ix+02bh)		;b136   ; Paso positivo: se suma
	add a,(iy+01dh)		;b139
	ld (ix+02bh),a		;b13c
	ld a,(ix+02ch)		;b13f
	adc a,000h		;b142
	and 00fh		;b144   ; Recortado a 12 bits, como en la rama de la resta
	ld (ix+02ch),a		;b146
L_B149:
	ld a,(iy+022h)		;b149   ; Recarga la espera desde +0x22..+0x24
	ld (iy+010h),a		;b14c
	inc c			;b14f
	jr L_B157		;b150
L_B152:
	inc iy		;b152   ; Fase agotada: la siguiente
	dec d			;b154
	jr nz,ENV_PER		;b155
L_B157:
	ld a,c			;b157   ; Ninguna fase movio el periodo
	or a			;b158
	jr nz,CIERRA_CANAL		;b159
	bit 1,(ix+02dh)		;b15b   ; Bit 1 de +0x2D: repetir la envolvente de periodo
	call nz,ARRANCA_ENV_PER		;b15f
CIERRA_CANAL:		; Vuelca volumen y periodo del canal al buffer del PSG y pasa al siguiente
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
ENV_RUIDO:		; Envolvente global del ruido: dos fases, sobre el bloque de 0xB535
	ld a,(iy+000h)		;b194   ; Bloque global: +0/+1 esperas, +2/+3 pasos, +6/+7 incrementos, +8/+9 recargas
	or a			;b197
	jr z,L_B1A1		;b198
	dec a			;b19a   ; Sigue esperando
	ld (iy+000h),a		;b19b
	inc c			;b19e   ; C cuenta las fases vivas
	jr L_B1C2		;b19f
L_B1A1:
	ld a,(iy+002h)		;b1a1   ; Pasos que le quedan a la fase
	or a			;b1a4
	jr z,L_B1BD		;b1a5
	dec a			;b1a7
	ld (iy+002h),a		;b1a8
	ld a,(0b541h)		;b1ab   ; El ajuste del periodo de ruido, mas el incremento
	add a,(iy+006h)		;b1ae
	ld (0b541h),a		;b1b1
	ld a,(iy+008h)		;b1b4   ; Recarga la espera de la fase
	ld (iy+000h),a		;b1b7
	inc c			;b1ba
	jr L_B1C2		;b1bb
L_B1BD:
	inc iy		;b1bd   ; A la siguiente fase
	dec d			;b1bf
	jr nz,ENV_RUIDO		;b1c0
L_B1C2:
	ld a,c			;b1c2   ; Si ninguna hizo nada, la envolvente esta agotada
	or a			;b1c3
	jr nz,L_B1CE		;b1c4
	ld a,(0b53fh)		;b1c6
	bit 2,a		;b1c9   ; Bit 2 del byte global 0xB53F: repetirla
	call nz,ARRANCA_ENV_RUI		;b1cb
L_B1CE:
	ld a,(0b540h)		;b1ce   ; Periodo del ruido: el del comando 0x88 mas el de la envolvente
	ld e,a			;b1d1
	ld a,(0b541h)		;b1d2
	add a,e			;b1d5
	ld (0b4a6h),a		;b1d6   ; Registro 6 del PSG, en el buffer
	call VUELCA_PSG		;b1d9   ; Y ahora si, los once registros de golpe
	pop af			;b1dc
	ret			;b1dd
ARRANCA_ENV_VOL:		; Copia del instrumento las esperas y los pasos de la envolvente de volumen
	push ix		;b1de
	ld d,002h		;b1e0
L_B1E2:
	ld a,(ix+020h)		;b1e2   ; Espera inicial de la fase (+0x20/+0x21 -> +0x0C/+0x0D)
	ld (ix+00ch),a		;b1e5
	ld a,(ix+016h)		;b1e8   ; Y cuantos pasos dara (+0x16/+0x17 -> +0x0E/+0x0F)
	ld (ix+00eh),a		;b1eb
	inc ix		;b1ee   ; Las dos fases van seguidas en memoria
	dec d			;b1f0
	jr nz,L_B1E2		;b1f1
	pop ix		;b1f3
	ret			;b1f5
ARRANCA_ENV_PER:		; Lo mismo para la envolvente de periodo, que lleva tres fases
	ld d,003h		;b1f6
	push ix		;b1f8
L_B1FA:
	ld a,(ix+022h)		;b1fa   ; Espera inicial (+0x22..+0x24 -> +0x10..+0x12)
	ld (ix+010h),a		;b1fd
	ld a,(ix+018h)		;b200   ; Pasos de la fase (+0x18..+0x1A -> +0x13..+0x15)
	ld (ix+013h),a		;b203
	inc ix		;b206   ; Las tres fases, seguidas
	dec d			;b208
	jr nz,L_B1FA		;b209
	pop ix		;b20b
	ret			;b20d
ARRANCA_ENV_RUI:		; Lo mismo para la envolvente global del ruido
	ld d,002h		;b20e
	push iy		;b210
	ld iy,0b535h		;b212
L_B216:
	ld a,(iy+008h)		;b216   ; Espera inicial (+8/+9 -> +0/+1)
	ld (iy+000h),a		;b219
	ld a,(iy+004h)		;b21c   ; Y sus pasos (+4/+5 -> +2/+3)
	ld (iy+002h),a		;b21f
	inc iy		;b222   ; Las dos fases, seguidas
	dec d			;b224
	jr nz,L_B216		;b225
	pop iy		;b227
	ret			;b229
CMD_VOLUMEN:		; Comando 0x80: volumen base del canal
	inc bc			;b22a   ; El byte siguiente es el volumen, de 0 a 15
	ld a,(bc)			;b22b
	ld (ix+009h),a		;b22c   ; A +9 del bloque; el que suena es este mas el ajuste de la envolvente
	inc bc			;b22f
	jp LEE_MELODIA		;b230   ; Y a seguir leyendo la melodia
CMD_DURACION:		; Comando 0x83: duracion de las notas siguientes
	inc bc			;b233   ; El byte siguiente son unidades de duracion
	ld a,(bc)			;b234
	ld de,(0b49fh)		;b235   ; La unidad, en frames, la fijo el comando 0x85
	ld d,000h		;b239
	call MULTIPLICA		;b23b   ; Duracion = unidades * unidad
	ld (ix+006h),l		;b23e   ; Queda en +6/+7, de donde la cogen las notas que vengan
	ld (ix+007h),h		;b241
	inc bc			;b244
	jp LEE_MELODIA		;b245
CMD_MEZCLADOR:		; Comando 0x81: que abre el canal, tono y/o ruido
	inc bc			;b248   ; El byte siguiente dice que abre en el mezclador
	ld a,(bc)			;b249
	and 009h		;b24a   ; Solo valen dos bits: 1 el tono y 8 el ruido
	ld (ix+008h),a		;b24c   ; Se guarda en +8 y lo aplica ARRANCA_NOTA
	inc bc			;b24f
	jp LEE_MELODIA		;b250
CMD_FIN:		; Comando 0x8B: fin de la melodia, el canal queda parado
	push bc			;b253   ; Borra los 46 bytes del bloque
	push ix		;b254
	pop hl			;b256
	xor a			;b257
	ld b,02eh		;b258
L_B25A:
	ld (hl),a			;b25a
	inc hl			;b25b
	djnz L_B25A		;b25c
	pop bc			;b25e
	jp CIERRA_CANAL		;b25f   ; Con el puntero de lectura a cero el canal queda parado para siempre
CMD_TEMPO:		; Comando 0x85: fija la unidad de duracion a partir del tempo
	inc bc			;b262
	ld a,(bc)			;b263   ; El byte siguiente es el tempo
	push bc			;b264
	ld de,00010h		;b265   ; Por dieciseis: HL = tempo * 16, que luego pasa a DE
	call MULTIPLICA		;b268
	ld bc,00bb8h		;b26b   ; 3000 son los frames que dura un minuto a 50 Hz
	push hl			;b26e
	pop de			;b26f
	call DIVIDE_16		;b270   ; Unidad de duracion = 3000 / (tempo * 16), division entera
	ld a,c			;b273
	ld (0b49fh),a		;b274   ; Y ahi se queda, para los comandos 0x83 y 0x86
	pop bc			;b277
	inc bc			;b278
	jp LEE_MELODIA		;b279
CMD_RUIDO:		; Comando 0x88: periodo del generador de ruido
	inc bc			;b27c
	ld a,(bc)			;b27d
	push af			;b27e
	and 01fh		;b27f   ; Del byte se queda con 5 bits, que es lo que usa el registro 6
	ld (0b540h),a		;b281
	call ARRANCA_ENV_RUI		;b284   ; Rearranca la envolvente del ruido
	pop af			;b287
	inc bc			;b288
	or a			;b289   ; Con el bit 7 puesto solo cambia el ruido y sigue leyendo
	jp m,LEE_MELODIA		;b28a
	jp ARRANCA_NOTA		;b28d   ; Sin el bit 7, ademas suena: abre el canal y cuenta la duracion
CMD_SILENCIO:		; Comando 0x84: silencio de una duracion
	inc bc			;b290   ; El canal ya se cerro al leer, asi que solo hay que esperar la duracion
	jp CUENTA_DURACION		;b291
CMD_REPITE:		; Comando 0x82: vuelve al principio de la melodia
	ld c,(ix+000h)		;b294   ; +0/+1 es el puntero al principio, que no se toca nunca
	ld b,(ix+001h)		;b297
	ld (ix+002h),c		;b29a   ; Se lo copia al puntero de lectura y vuelve a empezar
	ld (ix+003h),b		;b29d
	jp LEE_MELODIA		;b2a0
CMD_DURACION_SUM:		; Comando 0x86: duracion como suma de varios valores
	inc bc			;b2a3   ; El primer byte dice cuantos valores vienen
	ld a,(bc)			;b2a4
	inc bc			;b2a5
	ld de,00000h		;b2a6   ; DE va acumulando la suma
L_B2A9:
	push af			;b2a9
	ld a,(bc)			;b2aa
	push de			;b2ab
	ld de,(0b49fh)		;b2ac   ; Cada valor, por la unidad de duracion
	ld d,000h		;b2b0
	call MULTIPLICA		;b2b2
	pop de			;b2b5
	add hl,de			;b2b6   ; Se suma a lo que ya habia
	ex de,hl			;b2b7
	inc bc			;b2b8
	pop af			;b2b9
	dec a			;b2ba   ; Hasta agotar la cuenta
	jr nz,L_B2A9		;b2bb
	ld (ix+006h),l		;b2bd   ; El total queda como duracion de las notas
	ld (ix+007h),h		;b2c0
	jp LEE_MELODIA		;b2c3
CMD_REPITE_ENV:		; Comando 0x8A: enciende los bits de repeticion de las envolventes
	inc bc			;b2c6
	ld a,(bc)			;b2c7   ; El byte siguiente son las banderas
	ld e,a			;b2c8
	or (ix+02dh)		;b2c9   ; Bits 0 y 1: repetir la envolvente de volumen y la de periodo
	ld (ix+02dh),a		;b2cc
	ld a,(0b53fh)		;b2cf   ; Bit 2: repetir la del ruido, que es global
	or e			;b2d2
	ld (0b53fh),a		;b2d3
	inc bc			;b2d6
	jp LEE_MELODIA		;b2d7
CMD_INSTRUMENTO:		; Comando 0x87: carga uno de los cinco instrumentos de 0xB542
	inc bc			;b2da
	res 0,(ix+02dh)		;b2db   ; Al cambiar de instrumento se apagan las dos repeticiones
	res 1,(ix+02dh)		;b2df
	ld a,(bc)			;b2e3
	ld de,0000fh		;b2e4   ; Cada instrumento son 15 bytes
	call MULTIPLICA		;b2e7   ; HL = indice * 15
	ld de,0b542h		;b2ea   ; La tabla de instrumentos
	add hl,de			;b2ed
	push ix		;b2ee
	ld d,00fh		;b2f0
L_B2F2:
	ld a,(hl)			;b2f2   ; Los 15 bytes van a +0x16..+0x24 del bloque del canal
	ld (ix+016h),a		;b2f3
	inc hl			;b2f6
	inc ix		;b2f7
	dec d			;b2f9
	jp nz,L_B2F2		;b2fa
	pop ix		;b2fd
	inc bc			;b2ff
	ld (ix+00ch),000h		;b300   ; Contadores de la envolvente de volumen a cero
	ld (ix+00dh),000h		;b304
	ld (ix+010h),000h		;b308   ; Y los de la de periodo
	ld (ix+011h),000h		;b30c
	ld (ix+012h),000h		;b310
	ld (ix+02ah),000h		;b314   ; Los ajustes que se suman al volumen y al periodo, tambien
	ld (ix+02bh),000h		;b318
	ld (ix+02ch),000h		;b31c
	jp LEE_MELODIA		;b320
CMD_ENV_RUIDO:		; Comando 0x89: carga la envolvente global del ruido de 0xB58D
	inc bc			;b323
	ld a,(0b53fh)		;b324   ; Al cargarla se apaga su bit de repeticion
	res 2,a		;b327
	ld (0b53fh),a		;b329
	ld a,(bc)			;b32c
	ld de,00006h		;b32d   ; Seis bytes por juego
	call MULTIPLICA		;b330
	ld de,0b58dh		;b333   ; La tabla, que solo tiene el juego 0
	add hl,de			;b336
	ld iy,0b535h		;b337   ; El bloque global del ruido
	ld (iy+000h),000h		;b33b   ; Las dos esperas a cero: el primer paso va en el frame siguiente
	ld (iy+001h),000h		;b33f
	ld d,006h		;b343
L_B345:
	ld a,(hl)			;b345   ; Los seis bytes, a +4..+9 del bloque global
	ld (iy+004h),a		;b346
	inc hl			;b349
	inc iy		;b34a
	dec d			;b34c
	jr nz,L_B345		;b34d
	xor a			;b34f   ; Y el ajuste del periodo de ruido, a cero
	ld (0b541h),a		;b350
	inc bc			;b353
	jp LEE_MELODIA		;b354
PSG_ESCRIBE:		; Escribe un registro del PSG
	push de			;b357
	cpl			;b358   ; Se invierte porque en el registro 7 un 0 es "abierto"
	ld e,a			;b359
	ld d,009h		;b35a   ; 0x09: bit 0 el tono y bit 3 el ruido, los del canal 0
	ld a,(0b49eh)		;b35c   ; El canal que se esta atendiendo
L_B35F:
	dec a			;b35f   ; Corre las dos mascaras tantos bits como diga el canal
	jp m,L_B36A		;b360
	scf			;b363   ; Al rotar E entran unos: los demas canales no se tocan
	rl e		;b364
	sla d		;b366
	jr L_B35F		;b368
L_B36A:
	ld a,(0b4a7h)		;b36a   ; El mezclador que hay en el buffer
	or d			;b36d   ; Cierra tono y ruido del canal, y abre solo lo que pidieran
	and e			;b36e
	ld (0b4a7h),a		;b36f
	pop de			;b372
	ret			;b373
MULTIPLICA:		; HL = A * DE. Se usa para saltar al bloque del canal (A * 46)
	ld hl,00000h		;b374
	cp 000h		;b377   ; Multiplicar por cero se despacha aqui
	ret z			;b379
	push bc			;b37a
	ld b,008h		;b37b
L_B37D:
	srl a		;b37d   ; Suma y desplaza: ocho vueltas, un bit de A por vuelta
	jr nc,L_B382		;b37f
	add hl,de			;b381
L_B382:
	sla e		;b382
	rl d		;b384
	djnz L_B37D		;b386
	pop bc			;b388
	ret			;b389
DIVIDE_16:		; BC = BC / DE por restas y desplazamientos; el resto queda en HL
	push af			;b38a
	ld hl,00000h		;b38b
	ld a,b			;b38e
	ld b,010h		;b38f   ; Dieciseis vueltas, un bit de cociente por vuelta
L_B391:
	rl c		;b391
	rla			;b393
	adc hl,hl		;b394   ; Mete el siguiente bit del dividendo y prueba a restar el divisor
	sbc hl,de		;b396
	jr nc,L_B39B		;b398
	add hl,de			;b39a   ; No cabia: se deshace la resta
L_B39B:
	ccf			;b39b
	djnz L_B391		;b39c
	rl c		;b39e   ; El ultimo bit del cociente
	rla			;b3a0
	ld b,a			;b3a1
	pop af			;b3a2
	ret			;b3a3
INDEXA_TABLA:		; HL = palabra que hay en (HL + A*2). Sirve para las dos tablas
	push af			;b3a4
	add a,a			;b3a5   ; Por dos, que las entradas son palabras
	add a,l			;b3a6   ; Suma a HL sin tocar H salvo que haya acarreo
	ld l,a			;b3a7
	jr nc,L_B3AB		;b3a8
	inc h			;b3aa
L_B3AB:
	ld a,(hl)			;b3ab   ; La palabra de la tabla, byte bajo primero
	inc hl			;b3ac
	ld h,(hl)			;b3ad   ; Y el alto
	ld l,a			;b3ae
	pop af			;b3af
	ret			;b3b0
VUELCA_PSG:		; Manda los 11 registros del PSG de una tacada desde el buffer 0xB4A0
	ld hl,0b4a0h		;b3b1
	ld a,000h		;b3b4   ; Empieza por el registro 0
	ld d,00bh		;b3b6   ; Once registros, del 0 al 10; los de la envolvente del chip (11 a 13) no se tocan
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
; DATOS tabla_notas: Periodos de las notas, indexada por el byte de melodia (0
;   a 95). Son 96 entradas: ocho octavas de doce semitonos. Cada entrada es el
;   periodo de tono del PSG, y la de doce mas alla vale justo la mitad. La
;   primera, 0x0D5D, da 65,4 Hz con el reloj del PSG del MSX (3,58 MHz / 16 /
;   periodo), o sea el do de la segunda octava; la ultima, 0x000E, se sale de
;   lo audible
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

; ----------------------------------------------------------------------
; ------------------------------------------------------------
; LOS DOCE COMANDOS DE LA MELODIA
; El byte de melodia menos 0x80 indexa esta tabla. Entre
; parentesis, los bytes que se lleva cada comando detras:
; 0x80 (1) volumen base del canal, 0 a 15
; 0x81 (1) mezclador: bit 0 tono, bit 3 ruido
; 0x82 (0) vuelve al principio de la melodia
; 0x83 (1) duracion = valor * unidad de duracion
; 0x84 (0) silencio de una duracion
; 0x85 (1) tempo: unidad = 3000 / (valor * 16) frames
; 0x86 (1+n) duracion = suma de n valores
; 0x87 (1) instrumento, de los cinco de 0xB542
; 0x88 (1) periodo del ruido; con el bit 7 puesto no suena
; 0x89 (1) envolvente del ruido, de la tabla de 0xB58D
; 0x8A (1) bits de repeticion de las envolventes
; 0x8B (0) fin de la melodia
; ------------------------------------------------------------
; ----------------------------------------------------------------------
DATA_tabla_comandos:
	defw 0b22ah	; b486  -> CMD_VOLUMEN
	defw 0b248h	; b488  -> CMD_MEZCLADOR
	defw 0b294h	; b48a  -> CMD_REPITE
	defw 0b233h	; b48c  -> CMD_DURACION
	defw 0b290h	; b48e  -> CMD_SILENCIO
	defw 0b262h	; b490  -> CMD_TEMPO
	defw 0b2a3h	; b492  -> CMD_DURACION_SUM
	defw 0b2dah	; b494  -> CMD_INSTRUMENTO
	defw 0b27ch	; b496  -> CMD_RUIDO
	defw 0b323h	; b498  -> CMD_ENV_RUIDO
	defw 0b2c6h	; b49a  -> CMD_REPITE_ENV
	defw 0b253h	; b49c  -> CMD_FIN

; ----------------------------------------------------------------------
; DATOS var_B49E: Dos variables del reproductor: 0xB49E el canal que se esta
;   atendiendo (0, 1 o 2), que es lo que mira PSG_ESCRIBE para saber que bits
;   del mezclador tocar, y 0xB49F la unidad de duracion en frames, que deja el
;   comando 0x85 y usan el 0x83 y el 0x86
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
;   nota, +9 volumen, +0x0A/+0x0B periodo del tono, +0x0C/+0x0D y +0x0E/+0x0F
;   los contadores de las dos fases de la envolvente de volumen, +0x10..+0x12
;   y +0x13..+0x15 los de las tres de la envolvente de periodo, +0x16..+0x24
;   los 15 bytes del instrumento tal cual los copia el comando 0x87, +0x2A el
;   ajuste de volumen, +0x2B/+0x2C el de periodo (12 bits) y +0x2D las
;   banderas de repeticion (bit 0 el volumen, bit 1 el periodo)
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
; DATOS estado_global: La envolvente global del ruido, la unica que no es por
;   canal. IY apunta a 0xB535: +0/+1 lo que falta para el siguiente paso de
;   cada una de las dos fases, +2/+3 los pasos que le quedan, +4/+5 y +6/+7 y
;   +8/+9 los seis bytes que copia el comando 0x89 (pasos, incrementos y
;   esperas). Detras, tres variables sueltas: 0xB53F banderas (bit 2, repetir
;   esta envolvente), 0xB540 el periodo de ruido que puso el comando 0x88 y
;   0xB541 lo que le va sumando la envolvente
;   0xb535..0xb542  (13 bytes)
DATA_estado_global:
	defb 000h,000h,000h,000h,001h,00ah,00ah,0fdh,001h,003h,000h,000h,000h	; b535  .............

; ----------------------------------------------------------------------
; DATOS instrumentos: CINCO instrumentos de 15 bytes, que el comando 0x87
;   copia enteros a +0x16 del bloque del canal. Cada fila, en orden: 2 bytes
;   de pasos de la envolvente de volumen (una cifra por fase), 3 de pasos de
;   la de periodo, 2 incrementos de volumen, 3 incrementos de periodo (con
;   signo), 2 esperas de volumen y 3 esperas de periodo. Una espera de N
;   quiere decir un paso cada N+1 frames. El instrumento 0 sube el volumen un
;   punto y luego lo baja trece veces de uno en uno; el 2 pega un golpe de
;   doce y decae, que es lo que usa la percusion
;   0xb542..0xb58d  (75 bytes)
DATA_instrumentos:
	defb 001h,00dh,000h,000h,000h,001h,0ffh,000h,000h,000h,000h,001h,000h,000h,000h	; b542  ...............
	defb 002h,002h,001h,001h,000h,000h,000h,001h,0ffh,000h,000h,000h,001h,001h,000h	; b551  ...............
	defb 001h,00ch,000h,000h,000h,00ch,0ffh,000h,000h,000h,000h,001h,000h,000h,000h	; b560  ...............
	defb 000h,000h,001h,003h,000h,000h,000h,0fdh,001h,000h,000h,000h,000h,001h,000h	; b56f  ...............
	defb 002h,00bh,001h,003h,000h,001h,0ffh,0fdh,001h,000h,009h,009h,001h,001h,000h	; b57e  ...............

; ----------------------------------------------------------------------
; DATOS env_ruido: UN solo juego de 6 bytes para la envolvente del ruido, el
;   que carga el comando 0x89: pasos de las dos fases (1 y 10), incrementos
;   (+10 y -3) y esperas (1 y 3). El comando lo indexa multiplicando por 6, o
;   sea que aqui cabrian mas, pero solo hay uno
;   0xb58d..0xb593  (6 bytes)
DATA_env_ruido:
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
; PSG. Leidos los tres flujos con las reglas del reproductor,
; los tres se recorren enteros y los tres acaban en 0x82, que
; es volver al principio: la musica de la portada no termina.
; El canal 0 lleva 160 notas, el 1 son 310 y el 2 solo 5.
; La tercera voz es la PERCUSION: cinco notas que se limitan a
; alternar el mezclador entre tono y ruido (comando 0x81 con 1
; y con 8) con el instrumento 2, que es un golpe de volumen 12
; que decae. Es la unica que carga la envolvente del ruido
; (comando 0x89), pero NO es la unica que lo abre: el canal 1
; tambien, con un 0x81 de valor 9 en 0xB7F0 -tono y ruido a la
; vez- y ese mismo instrumento 2 detras, hasta que vuelve a
; tono solo en 0xB80B.
; El tempo lo pone el canal 0, que es el primero en atenderse:
; 0x85 con 100, que da unidad de duracion = 1 frame.
; Los bits de repeticion de las envolventes no llegan a usarse:
; el unico comando 0x8A de las tres voces lleva un 0.
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
; DATOS melodia_canal_2: Voz del canal 2, 34 bytes. El flujo se acaba en
;   0xB893, con el 0x82 que vuelve al principio; los cinco bytes de 0xB894 a
;   0xB898 (C9 00 00 00 00) son la cola del bloque y no los lee nadie
;   0xb877..0xb899  (34 bytes)
DATA_melodia_canal_2:
	defb 081h,001h,087h,002h,080h,000h,08ah,000h,089h,000h,083h,008h,018h,084h,081h,008h	; b877  ................
	defb 01eh,081h,001h,018h,018h,081h,008h,083h,008h,084h,01eh,084h,082h,0c9h,000h,000h	; b887  ................
	defb 000h,000h	; b897
