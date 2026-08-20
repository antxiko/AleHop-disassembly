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
; ############################################################
; TABLA DE NOMBRES (768 bytes de datos, no codigo)
; ############################################################
; 32x24 casillas que 0xC05F manda a VRAM 0x1800 de una tacada.
; ----------------------------------------------------------------------
DATA_tabla_nombres:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,082h,07dh,07eh,081h,0ffh,0ffh,0ffh,082h,07dh,07eh,081h,0ffh,0ffh,0ffh,082h,07dh,07eh,081h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bd00  ........}~.....}~.....}~........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,080h,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,080h,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,080h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bd20  ................................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,084h,08ah,08ah,08ah,08ah,08ah,08ah,08ah,08ah,08ah,08ah,08ah,08ah,08ah,08ah,08ah,08ah,085h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bd40  ................................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,08bh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,089h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bd60  ................................
	defb 07eh,07dh,07eh,07dh,07eh,07dh,07eh,08bh,0ffh,066h,067h,068h,0ffh,069h,06ah,0ffh,06bh,068h,066h,067h,066h,067h,076h,0ffh,089h,07dh,07eh,07dh,07eh,07dh,07eh,07dh	; bd80  ~}~}~}~..fgh.ij.khfgfgv..}~}~}~}
	defb 080h,07fh,080h,07fh,080h,07fh,080h,08bh,0ffh,06ch,06dh,06eh,06fh,070h,071h,0ffh,078h,06dh,072h,073h,074h,075h,077h,0ffh,089h,07fh,080h,07fh,080h,07fh,080h,07fh	; bda0  .........lmnopq.xmrstuw.........
	defb 0ffh,0ffh,07dh,07eh,0ffh,0ffh,082h,08bh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,089h,081h,0ffh,0ffh,07dh,07eh,0ffh,0ffh	; bdc0  ..}~........................}~..
	defb 0ffh,0ffh,07fh,080h,0ffh,0ffh,0ffh,086h,088h,088h,088h,088h,088h,088h,088h,088h,088h,088h,088h,088h,088h,088h,088h,088h,087h,0ffh,0ffh,0ffh,07fh,080h,0ffh,0ffh	; bde0  ................................
	defb 0ffh,0ffh,0ebh,0ech,0ffh,0ffh,0ffh,0ffh,0ffh,0f0h,0edh,0eeh,0efh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f0h,0edh,0eeh,0efh,0ffh,0ffh,0ffh,0ffh,0ffh,0ebh,0ech,0ffh,0ffh	; be00  ................................
	defb 0ffh,0ffh,0edh,0eeh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ebh,0ech,0ebh,0ech,0ebh,0ech,0ebh,0ech,0ebh,0ech,0ebh,0ech,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0edh,0eeh,0ffh,0ffh	; be20  ................................
	defb 0ffh,0ffh,0ebh,0ech,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0edh,0eeh,0edh,0eeh,0edh,0eeh,0edh,0eeh,0edh,0eeh,0edh,0eeh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ebh,0ech,0ffh,0ffh	; be40  ................................
	defb 0ebh,0ech,0edh,0eeh,0ebh,0ech,0ebh,0ech,0ebh,0ech,0ebh,0ech,0efh,0ffh,0f0h,0efh,0f0h,0efh,0ffh,0f0h,0ebh,0ech,0ebh,0ech,0ebh,0ech,0ebh,0ech,0edh,0eeh,0ebh,0ech	; be60  ................................
	defb 0edh,0eeh,0ebh,0ech,0edh,0eeh,0edh,0eeh,0edh,0eeh,0edh,0eeh,0ffh,0ffh,0ffh,0f0h,0efh,0ffh,0ffh,0ffh,0edh,0eeh,0edh,0eeh,0edh,0eeh,0edh,0eeh,0ebh,0ech,0edh,0eeh	; be80  ................................
	defb 0ffh,0f0h,0edh,0eeh,0efh,0f2h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f3h,0f0h,0edh,0eeh,0efh,0ffh	; bea0  ................................
	defb 0ffh,0ffh,0ebh,0ech,0ffh,0f9h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f7h,0ffh,0ebh,0ech,0ffh,0ffh	; bec0  ................................
	defb 0ffh,0ffh,0edh,0eeh,0ffh,0f4h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0f5h,0ffh,0edh,0eeh,0ffh,0ffh	; bee0  ................................
	defb 0ffh,000h,0e0h,0e1h,001h,0ffh,0ffh,0ffh,0ffh,0ffh,0e5h,0e0h,0e1h,0e4h,0ffh,0ffh,0ffh,0ffh,0e5h,0e0h,0e1h,0e4h,0ffh,0ffh,0ffh,0ffh,0ffh,000h,0e0h,0e1h,001h,0ffh	; bf00  ................................
	defb 0ffh,007h,0e2h,0e3h,005h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0e2h,0e3h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0e2h,0e3h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,007h,0e2h,0e3h,005h,0ffh	; bf20  ................................
	defb 0ffh,007h,0e0h,0e1h,005h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0e0h,0e1h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0e0h,0e1h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,007h,0e0h,0e1h,005h,0ffh	; bf40  ................................
	defb 0ffh,007h,0e2h,0e3h,005h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,007h,0e2h,0e3h,005h,0ffh	; bf60  ................................
	defb 0ffh,007h,0e0h,0e1h,005h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,0e0h,0e1h,007h,0e0h,0e1h,005h,0ffh	; bf80  ................................
	defb 0ffh,007h,0e2h,0e3h,005h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,0e2h,0e3h,007h,0e2h,0e3h,005h,0ffh	; bfa0  ................................
	defb 0ffh,007h,0e0h,0e1h,005h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,007h,0e0h,0e1h,005h,0ffh	; bfc0  ................................
	defb 0ffh,007h,0e2h,0e3h,005h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,007h,0e2h,0e3h,005h,0ffh	; bfe0  ................................

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
	call LIMPIA_PANTALLA		;c037   ; Borra los 16 KB de VRAM antes de nada
	ld hl,0c3ceh		;c03a   ; Tabla de pares registro/valor del VDP para la pantalla de titulo
	call L_C2AE		;c03d
	ld hl,01b00h		;c040   ; Apaga los 32 sprites poniendolos fuera de pantalla (Y = 0xC0)
	ld a,0c0h		;c043
	ld bc,00080h		;c045
	call 00056h		;c048   ; BIOS FILVRM - Fills VRAM with value
	ld hl,INTERRUPCION_TITULO		;c04b   ; Engancha 0xC105 en el hook H.TIMI, que el BIOS llama en cada interrupcion de video
	ld (0fda0h),hl		;c04e
	ld a,0c3h		;c051
	ld (0fd9fh),a		;c053
	call ARRANCA_MUSICA		;c056   ; Las tres voces de la musica arrancan antes de dibujar
	ld a,(0c52eh)		;c059   ; Segun la bandera, portada normal o pantalla de final de partida
	and a			;c05c
	jr z,L_C074		;c05d
	ld hl,0bd00h		;c05f   ; Vuelca la tabla de nombres de 0xBD00 a la VRAM
	ld de,01800h		;c062
	ld bc,00300h		;c065
	call 0005ch		;c068   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld hl,0c510h		;c06b   ; El juego de graficos de la presentacion
	call CARGA_GRAFICOS_2		;c06e
	jp SCROLL_MENSAJE		;c071   ; Al terminar el juego no hay atraccion: se pasa el mensaje de despedida
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
	xor a			;c097   ; X a cero y sin altura de bote
	ld (0c532h),a		;c098
	ld (0c533h),a		;c09b
	ld a,04ch		;c09e   ; 0x4C es la Y de partida: 0xC531 es la fila, no la columna
	ld (0c531h),a		;c0a0
L_C0A3:
	call PREPARA_BOLA		;c0a3   ; Cada bote empieza con el fotograma de agacharse
	ld a,0edh		;c0a6   ; 0xC535 = 0xED, o sea -19: el mismo impulso que el salto del juego
	call LANZA_BOTE		;c0a8
	ld a,024h		;c0ab   ; Fotograma en el aire
	ld (0c534h),a		;c0ad
L_C0B0:
	call FISICA_BOTE		;c0b0   ; Un paso de la parabola; al tocar suelo se vuelve a botar
	jr z,L_C0A3		;c0b3
	ld hl,0c532h		;c0b5   ; La X avanza de uno en uno y se acaba al dar la vuelta
	inc (hl)			;c0b8
	ret z			;c0b9
	call PINTA_BOLA		;c0ba
	halt			;c0bd   ; Espera al retrazo: la animacion va a 50/60 fotogramas por segundo
	jr L_C0B0		;c0be
PREPARA_BOLA:		; Deja la bola en su fotograma inicial y pinta los cuatro sprites
	ld a,00ch		;c0c0   ; Fotograma de agacharse
	ld (0c534h),a		;c0c2
	call PINTA_BOLA		;c0c5
	ld b,004h		;c0c8   ; Cuatro frames de espera
	call ESPERA_B_FRAMES		;c0ca
	ret			;c0cd
HL_MAS_A:		; Utilidad: HL += A. La misma que 0xD123 en el motor
	push de			;c0ce
	ld e,a			;c0cf
	ld d,000h		;c0d0   ; D a cero: A se toma sin signo
	add hl,de			;c0d2
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
	ld de,0c540h		;c0e2   ; Destino fijo: el buffer de 2048 bytes de 0xC540
L_C0E5:
	ld c,(hl)			;c0e5   ; Cada tramo empieza por una cuenta de 16 bits
	inc hl			;c0e6
	ld b,(hl)			;c0e7
	inc hl			;c0e8
	bit 7,b		;c0e9   ; Con el bit 15 puesto es un tramo repetido
	jr z,L_C101		;c0eb
	ld a,0ffh		;c0ed
	cp b			;c0ef   ; Y si la cuenta entera es 0xFFFF, se acabo
	jr nz,L_C0F4		;c0f0
	cp c			;c0f2
	ret z			;c0f3
L_C0F4:
	res 7,b		;c0f4   ; Quitado el bit 15 queda la cuenta de repeticiones
	ld a,(hl)			;c0f6   ; El mismo byte, tantas veces como diga la cuenta
	ld (de),a			;c0f7
	inc de			;c0f8
	dec bc			;c0f9
	ld a,c			;c0fa
	or b			;c0fb
	jr nz,L_C0F4		;c0fc
	inc hl			;c0fe
	jr L_C0E5		;c0ff
L_C101:
	ldir		;c101   ; Sin el bit 15, copia literal de BC bytes
	jr L_C0E5		;c103
INTERRUPCION_TITULO:		; Manejador enganchado en H.TIMI durante el titulo
	in a,(099h)		;c105   ; Lee el estado del VDP, que es lo que baja la senal de interrupcion
	pop hl			;c107   ; Tira la direccion de vuelta: al manejador del BIOS no se le devuelve el control
	ld hl,0c53bh		;c108
	inc (hl)			;c10b   ; Contador de frames del titulo, el equivalente a 0xDB75 en la partida
	call 0b036h		;c10c   ; Mueve la musica: el reproductor va enganchado a la interrupcion
	pop ix		;c10f   ; El BIOS ha apilado todos los registros antes de llamar al hook
	pop iy		;c111
	pop af			;c113
	pop bc			;c114
	pop de			;c115
	pop hl			;c116
	ex af,af'			;c117
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
	ld iy,0c3ech		;c134   ; Tres pasadas, una por plano de color: asi se hace un sprite multicolor en el MSX1. Los colores son 01 0F 0B, los mismos tres del jugador
	ld hl,0c537h		;c138
	ld b,003h		;c13b
L_C13D:
	ld a,(0c531h)		;c13d   ; La Y del protagonista
	ld c,a			;c140
	ld a,(0c533h)		;c141   ; Mas el desplazamiento del bote
	add a,c			;c144
	ld (iy+000h),a		;c145
	ld a,(0c532h)		;c148   ; Y la X, tal cual
	ld (iy+001h),a		;c14b
	ld a,(0c534h)		;c14e   ; Cada plano usa el patron siguiente
	sub b			;c151
	add a,003h		;c152
	sla a		;c154
	sla a		;c156
	ld (iy+002h),a		;c158   ; El numero de patron va multiplicado por 4 porque los sprites son de 16x16
	ld a,(hl)			;c15b   ; Un color por plano
	ld (iy+003h),a		;c15c
	ld a,004h		;c15f   ; Los planos van en los sprites 3, 2 y 1
	sub b			;c161
	call ESCRIBE_SPRITE_2		;c162
	inc hl			;c165
	djnz L_C13D		;c166
	call LEE_DISPARO		;c168   ; Se mira el disparo en cada repintado: por eso vale desde cualquier escena
	jp nz,EMPIEZA_PARTIDA		;c16b
	ret			;c16e
EMPIEZA_PARTIDA:		; Desengancha la interrupcion, silencia el PSG y salta al motor
	ld hl,0fd9fh		;c16f
	ld (hl),0c9h		;c172   ; Mete un RET en el hook H.TIMI para desenganchar la interrupcion del titulo
	call 00090h		;c174   ; BIOS GICINI - Initialises PSG and sets initial value for the PLAY statement | BIOS GICINI: calla el PSG antes de entrar en la partida
	jp 0d000h		;c177   ; Al pulsar disparo se salta al motor del juego: es la unica entrada a 0xD000
FISICA_BOTE:		; Un paso de la parabola del bote: 0xC535 sube de uno en uno y su cuarta parte se acumula en 0xC533. Gemela de 0xD471
	ld hl,0c535h		;c17a   ; 0xC535 sube de uno en uno: es el tiempo del bote
	inc (hl)			;c17d
	ld a,(hl)			;c17e
	sra a		;c17f   ; Su cuarta parte con signo es la velocidad vertical
	sra a		;c181
	ld hl,0c533h		;c183
	add a,(hl)			;c186   ; Que se acumula en el desplazamiento del sprite
	ld (hl),a			;c187
	ret			;c188
ESCENA_5:		; Ultima escena del modo atraccion
	ld a,038h		;c189   ; Fotograma de la ultima escena
	ld (0c534h),a		;c18b
	xor a			;c18e   ; Sin altura y pegado al borde izquierdo
	ld (0c533h),a		;c18f
	ld (0c532h),a		;c192
	ld a,04ah		;c195
	ld (0c531h),a		;c197
L_C19A:
	ld bc,0ec01h		;c19a   ; Un sprite mas encima del protagonista, patron 0xEC
	call PINTA_SPRITE_0_2		;c19d
	call PINTA_BOLA		;c1a0
	ld hl,0c532h		;c1a3   ; La X avanza de tres en tres: la escena mas rapida
	ld a,003h		;c1a6
	add a,(hl)			;c1a8
	ld (hl),a			;c1a9
	halt			;c1aa
	jr nc,L_C19A		;c1ab
	ld hl,01b00h		;c1ad   ; Y al salirse de pantalla, apaga los sprites
	ld a,0c0h		;c1b0
	jp 0004dh		;c1b2   ; BIOS WRTVRM - Writes data in VRAM
ESCENA_3:		; Tercera escena
	xor a			;c1b5   ; Esta escena reinicia tambien el contador de frames
	ld (0c532h),a		;c1b6
	ld (0c533h),a		;c1b9
	ld (0c53bh),a		;c1bc
	ld a,04ah		;c1bf
	ld (0c531h),a		;c1c1
	ld a,028h		;c1c4   ; Fotograma de tramo rapido
	ld (0c534h),a		;c1c6
L_C1C9:
	call PINTA_BOLA		;c1c9   ; De dos en dos, hasta dar la vuelta
	ld hl,0c532h		;c1cc
	inc (hl)			;c1cf
	inc (hl)			;c1d0
	ret z			;c1d1
	halt			;c1d2
	ld hl,0c533h		;c1d3   ; Va bajando un pixel por frame
	inc (hl)			;c1d6
	ld a,(0c53bh)		;c1d7   ; Menos cuando el bit 2 del contador esta puesto: entonces sube
	and 004h		;c1da
	jr z,L_C1C9		;c1dc
	dec (hl)			;c1de
	dec (hl)			;c1df
	jr L_C1C9		;c1e0
ESCENA_4:		; Cuarta escena
	xor a			;c1e2
	ld (0c532h),a		;c1e3
	ld (0c533h),a		;c1e6
	ld a,04ah		;c1e9
	ld (0c531h),a		;c1eb
L_C1EE:
	ld a,(0c53bh)		;c1ee   ; Un fotograma nuevo cada dos frames
	sra a		;c1f1
	and 007h		;c1f3
	ld hl,0c3e4h		;c1f5   ; Los ocho patrones de la animacion, los mismos ocho de 0xDABA
	call HL_MAS_A		;c1f8
	ld a,(hl)			;c1fb
	ld (0c534h),a		;c1fc
	call PINTA_BOLA		;c1ff
	ld hl,0c532h		;c202   ; De dos en dos, hasta dar la vuelta
	inc (hl)			;c205
	inc (hl)			;c206
	ret z			;c207
	halt			;c208
	jr L_C1EE		;c209
CARGA_GRAFICOS_2:		; Gemelo de 0xD5FC: recorre una tabla de pares (origen, destino VRAM)
	nop			;c20b   ; Origen: el bloque comprimido
	ld e,(hl)			;c20c
	inc hl			;c20d
	ld d,(hl)			;c20e
	inc hl			;c20f
	ld a,d			;c210   ; Un 0x0000 cierra la tabla
	or e			;c211
	ret z			;c212
	push hl			;c213
	ex de,hl			;c214
	call DESCOMPRIME_2		;c215   ; Se descomprime al buffer
	pop hl			;c218
	ld e,(hl)			;c219   ; Destino: la direccion de VRAM
	inc hl			;c21a
	ld d,(hl)			;c21b
	inc hl			;c21c
	push hl			;c21d
	ld bc,00800h		;c21e   ; Cada bloque son 2048 bytes de VRAM
	ld hl,0c540h		;c221
	call 0005ch		;c224   ; BIOS LDIRVM - Block transfers to VRAM from memory
	pop hl			;c227
	jr CARGA_GRAFICOS_2		;c228
ESCRIBE_SPRITE_2:		; Vuelca los 4 bytes de atributo de un sprite. Gemelo de 0xD885
	push hl			;c22a   ; Sprite numero A
	push bc			;c22b
	push de			;c22c
	sla a		;c22d   ; Cada atributo son cuatro bytes
	sla a		;c22f
	ld hl,01b00h		;c231
	call HL_MAS_A		;c234
	ex de,hl			;c237
	ld hl,0c3ech		;c238   ; Y, X, patron y color
	ld bc,00004h		;c23b
	call 0005ch		;c23e   ; BIOS LDIRVM - Block transfers to VRAM from memory
	pop de			;c241
	pop bc			;c242
	pop hl			;c243
	ret			;c244
PINTA_SPRITE_0_2:		; Sprite 0 en la posicion del protagonista, con el patron B y el color C. Gemela de 0xD8A0
	ld a,(0c531h)		;c245   ; A la Y se le suma el bote, igual que en el protagonista
	ld d,a			;c248
	ld a,(0c533h)		;c249
	add a,d			;c24c
	ld iy,0c3ech		;c24d
	ld (iy+000h),a		;c251
	ld a,(0c532h)		;c254
	ld (iy+001h),a		;c257
	ld (iy+002h),b		;c25a   ; El patron y el color vienen en B y C
	ld (iy+003h),c		;c25d
	xor a			;c260   ; Siempre el sprite 0
	jp ESCRIBE_SPRITE_2		;c261

; ----------------------------------------------------------------------
; DATOS codigo_muerto_1: 26 bytes de codigo al que no llega nadie
;   0xc264..0xc27e  (26 bytes)

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
DATA_codigo_muerto_1:
	defb 021h,032h,0c5h,03ah,02fh,0c5h,086h,077h,0cdh,07ah,0c1h,0f5h,0cdh,034h,0c1h,001h	; c264  !2.:/..w.z...4..
	defb 005h,07ch,0cdh,045h,0c2h,0f1h,0c8h,076h,018h,0e6h	; c274  .|.E...v..

; ======================================================================
; CODIGO 0xc27e..0xc38e  (272 bytes)
; ======================================================================


ESPERA_B_FRAMES:		; B esperas de retrazo. Gemela de 0xD954
	halt			;c27e   ; B esperas de retrazo
	djnz ESPERA_B_FRAMES		;c27f
	ret			;c281
LANZA_BOTE:		; Arranca la parabola: 0xC535 = A y desplazamiento vertical a cero. Gemela de 0xDA85
	ld (0c535h),a		;c282   ; El impulso inicial del bote
	xor a			;c285
	ld (0c533h),a		;c286   ; Y se parte de altura cero
	ret			;c289
ESCENA_2:		; Segunda escena
	xor a			;c28a   ; Desde el borde izquierdo y sin altura
	ld (0c532h),a		;c28b
	ld (0c533h),a		;c28e
	ld a,04ah		;c291
	ld (0c531h),a		;c293
L_C296:
	call FOTOGRAMA_BOLA		;c296   ; Aqui si se anima: cuatro fotogramas de andar
	call PINTA_BOLA		;c299
	ld hl,0c532h		;c29c   ; Un pixel por frame, hasta dar la vuelta
	inc (hl)			;c29f
	ret z			;c2a0
	halt			;c2a1
	jr L_C296		;c2a2
LIMPIA_PANTALLA:		; Prepara la pantalla antes de dibujar
	ld hl,00000h		;c2a4   ; Los 16 KB enteros de VRAM a cero
	ld bc,04000h		;c2a7
	xor a			;c2aa
	jp 00056h		;c2ab   ; BIOS FILVRM - Fills VRAM with value
L_C2AE:
	ld c,(hl)			;c2ae   ; Pares registro, valor
	inc hl			;c2af
	ld b,(hl)			;c2b0
	inc hl			;c2b1
	ld a,c			;c2b2
	or b			;c2b3
	ret z			;c2b4   ; Un 0x0000 cierra la tabla
	push hl			;c2b5
	call 00047h		;c2b6   ; BIOS WRTVDP - Writes data in the VDP-register
	pop hl			;c2b9
	jr L_C2AE		;c2ba
SCROLL_MENSAJE:		; Hace pasar el mensaje de fin de partida, letra a letra y pixel a pixel
	call REINICIA_SCROLL		;c2bc   ; Renglon limpio y puntero al principio
L_C2BF:
	ld hl,(0c53dh)		;c2bf
	inc hl			;c2c2
	ld (0c53dh),hl		;c2c3
	ld a,(hl)			;c2c6   ; Lee la siguiente letra del mensaje; el 0x00 lo devuelve al principio
	and a			;c2c7
	jp z,SCROLL_MENSAJE		;c2c8
	cp 020h		;c2cb
	jr nz,L_C2D1		;c2cd
	ld a,096h		;c2cf   ; El espacio (0x20) se cambia por 0x96 para que caiga en el hueco blanco de la tipografia
L_C2D1:
	add a,069h		;c2d1   ; Sumando 0x69 el codigo ASCII se convierte en numero de tile
	ld e,a			;c2d3
	ld d,000h		;c2d4
	sla e		;c2d6
	rl d		;c2d8
	sla e		;c2da
	rl d		;c2dc
	sla e		;c2de
	rl d		;c2e0
	ld hl,00800h		;c2e2   ; La tipografia ya esta en VRAM: la letra se lee de alli
	add hl,de			;c2e5
	ld de,0cde0h		;c2e6   ; Los ocho bytes de la letra van al final del renglon
	ld bc,00008h		;c2e9
	call 00059h		;c2ec   ; BIOS LDIRMV - Block transfers to memory from VRAM | BIOS LDIRMV: se lee el dibujo de la letra desde la propia VRAM
	ld b,008h		;c2ef   ; Ocho pasadas: una letra son ocho pixeles
L_C2F1:
	push bc			;c2f1
	call DESPLAZA_UNA_FILA		;c2f2
	ld hl,0cd40h		;c2f5   ; El renglon entero, 20 casillas de 8 bytes, a los patrones de 0x0800
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
	ld b,008h		;c30e   ; Ocho filas de pixeles
L_C310:
	push bc			;c310
	ld hl,0cddfh		;c311   ; Se empieza por el byte de la letra que esta entrando
	ld a,b			;c314
	call HL_MAS_A		;c315
	call L_C31F		;c318
	pop bc			;c31b
	djnz L_C310		;c31c
	ret			;c31e
L_C31F:
	rl (hl)		;c31f   ; Un bit a la izquierda, y el que sale entra en el byte anterior
	push af			;c321
	pop bc			;c322
	ld de,0fff8h		;c323   ; De una casilla a la anterior hay 8 bytes
	add hl,de			;c326
	ld de,0cd40h		;c327
	and a			;c32a
	sbc hl,de		;c32b   ; Hasta el principio del renglon
	ret c			;c32d
	add hl,de			;c32e
	push bc			;c32f
	pop af			;c330
	jr L_C31F		;c331
REINICIA_SCROLL:		; Limpia el renglon y vuelve a poner el puntero al principio del mensaje
	ld hl,0cd40h		;c333   ; Renglon a cero, 0xA6 bytes
	ld de,0cd41h		;c336
	ld bc,000a6h		;c339
	ld (hl),000h		;c33c
	ldir		;c33e
	ld hl,0c3efh		;c340   ; El mensaje empieza en 0xC3EF
	ld (0c53dh),hl		;c343
	ld hl,00d58h		;c346   ; 0xE0 bytes de la tabla de patrones
	ld bc,000e0h		;c349
L_C34C:
	call 0004ah		;c34c   ; BIOS RDVRM - Reads the content of VRAM
	cpl			;c34f   ; Solo se invierten los bytes que traian el bit 7 puesto
	bit 7,a		;c350
	call z,0004dh		;c352   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;c355
	dec bc			;c356
	ld a,b			;c357
	or c			;c358
	jr nz,L_C34C		;c359
	ld hl,02800h		;c35b   ; La tabla de color de las 20 casillas del renglon
	ld bc,000a0h		;c35e
L_C361:
	push hl			;c361   ; Posicion dentro del renglon
	ld de,02800h		;c362
	and a			;c365
	sbc hl,de		;c366
	ld a,l			;c368
	and 007h		;c369   ; Cuatro colores, uno cada dos filas de pixeles
	sra a		;c36b
	ld hl,0c3e0h		;c36d
	call HL_MAS_A		;c370
	ld a,(hl)			;c373
	pop hl			;c374
	call 0004dh		;c375   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;c378
	dec bc			;c379
	ld a,c			;c37a
	or b			;c37b
	jr nz,L_C361		;c37c
	ld hl,019d9h		;c37e   ; Fila 14, columna 25
	ld a,013h		;c381   ; Las 20 casillas del renglon llevan los patrones 0x13 a 0x00, escritos de derecha a izquierda
L_C383:
	push af			;c383
	call 0004dh		;c384   ; BIOS WRTVRM - Writes data in VRAM
	dec hl			;c387
	pop af			;c388
	dec a			;c389
	jp p,L_C383		;c38a
	ret			;c38d

; ----------------------------------------------------------------------
; DATOS codigo_muerto_2: 43 bytes: efecto de cambio de color de la VRAM, sin
;   usar
;   0xc38e..0xc3b9  (43 bytes)

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
DATA_codigo_muerto_2:
	defb 021h,000h,020h,001h,030h,018h,0cdh,04ah,000h,0cdh,0a7h,0c3h,0cdh,0a7h,0c3h,0cdh	; c38e  !. .0..J........
	defb 04dh,000h,023h,00bh,078h,0b1h,020h,0eeh,0c9h,0cbh,007h,0cbh,007h,0cbh,007h,0cbh	; c39e  M.#.x. .........
	defb 007h,057h,0e6h,00fh,0eeh,001h,07ah,0c0h,0e6h,0f0h,0c9h	; c3ae  .W....z....

; ======================================================================
; CODIGO 0xc3b9..0xc3ce  (21 bytes)
; ======================================================================


ARRANCA_MUSICA:		; Pone las tres voces de la musica del titulo, una por canal del PSG
	ld de,0b593h		;c3b9   ; Voz 1 al canal A
	xor a			;c3bc
	call 0b015h		;c3bd
	ld de,0b640h		;c3c0   ; Voz 2 al canal B
	inc a			;c3c3
	call 0b015h		;c3c4
	ld de,0b877h		;c3c7   ; Voz 3 al canal C
	inc a			;c3ca
	jp 0b015h		;c3cb

; ----------------------------------------------------------------------
; DATOS tabla_C3CE: 18 bytes que lee 0xC03A al arrancar, antes de llamar a
;   0xC2AE
;   0xc3ce..0xc3e0  (18 bytes)

; ----------------------------------------------------------------------
; ############################################################
; DATOS Y VARIABLES DE LA PANTALLA DE TITULO
; ############################################################
; ----------------------------------------------------------------------
DATA_tabla_C3CE:
	defb 000h,002h,001h,062h,002h,006h,003h,0ffh,004h,003h,007h,011h,005h,036h,006h,007h	; c3ce  ...b.........6..
	defb 000h,000h	; c3de

; ----------------------------------------------------------------------
; DATOS tablas_cortas: Dos tablitas: 0xC3E0 (la lee 0xC36D) y 0xC3E4 (la lee
;   0xC1F5)
;   0xc3e0..0xc3ec  (12 bytes)
DATA_tablas_cortas:
	defb 040h,050h,070h,0f0h,010h,010h,010h,010h,014h,018h,01ch,020h	; c3e0  @Pp........ 

; ----------------------------------------------------------------------
; DATOS buffer_sprite: Los 4 bytes de atributo (Y, X, patron, color) que monta
;   PINTA_BOLA con IY. El equivalente en la partida es 0xDADD
;   0xc3ec..0xc3f0  (4 bytes)
DATA_buffer_sprite:
	defb 000h,000h,000h	; c3ec

; ----------------------------------------------------------------------
; ############################################################
; EL MENSAJE DE FIN DE PARTIDA
; ############################################################
; Texto en ASCII, con el que la rutina de 0xC2BC hace un scroll
; suave letra a letra. El puntero vive en 0xC53D y REINICIA_SCROLL
; lo pone en 0xC3EF; el bucle hace `inc hl` antes de leer, asi
; que el primer caracter es el de 0xC3F0. El 0x00 del final
; devuelve el puntero al principio: el mensaje se repite en bucle.
; (Por eso el puntero arranca justo en el ultimo byte del buffer
; de sprite de aqui arriba: se solapan, pero nunca se usan a la
; vez, uno es del titulo y otro de la pantalla final.)
; Cada byte se convierte en numero de tile sumandole 0x69, salvo
; el espacio (0x20), que se sustituye por 0x96 antes de sumar.
; Por eso los signos de puntuacion se ven como \ [ ] al leer los
; bytes en ASCII: son ! . ? en la tipografia del juego.
; Dice, literalmente:
; ENHORABUENA!!!  HAS CONSEGUIDO SUPERAR LOS OBSTACULOS QUE
; TE SEPARABAN DE LA VICTORIA...  TOPO SOFT TE FELICITA.
; PERO...  PODRAS CON  TEMPTATION??
; La despedida es un anuncio de otro juego que Topo Soft habia
; publicado el ano anterior.
; ----------------------------------------------------------------------
	defb 000h	; c3ef

; ----------------------------------------------------------------------
; DATOS mensaje_final: El texto que hace scroll al terminar el juego, en
;   ASCII, terminado en 0x00
;   0xc3f0..0xc4a7  (183 bytes)
DATA_mensaje_final:
	defb 045h,04eh,048h,04fh,052h,041h,042h,055h,045h,04eh,041h,05ch,05ch,05ch,020h,020h	; c3f0  ENHORABUENA\\\  
	defb 020h,020h,020h,048h,041h,053h,020h,043h,04fh,04eh,053h,045h,047h,055h,049h,044h	; c400     HAS CONSEGUID
	defb 04fh,020h,053h,055h,050h,045h,052h,041h,052h,020h,04ch,04fh,053h,020h,04fh,042h	; c410  O SUPERAR LOS OB
	defb 053h,054h,041h,043h,055h,04ch,04fh,053h,020h,051h,055h,045h,020h,054h,045h,020h	; c420  STACULOS QUE TE 
	defb 053h,045h,050h,041h,052h,041h,042h,041h,04eh,020h,044h,045h,020h,04ch,041h,020h	; c430  SEPARABAN DE LA 
	defb 056h,049h,043h,054h,04fh,052h,049h,041h,05bh,05bh,05bh,020h,020h,020h,020h,020h	; c440  VICTORIA[[[     
	defb 020h,054h,04fh,050h,04fh,020h,053h,04fh,046h,054h,020h,054h,045h,020h,046h,045h	; c450   TOPO SOFT TE FE
	defb 04ch,049h,043h,049h,054h,041h,05bh,020h,020h,020h,020h,050h,045h,052h,04fh,05bh	; c460  LICITA[    PERO[
	defb 05bh,05bh,020h,020h,050h,04fh,044h,052h,041h,053h,020h,043h,04fh,04eh,020h,020h	; c470  [[  PODRAS CON  
	defb 020h,054h,045h,04dh,050h,054h,041h,054h,049h,04fh,04eh,05dh,05dh,020h,020h,020h	; c480   TEMPTATION]]   
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c490                  
	defb 020h,020h,020h,020h,020h,020h,020h	; c4a0

; ----------------------------------------------------------------------
; DATOS relleno_mensaje: El 0x00 que cierra el mensaje y espacios de relleno
;   hasta la tabla de graficos
;   0xc4a7..0xc510  (105 bytes)
DATA_relleno_mensaje:
	defb 000h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4a7  .               
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4b7                  
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4c7                  
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4d7                  
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4e7                  
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; c4f7                  
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h	; c507           

; ----------------------------------------------------------------------
; DATOS tabla_graficos: Juego de graficos de la presentacion. Es el MISMO
;   contenido que la tabla de 0xDB35 del motor: pares (origen comprimido,
;   destino VRAM) terminados en 0x0000
;   0xc510..0xc52e  (30 bytes)
DATA_tabla_graficos:
	defw 06d35h,00000h	; c510
	defw 07137h,02000h	; c514
	defw 074cfh,00800h	; c518
	defw 07be9h,02800h	; c51c
	defw 05feeh,01000h	; c520
	defw 066c9h,03000h	; c524
	defw 08293h,03800h	; c528
	defw 00000h	; c52c

; ----------------------------------------------------------------------
; DATOS bandera_arranque: 0xC52E: 0 = arranque normal, distinto de 0 = se
;   vuelve de terminar la partida. La escribe 0xC003 con el valor que trae
;   SLOTS y la lee 0xC059
;   0xc52e..0xc531  (3 bytes)
DATA_bandera_arranque:
	defb 000h,000h,000h	; c52e

; ----------------------------------------------------------------------
; DATOS variables_titulo: Las variables de la pantalla de titulo. Las mas
;   usadas: 0xC532 (12 accesos), 0xC533 (10), 0xC531 y 0xC534 (7 cada una),
;   0xC53B (contador de frames de la interrupcion, igual que 0xDB75 en la
;   partida) y 0xC53D (puntero de 16 bits)
;   0xc531..0xc540  (15 bytes)
DATA_variables_titulo:
	defb 04ch,080h,000h,000h,000h,000h,001h,00fh,00bh,000h,000h,000h,000h,000h,0ffh	; c531  L..............
