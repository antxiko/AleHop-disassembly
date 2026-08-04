# Ale Hop! (Topo Soft, 1988, MSX1) - desensamblado
#
# `make` regenera los listados comentados desde el binario y comprueba que al
# reensamblarlos sale EXACTAMENTE el original, byte a byte.
#
# Esa comprobacion es lo que hace utilizable el desensamblado: mientras este en
# verde, cualquier cambio en el juego se puede atribuir con seguridad a lo que
# hemos tocado y no a un error de interpretacion del binario.
#
# Particularidad de este juego: el bloque se carga entero en 0x0000 y luego el
# cargador recoloca tres trozos a 0xB000, 0xBD00 y 0xD000. Por eso el juego no
# es un listado sino CINCO, cada uno con el `org` de donde se ejecuta de verdad;
# concatenados en orden de carga dan el bloque original. Ver tools/split_trace.py.

TSX  := alehop.tsx
# sha256 de la cinta con la que se hizo este desensamblado.
TSX_SHA := 499d74c7a3612e8db402d041c909f3d1b5ae193f11194a85586a665edc73bb64
SYMS := work/msx.sym
MSXGL ?= /Users/fx-media/Documents/BARCOEMESEKS/MSXgl/engine/src

# nombre:org de cada trozo del juego, EN ORDEN DE CARGA
TROZOS := datos:0x0000 sonido:0xB000 nucleo:0xBD00 extra:0xD000 cola:0xA694

.PHONY: all verify clean extract syms listados sanity test cinta

all: verify

# ---------------------------------------------------------------- extraccion
# La cinta no se distribuye con el repositorio (ver AVISO-LEGAL.md), asi que lo
# primero es decirlo claro en vez de soltar un error de make que no explica nada.
cinta:
	@if [ ! -f "$(TSX)" ]; then \
	  echo ""; \
	  echo "  Falta la imagen de cinta: $(TSX)"; \
	  echo ""; \
	  echo "  No se distribuye con este repositorio, solo el desensamblado"; \
	  echo "  comentado (ver AVISO-LEGAL.md). Para reconstruirlo todo hace"; \
	  echo "  falta tu propia copia del TSX de Ale Hop!, con ese nombre y en"; \
	  echo "  la raiz del proyecto:"; \
	  echo ""; \
	  echo "      cp \"/donde/lo/tengas/Ale Hop! ... .tsx\"  $(TSX)"; \
	  echo ""; \
	  echo "  Debe dar este sha256:"; \
	  echo "      $(TSX_SHA)"; \
	  echo ""; \
	  echo "  Sin la cinta si puedes: leer los listados de src/, y ejecutar"; \
	  echo "  los tests que no dependen del binario, con 'make test'."; \
	  echo ""; \
	  exit 1; \
	fi

.PHONY: cinta

extract: extracted/.stamp
extracted/.stamp: tools/tsx_parse.py | cinta
	python3 tools/tsx_parse.py "$(TSX)" extracted
	@mkdir -p work dump
	python3 -c "d=open('extracted/07_TOPO.bin','rb').read(); open('work/TOPO.raw','wb').write(d[6:])"
	python3 -c "d=open('extracted/09_SLOTS.bin','rb').read(); open('work/SLOTS.raw','wb').write(d[6:])"
	python3 -c "d=open('extracted/10_raw_10.bin','rb').read(); open('dump/turbo1_cinta.bin','wb').write(d[1:-1])"
	python3 -c "d=open('extracted/11_raw_10.bin','rb').read(); open('dump/turbo2_cinta.bin','wb').write(d[1:-1])"
	touch $@

syms:
	@mkdir -p work
	@if [ -d "$(MSXGL)" ]; then \
	  python3 tools/gen_msx_syms.py "$(MSXGL)" $(SYMS); \
	else \
	  echo "MSXgl no esta en $(MSXGL); se conserva el $(SYMS) que ya hay."; \
	fi

# ------------------------------------------------------- imagen de ejecucion
# El trazado del juego NO se hace sobre la imagen de la cinta sino sobre la RAM
# de 64K tal y como queda justo antes de arrancar, porque es ahi donde las
# direcciones de los CALL y los JP significan algo. La produce openMSX cargando
# la cinta original, o sea que el propio cargador del juego hace de decodificador.
dump/full_recolocado.bin: tools/omsx_load.tcl | cinta
	@mkdir -p dump
	ALEHOP_TSX="$(PWD)/$(TSX)" ALEHOP_OUT="$(PWD)/dump" \
	  openmsx -machine Philips_VG_8020-20 -script tools/omsx_load.tcl
	@python3 -c "import sys;\
	a=open('dump/turbo2_ram.bin','rb').read();\
	b=open('dump/turbo2_cinta.bin','rb').read();\
	sys.exit(0 if a==b else 'la RAM volcada NO coincide con la cinta')"
	@echo "  la RAM volcada coincide byte a byte con la cinta"

# ------------------------------------------------------------------ trazado
work/game64.trace.json: tools/z80trace.py src/game.entries src/game_sonido.entries \
                        src/game.nocode dump/full_recolocado.bin
	@mkdir -p work
	cat src/game.entries src/game_sonido.entries > work/game_all.entries
	python3 tools/z80trace.py dump/full_recolocado.bin 0x0000 work/game_all.entries \
	  work/game64 src/game.nocode

work/game_datos.trace.json: work/game64.trace.json tools/split_trace.py
	python3 tools/split_trace.py dump/full_recolocado.bin work/game64.trace.json work

work/slots.trace.json: tools/z80trace.py src/slots.entries extract
	@mkdir -p work
	python3 tools/z80trace.py work/SLOTS.raw 0xC350 src/slots.entries work/slots

work/topo.trace.json: tools/z80trace.py src/topo.entries extract
	@mkdir -p work
	python3 tools/z80trace.py work/TOPO.raw 0x9470 src/topo.entries work/topo

work/turbo1.trace.json: tools/z80trace.py src/turbo1.entries extract
	@mkdir -p work
	python3 tools/z80trace.py dump/turbo1_cinta.bin 0x88B8 src/turbo1.entries work/turbo1

# ----------------------------------------------------------------- listados
listados: src/alehop_topo.asm src/alehop_slots.asm src/alehop_portada.asm juego

src/alehop_topo.asm: work/topo.trace.json src/topo.notes tools/mkasm.py
	python3 tools/mkasm.py work/TOPO.raw 0x9470 work/topo.trace.json \
	  src/topo.notes $(SYMS) $@ "ALE HOP! - MSX - TOPO: logo de Topo Soft"

src/alehop_slots.asm: work/slots.trace.json src/slots.notes tools/mkasm.py
	python3 tools/mkasm.py work/SLOTS.raw 0xC350 work/slots.trace.json \
	  src/slots.notes $(SYMS) $@ "ALE HOP! - MSX - SLOTS: buscador de RAM y cargador turbo"

src/alehop_portada.asm: work/turbo1.trace.json src/turbo1.notes tools/mkasm.py
	python3 tools/mkasm.py dump/turbo1_cinta.bin 0x88B8 work/turbo1.trace.json \
	  src/turbo1.notes $(SYMS) $@ "ALE HOP! - MSX - bloque turbo 1: pantalla de portada"

juego: work/game_datos.trace.json src/game_datos.notes tools/mkasm.py
	@for t in $(TROZOS); do \
	  n=$${t%%:*}; o=$${t##*:}; \
	  python3 tools/mkasm.py work/game_$$n.bin $$o work/game_$$n.trace.json \
	    src/game_$$n.notes $(SYMS) src/alehop_game_$$n.asm \
	    "ALE HOP! - MSX - juego, trozo '$$n' (se ejecuta en $$o)"; \
	done

.PHONY: juego

# -------------------------------------------------------------- verificacion
verify: listados sanity test
	@echo "=================================================================="
	@echo " Reproducibilidad: ensamblar el listado debe dar el binario exacto"
	@echo "=================================================================="
	@./tools/verify_build.sh src/alehop_slots.asm   work/SLOTS.raw        0xC350
	@./tools/verify_build.sh src/alehop_topo.asm    work/TOPO.raw         0x9470
	@./tools/verify_build.sh src/alehop_portada.asm dump/turbo1_cinta.bin 0x88B8
	@for t in $(TROZOS); do \
	  n=$${t%%:*}; o=$${t##*:}; \
	  ./tools/verify_build.sh src/alehop_game_$$n.asm work/game_$$n.bin $$o || exit 1; \
	done
	@echo "------------------------------------------------------------------"
	@echo " Y los cinco trozos concatenados en orden de carga, el bloque entero"
	@echo "------------------------------------------------------------------"
	@for t in $(TROZOS); do n=$${t%%:*}; \
	  pasmo --bin src/alehop_game_$$n.asm work/_$$n.bin; done
	@cat work/_datos.bin work/_sonido.bin work/_nucleo.bin work/_extra.bin \
	     work/_cola.bin > work/juego_reensamblado.bin
	@cmp work/juego_reensamblado.bin dump/turbo2_cinta.bin \
	  && echo "OK: el juego entero reensambla byte a byte"
	@rm -f work/_*.bin
	@echo "=================================================================="
	@echo " TODO VERDE: los cuatro modulos reensamblan al original"
	@echo "=================================================================="

# El control de sanidad va aparte de la reproducibilidad porque detecta un fallo
# que esta NO ve: si el trazador marca graficos como codigo, el binario sigue
# saliendo identico (los bytes son los mismos) pero el listado miente.
sanity: work/game64.trace.json work/game_datos.trace.json
	@echo "=================================================================="
	@echo " Sanidad del trazado: las zonas de datos no pueden salir como codigo"
	@echo "=================================================================="
	@python3 tools/check_trace.py work/game64.trace.json src/game.nocode
	@echo ""
	@echo "=================================================================="
	@echo " Presupuesto del binario: no deben quedar bytes sin explicar"
	@echo "=================================================================="
	@python3 tools/presupuesto.py work src

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@python3 -m unittest discover -s tests -v

# Las imagenes de los seis niveles. Cada uno da dos: la tira entera de 256
# columnas y una pantalla de verdad con las tres bandas (fondo, mapa, marcador).
imagenes: extract
	@mkdir -p docs/niveles
	python3 tools/render_niveles.py dump/turbo2_cinta.bin docs/niveles

.PHONY: imagenes

# La web de GitHub Pages: ingles en docs/ y castellano en docs/es/. El diseno es
# el compartido por los desensamblados de la serie (tools/estilo_web.py) y las
# paginas salen autocontenidas, con las imagenes embebidas.
web: imagenes
	python3 tools/md2html.py docs en
	python3 tools/md2html.py docs/es es
	python3 tools/make_web.py dump/turbo2_cinta.bin docs docs/index.html en
	python3 tools/make_web.py dump/turbo2_cinta.bin docs docs/es/index.html es
	@touch docs/.nojekyll
	@python3 tools/check_enlaces.py docs

.PHONY: web

# No borra los .asm: son el producto que se ofrece para leer sin compilar nada.
clean:
	rm -f work/*.trace.json work/*.blocks work/game_all.entries work/game_*.bin
	rm -rf dump extracted
