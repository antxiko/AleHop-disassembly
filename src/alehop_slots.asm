; ==========================================================================
; ALE HOP! - MSX - SLOTS: buscador de RAM y cargador turbo
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0c350


; ======================================================================
; CODIGO 0xc350..0xc3d2  (130 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; BUSCADOR DE RAM EN LOS SLOTS
; ############################################################
; Recorre los 4 slots primarios x 4 secundarios probando a
; escribir y releer, para localizar RAM en cada pagina. Guarda
; los identificadores de slot encontrados en 0xE290..0xE293 y
; deja los slots como estaban al salir: quien conmuta de verdad
; es luego la secuencia de carga.
; Anota DOS configuraciones: en 0xE290/0xE291 la que habia al
; entrar (la del BASIC, con ROM abajo) y en 0xE292/0xE293 la de
; "todo RAM". El juego alternara entre las dos toda la partida.
; ----------------------------------------------------------------------
BUSCA_RAM:		; Localiza RAM en todas las paginas y anota los slots
	di			;c350   ; Nada de interrupciones mientras se toquetean los slots
	ld a,(08000h)		;c351   ; Guarda un byte de 0x8000 para restaurarlo: la prueba lo machaca
	push af			;c354
	call GUARDA_SLOTS_A		;c355
	ld hl,00024h		;c358   ; Codigo automodificable: escribe 0x0024 (ENASLT) como destino del CALL de 0xC3B2
	ld (0c3b3h),hl		;c35b
	ld hl,04000h		;c35e   ; Sondea la pagina 1 (0x4000)
	call SONDEA_PAGINA		;c361
	ld hl,08000h		;c364   ; Sondea la pagina 2 (0x8000)
	call SONDEA_PAGINA		;c367
	ld hl,0c418h		;c36a   ; Copia el buscador a 0x9C40, en RAM...
	ld de,09c40h		;c36d
	ld bc,000c8h		;c370
	ldir		;c373
	ld hl,09c40h		;c375   ; ...y reescribe el CALL para usar esa copia en vez de la BIOS
	ld (0c3b3h),hl		;c378
	ld hl,00000h		;c37b   ; Ahora ya se puede sondear la pagina 0, donde la BIOS dejaria de estar mapeada
	call SONDEA_PAGINA		;c37e
	call GUARDA_SLOTS_B		;c381
	ld a,(0e290h)		;c384   ; Restaura los slots tal y como estaban
	out (0a8h),a		;c387
	ld a,(0e291h)		;c389
	ld (0ffffh),a		;c38c
	pop af			;c38f
	ld (08000h),a		;c390
	ei			;c393
	ret			;c394
GUARDA_SLOTS_A:		; Anota en 0xE290 el estado actual de slots
	ld hl,0e290h		;c395
	jr L_C39D		;c398
GUARDA_SLOTS_B:		; Anota en 0xE292 el estado actual de slots
	ld hl,0e292h		;c39a
L_C39D:
	in a,(0a8h)		;c39d
	ld (hl),a			;c39f
	inc hl			;c3a0
	ld a,(0ffffh)		;c3a1
	cpl			;c3a4
	ld (hl),a			;c3a5
	ret			;c3a6
SONDEA_PAGINA:		; Prueba todos los slots de la pagina HL y se queda con el que tenga RAM
	ld a,080h		;c3a7   ; 0x80 = marca de slot expandido
	ld c,004h		;c3a9   ; 4 slots primarios
L_C3AB:
	and 083h		;c3ab
	ld b,004h		;c3ad   ; 4 slots secundarios por cada primario
L_C3AF:
	push af			;c3af
	push bc			;c3b0
	push hl			;c3b1
	call 00024h		;c3b2   ; BIOS ENASLT - Switches to specified slot and page definitively | ENASLT o su copia en RAM (ver 0xC358 y 0xC375)
	pop hl			;c3b5
	ld (hl),020h		;c3b6   ; Prueba de RAM: escribe 0x20 y lo relee...
	ld a,(hl)			;c3b8
	cp 020h		;c3b9
	jr nz,L_C3C4		;c3bb
	ld (hl),0fah		;c3bd   ; ...y luego 0xFA, para descartar que sea ROM o bus flotante
	ld a,(hl)			;c3bf
	cp 0fah		;c3c0
	jr z,L_C3CF		;c3c2
L_C3C4:
	pop bc			;c3c4
	pop af			;c3c5
	add a,004h		;c3c6
	djnz L_C3AF		;c3c8
	inc a			;c3ca
	dec c			;c3cb
	jr nz,L_C3AB		;c3cc
	ret			;c3ce
L_C3CF:
	pop bc			;c3cf
	pop af			;c3d0
	ret			;c3d1

; ----------------------------------------------------------------------
; DATOS sin identificar  0xc3d2..0xc418  (70 bytes)
DATA_C3D2:
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c3d2  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c3e2  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c3f2  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c402  ................
	defb 000h,000h,000h,000h,000h,000h	; c412

; ======================================================================
; CODIGO 0xc418..0xc425  (13 bytes)
; ======================================================================


L_C418:
	call 09c60h		;c418
	jp m,09c4dh		;c41b
	in a,(0a8h)		;c41e
	and c			;c420
	or b			;c421
	out (0a8h),a		;c422
	ret			;c424

; ----------------------------------------------------------------------
; DATOS sin identificar  0xc425..0xc490  (107 bytes)
DATA_C425:
	defb 0e5h,0cdh,084h,09ch,04fh,006h,000h,07dh,0a4h,0b2h,021h,0c5h,0fch,009h,077h,0e1h	; c425  ....O..}..!...w.
	defb 079h,018h,0e0h,0f5h,07ch,007h,007h,0e6h,003h,05fh,03eh,0c0h,007h,007h,01dh,0f2h	; c435  y...|...._>.....
	defb 069h,09ch,05fh,02fh,04fh,0f1h,0f5h,0e6h,003h,03ch,047h,03eh,0abh,0c6h,055h,010h	; c445  i._/O....<G>..U.
	defb 0fch,057h,0a3h,047h,0f1h,0a7h,0c9h,0f5h,07ah,0e6h,0c0h,04fh,0f1h,0f5h,057h,0dbh	; c455  .W.G....z..O..W.
	defb 0a8h,047h,0e6h,03fh,0b1h,0d3h,0a8h,07ah,00fh,00fh,0e6h,003h,057h,03eh,0abh,0c6h	; c465  .G.?...z....W>..
	defb 055h,015h,0f2h,09ch,09ch,0a3h,057h,07bh,02fh,067h,03ah,0ffh,0ffh,02fh,06fh,0a4h	; c475  U.....W{/g:../o.
	defb 0b2h,032h,0ffh,0ffh,078h,0d3h,0a8h,0f1h,0e6h,003h,0c9h	; c485  .2..x......

; ======================================================================
; CODIGO 0xc490..0xc495  (5 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; CONMUTADOR DE SLOTS  (se ejecuta en 0xE22C, y el juego se
; queda con una copia en 0xF000)
; ############################################################
; 71 bytes con SEIS puntos de entrada que hacen todos lo mismo
; con distintos parametros: conmutar una pagina a una de las dos
; configuraciones anotadas por el buscador. Tres entradas usan la
; del BASIC y tres la de todo RAM, y cada terna cubre las paginas
; 0, 1 y 2. La pagina 3 no se toca nunca.
; Antes de arrancar el juego, la secuencia de carga los copia a
; 0xF000 y les reescribe los punteros a la tabla: por eso el
; juego llama luego a 0xF000, 0xF014 y 0xF019.
; ----------------------------------------------------------------------
L_C490:
	ld hl,0e291h		;c490
	jr $+27		;c493

; ----------------------------------------------------------------------
; DATOS sin identificar  0xc495..0xc4ae  (25 bytes)
DATA_C495:
	defb 021h,091h,0e2h,018h,01ah,021h,091h,0e2h,018h,01bh,021h,093h,0e2h,018h,00ah,021h	; c495  !....!....!....!
	defb 093h,0e2h,018h,00bh,021h,093h,0e2h,018h,00ch	; c4a5  ....!....

; ======================================================================
; CODIGO 0xc4ae..0xc4b4  (6 bytes)
; ======================================================================


L_C4AE:
	ld d,003h		;c4ae
	ld e,0fch		;c4b0
	jr $+12		;c4b2

; ----------------------------------------------------------------------
; DATOS sin identificar  0xc4b4..0xc4be  (10 bytes)
DATA_C4B4:
	defb 016h,00ch,01eh,0f3h,018h,004h,016h,030h,01eh,0cfh	; c4b4  .......0..

; ======================================================================
; CODIGO 0xc4be..0xc4d6  (24 bytes)
; ======================================================================


L_C4BE:
	di			;c4be
	ld a,(hl)			;c4bf
	and d			;c4c0
	ld b,a			;c4c1
	ld a,(0ffffh)		;c4c2
	cpl			;c4c5
	and e			;c4c6
	or b			;c4c7
	ld (0ffffh),a		;c4c8
	dec hl			;c4cb
	ld a,(hl)			;c4cc
	and d			;c4cd
	ld b,a			;c4ce
	in a,(0a8h)		;c4cf
	and e			;c4d1
	or b			;c4d2
	out (0a8h),a		;c4d3
	ret			;c4d5

; ----------------------------------------------------------------------
; DATOS sin identificar  0xc4d6..0xc4d7  (1 bytes)
DATA_C4D6:
	defb 000h	; c4d6

; ======================================================================
; CODIGO 0xc4d7..0xc580  (169 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; CARGADOR TURBO
; ############################################################
; Lee un bloque de cinta a (IX) con longitud DE. No usa la BIOS
; de cassette: mide a mano la anchura de los pulsos leyendo el
; bit 7 del puerto 0xA2 (la entrada de cinta del PSG).
; Formato del bloque, verificado comparando con la RAM que vuelca
; openMSX: un byte 0x00 de sincronismo, los datos, y un byte de
; checksum tal que el XOR de todo da cero.
; ----------------------------------------------------------------------
CARGA_TURBO:		; Lee un bloque de cinta a (IX), longitud DE
	ld hl,0c580h		;c4d7   ; Mete 0xC580 en la pila: al hacer RET se ira a apagar el motor
	push hl			;c4da
	push af			;c4db
	ld a,008h		;c4dc   ; Escribe en el PPI para arrancar el motor del cassette
	out (0abh),a		;c4de
	ld a,00eh		;c4e0
	out (0a0h),a		;c4e2
	pop af			;c4e4
	inc d			;c4e5
	ex af,af'			;c4e6
	dec d			;c4e7
	di			;c4e8
	ld a,005h		;c4e9
	ld c,a			;c4eb
	cp a			;c4ec
L_C4ED:
	call L_C55D		;c4ed
	jr nc,L_C4ED		;c4f0
	ld hl,00415h		;c4f2
L_C4F5:
	djnz L_C4F5		;c4f5
	dec hl			;c4f7
	ld a,h			;c4f8
	or l			;c4f9
	jr nz,L_C4F5		;c4fa
	call L_C559		;c4fc
	jr nc,L_C4ED		;c4ff
L_C501:
	ld b,09ch		;c501
	call L_C559		;c503
	jr nc,L_C4ED		;c506
	ld a,0c6h		;c508
	cp b			;c50a
	jr nc,L_C4ED		;c50b
	inc h			;c50d
	jr nz,L_C501		;c50e
L_C510:
	ld b,0c9h		;c510
	call L_C55D		;c512
	jr nc,L_C4ED		;c515
	ld a,b			;c517
	cp 0d4h		;c518
	jr nc,L_C510		;c51a
	call L_C55D		;c51c
	ret nc			;c51f
	ld h,000h		;c520
	ld b,0b0h		;c522
	jr L_C53E		;c524
L_C526:
	ex af,af'			;c526
	jr nz,L_C52E		;c527
	ld (ix+000h),l		;c529
	jr L_C538		;c52c
L_C52E:
	rr c		;c52e
	xor l			;c530
	ret nz			;c531
	ld a,c			;c532
	rla			;c533
	ld c,a			;c534
	inc de			;c535
	jr L_C53A		;c536
L_C538:
	inc ix		;c538
L_C53A:
	dec de			;c53a
	ex af,af'			;c53b
	ld b,0b2h		;c53c
L_C53E:
	ld l,001h		;c53e
L_C540:
	call L_C559		;c540
	ret nc			;c543
	ld a,0cbh		;c544
	cp b			;c546
	rl l		;c547
	ld b,0b0h		;c549
	jp nc,L_C540		;c54b
	ld a,h			;c54e
	xor l			;c54f
	ld h,a			;c550
	ld a,d			;c551
	or e			;c552
	jr nz,L_C526		;c553
	ld a,h			;c555
	cp 001h		;c556
	ret			;c558
L_C559:
	call L_C55D		;c559
	ret nc			;c55c
L_C55D:
	ld a,016h		;c55d
L_C55F:
	dec a			;c55f
	jr nz,L_C55F		;c560
	and a			;c562
L_C563:
	inc b			;c563
	nop			;c564
	ret z			;c565
	ld a,000h		;c566
	in a,(0a2h)		;c568
	cpl			;c56a
	xor c			;c56b
	and 080h		;c56c
	jp z,L_C563		;c56e
	ld a,c			;c571
	cpl			;c572
	ld c,a			;c573
	ld a,r		;c574
	and 00fh		;c576
	out (099h),a		;c578
	ld a,087h		;c57a
	out (099h),a		;c57c
	scf			;c57e
	ret			;c57f

; ----------------------------------------------------------------------
; DATOS sin identificar  0xc580..0xc58f  (15 bytes)
PARA_MOTOR:		; Apaga el motor del cassette y restaura el registro 1 del VDP
	defb 01eh,013h,03eh,009h,0d3h,0abh,03eh,001h,0d3h,099h,03eh,087h,0d3h,099h,0c9h	; c580  ..>...>...>....

; ======================================================================
; CODIGO 0xc58f..0xc640  (177 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; ENTRADA DEL CARGADOR  (BLOAD "cas:",R)
; ############################################################
; Verificado en openMSX: breakpoint alcanzado a los 100,7 s de
; tiempo emulado, justo despues del logo de Topo.
; ----------------------------------------------------------------------
SLOTS_START:		; Punto de entrada: relocaliza todo y arranca la carga
	di			;c58f   ; Apaga interrupciones para el resto del proceso
	ld hl,0dac0h		;c590   ; Copia 100 bytes de 0xDAC0 a 0xDEA8: deja preparada la zona de parcheo por cinta
	ld de,0dea8h		;c593
	ld bc,00064h		;c596
	ldir		;c599
	call 00041h		;c59b   ; BIOS DISSCR - Inhibits the screen display | DISSCR: apaga la pantalla durante la carga
	call BUSCA_RAM		;c59e   ; Localiza la RAM de todas las paginas
	di			;c5a1
	ld hl,0c490h		;c5a2   ; Copia el conmutador de slots a 0xE22C
	ld de,0e22ch		;c5a5
	ld bc,00047h		;c5a8
	ldir		;c5ab
	ld hl,SECUENCIA_CARGA		;c5ad   ; Copia la secuencia de carga a 0xE09C
	ld de,0e09ch		;c5b0
	ld bc,00085h		;c5b3
	ldir		;c5b6
	jp 0e09ch		;c5b8   ; Y salta a ella: a partir de aqui se ejecuta desde RAM alta

; ----------------------------------------------------------------------
; ############################################################
; SECUENCIA DE CARGA  (se ejecuta en 0xE09C)
; ############################################################
; Aqui esta lo mas llamativo de toda la carga: el juego se mete en
; la PAGINA 0, encima de donde esta la ROM del BIOS, y despues se
; recolocan tres trozos a RAM alta. Los 35 KB que quedan abajo son
; graficos y mapas, y el juego los volvera a tapar con la ROM:
; solo los destapa un momento cada vez que carga un nivel.
; ----------------------------------------------------------------------
SECUENCIA_CARGA:		; Carga los dos bloques turbo, recoloca y arranca el juego
	call 0e245h		;c5bb   ; Conmuta una pagina a RAM antes de cargar la portada
	ld ix,088b8h		;c5be   ; Destino del bloque 1: la pantalla de portada
	ld de,03064h		;c5c2   ; 12388 bytes
	xor a			;c5c5
	scf			;c5c6
	call CARGA_TURBO		;c5c7
	call 088b8h		;c5ca   ; Ejecuta la portada, que la vuelca a la VRAM y vuelve
	call 0e23bh		;c5cd   ; Ahora si: mete RAM tambien en la pagina 0
	call 0e240h		;c5d0
	ld ix,00000h		;c5d3   ; Destino del bloque 2: el juego entero, en la pagina 0
	ld de,0a695h		;c5d7   ; 42645 bytes
	xor a			;c5da
	scf			;c5db
	call CARGA_TURBO		;c5dc
	ld hl,08a41h		;c5df   ; Recoloca el reproductor de sonido a 0xB000 (2201 bytes)
	ld de,0b000h		;c5e2
	ld bc,00899h		;c5e5
	ldir		;c5e8
	ld hl,092dah		;c5ea   ; Recoloca el nucleo a 0xBD00 (2112 bytes): ahi va el punto de entrada
	ld de,0bd00h		;c5ed
	ld bc,00840h		;c5f0
	ldir		;c5f3
	ld hl,09b1ah		;c5f5   ; Recoloca el motor del juego a 0xD000 (2938 bytes)
	ld de,0d000h		;c5f8
	ld bc,00b7ah		;c5fb
	ldir		;c5fe
	ld hl,0f065h		;c600   ; Reapunta los tres primeros vectores del conmutador a la tabla de 0xF065
	ld (0e22dh),hl		;c603
	ld (0e232h),hl		;c606
	ld (0e237h),hl		;c609
	ld hl,0f067h		;c60c   ; Y los otros tres a la de 0xF067
	ld (0e23ch),hl		;c60f
	ld (0e241h),hl		;c612
	ld (0e246h),hl		;c615
	ld hl,0e22ch		;c618   ; Copia el conmutador de slots a 0xF000, ya parcheado
	ld de,0f000h		;c61b
	ld bc,0006eh		;c61e
	ldir		;c621
	ld hl,0dea8h		;c623   ; Mecanismo de parcheo: si en 0xDEA8 hay tres 0xC9 seguidos...
	ld b,003h		;c626
L_C628:
	ld a,(hl)			;c628
	cp 0c9h		;c629
	jr nz,L_C63B		;c62b
	inc hl			;c62d
	djnz L_C628		;c62e
	ld b,(hl)			;c630   ; ...lee un contador y aplica esa cantidad de parches (direccion, valor)
	inc hl			;c631
L_C632:
	ld e,(hl)			;c632
	inc hl			;c633
	ld d,(hl)			;c634
	inc hl			;c635
	ld a,(hl)			;c636
	inc hl			;c637
	ld (de),a			;c638
	djnz L_C632		;c639
L_C63B:
	ld a,000h		;c63b   ; A = 0: le dice al juego que es un arranque normal, no un fin de partida
	jp 0c000h		;c63d   ; Arranca el juego

; ----------------------------------------------------------------------
; DATOS sin identificar  0xc640..0xc641  (1 bytes)
DATA_C640:
	defb 0c9h	; c640
