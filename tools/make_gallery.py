#!/usr/bin/env python3
"""Genera una galeria HTML con las 29 pantallas del juego.

Todo el material sale del propio binario: los mapas, la fuente, los colores y
hasta el logo de la cabecera, que se recorta de la pantalla de presentacion
(tabla de nombres de 0x5CC0). Las imagenes van embebidas como data URI para que
la pagina sea autocontenida.
"""
import base64
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from render_maps import render, png, PALETA  # noqa: E402

ORG = 0x4000


def recorta(d, base_nt, col0, fila0, ncols, nfilas, escala=3):
    """Renderiza un recorte rectangular de una tabla de nombres."""
    patrones = d[0x4000 - ORG:0x4800 - ORG]
    colores = d[0x4800 - ORG:0x5000 - ORG]
    nt = d[base_nt - ORG:base_nt - ORG + 0x300]
    sub = bytes(nt[(fila0 + y) * 32 + col0 + x]
                for y in range(nfilas) for x in range(ncols))
    return render(patrones, colores, sub, ncols, nfilas, escala, backdrop=1)


def b64(path):
    return base64.b64encode(open(path, "rb").read()).decode()


def main(binpath, mapdir, out):
    d = open(binpath, "rb").read()

    # El logo "TEMPTATIONS" ocupa las filas 5..13 de la pantalla de presentacion.
    w, h, img = recorta(d, 0x5CC0, 6, 5, 21, 9, escala=3)
    png("/tmp/logo.png", w, h, img)

    # Y la pantalla de presentacion entera, con el texto del monje.
    w2, h2, img2 = recorta(d, 0x5CC0, 0, 0, 32, 24, escala=2)
    png("/tmp/menu.png", w2, h2, img2)

    NIVELES = [
        ("Nivel 1", "La necropolis", "Cementerio de columnas rotas y calaveras."),
        ("Nivel 2", "El bosque", "Vegetacion y cavernas."),
        ("Nivel 3", "Las ruinas", "Restos de una ciudad antigua."),
        ("Nivel 4", "El fondo marino", "Sin gravedad: Arnulfo nada convertido en pez."),
    ]

    filas = []
    for niv in range(4):
        cartas = []
        for p in range(7):
            i = niv * 7 + p
            fn = f"nivel{niv+1}_pantalla{p+1}_{i:02d}.png"
            addr = 0x9000 + i * 512
            cartas.append(f"""      <figure class="pantalla">
        <img src="data:image/png;base64,{b64(os.path.join(mapdir, fn))}"
             alt="Nivel {niv+1}, pantalla {p+1}" loading="lazy">
        <figcaption><span class="num">{p+1}</span><span class="dir">{addr:#06x}</span></figcaption>
      </figure>""")
        t, sub, desc = NIVELES[niv]
        filas.append(f"""  <section class="nivel" id="nivel{niv+1}">
    <header class="nivel-cab">
      <h2>{t}<span class="sep">·</span><em>{sub}</em></h2>
      <p>{desc}</p>
    </header>
    <div class="rejilla">
{chr(10).join(cartas)}
    </div>
  </section>""")

    final_b64 = b64(os.path.join(mapdir, "final_28.png"))

    html = f"""<title>Temptations (1988) — las 29 pantallas</title>
<style>
:root {{
  /* Paleta tomada del TMS9918, el chip de video del MSX1: son literalmente los
     colores con los que esta dibujado el juego. */
  --tinta:      #cccccc;   /* gris 14 */
  --tinta-baja: #7d7f86;
  --fondo:      #000000;   /* el negro de la pantalla */
  --panel:      #0d0f14;
  --borde:      #24272f;
  --acento:     #ff897d;   /* rojo claro 9: las columnas y el protagonista */
  --cyan:       #65dbef;   /* cyan 7 */
  --verde:      #3eb849;   /* verde 2: la hierba */
  --sombra: 0 0 0 1px var(--borde);
}}
@media (prefers-color-scheme: light) {{
  :root {{
    --tinta: #1b1c20; --tinta-baja: #5c5f68; --fondo: #e8e6e0;
    --panel: #f6f5f1; --borde: #cfccc4;
    --acento: #b23f34; --cyan: #1e6f80; --verde: #2c7a35;
  }}
}}
:root[data-theme="dark"] {{
  --tinta: #cccccc; --tinta-baja: #7d7f86; --fondo: #000000;
  --panel: #0d0f14; --borde: #24272f;
  --acento: #ff897d; --cyan: #65dbef; --verde: #3eb849;
}}
:root[data-theme="light"] {{
  --tinta: #1b1c20; --tinta-baja: #5c5f68; --fondo: #e8e6e0;
  --panel: #f6f5f1; --borde: #cfccc4;
  --acento: #b23f34; --cyan: #1e6f80; --verde: #2c7a35;
}}

* {{ box-sizing: border-box; }}
body {{
  margin: 0; background: var(--fondo); color: var(--tinta);
  font: 15px/1.65 ui-monospace, "SF Mono", Menlo, Consolas, monospace;
  padding: 0 1.25rem 5rem;
}}
.envoltorio {{ max-width: 1180px; margin: 0 auto; }}

header.principal {{
  display: flex; flex-direction: column; align-items: center; gap: 1.5rem;
  padding: 3.5rem 0 2.5rem; text-align: center;
}}
header.principal img {{
  width: min(100%, 620px); height: auto;
  image-rendering: pixelated;   /* son pixeles de 1988: que se vean como tales */
}}
.entradilla {{ max-width: 60ch; color: var(--tinta-baja); }}
.entradilla strong {{ color: var(--tinta); font-weight: 400; }}

.ficha {{
  display: flex; flex-wrap: wrap; justify-content: center; gap: 0 1.5rem;
  font-size: 12px; letter-spacing: .08em; text-transform: uppercase;
  color: var(--tinta-baja); border-top: 1px solid var(--borde);
  border-bottom: 1px solid var(--borde); padding: .85rem 0; width: 100%;
}}
.ficha b {{ color: var(--acento); font-weight: 400; }}

.nivel {{ margin-top: 3.5rem; }}
.nivel-cab {{ border-left: 3px solid var(--acento); padding-left: 1rem; margin-bottom: 1.25rem; }}
.nivel-cab h2 {{
  margin: 0; font-size: 1.05rem; font-weight: 400; letter-spacing: .06em;
  text-transform: uppercase; text-wrap: balance;
}}
.nivel-cab em {{ color: var(--cyan); font-style: normal; }}
.sep {{ color: var(--tinta-baja); margin: 0 .6rem; }}
.nivel-cab p {{ margin: .35rem 0 0; color: var(--tinta-baja); font-size: 13px; }}

.rejilla {{
  display: grid; gap: 1rem;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
}}
.pantalla {{ margin: 0; background: var(--panel); box-shadow: var(--sombra); }}
.pantalla img {{ display: block; width: 100%; height: auto; image-rendering: pixelated; }}
figcaption {{
  display: flex; justify-content: space-between; align-items: baseline;
  padding: .5rem .7rem; font-size: 11px; letter-spacing: .06em;
  color: var(--tinta-baja); border-top: 1px solid var(--borde);
}}
.num {{ color: var(--tinta); }}
.dir {{ font-variant-numeric: tabular-nums; color: var(--verde); }}

.final {{ margin-top: 3.5rem; }}
.final img {{
  display: block; width: 100%; max-width: 780px; height: auto;
  image-rendering: pixelated; box-shadow: var(--sombra);
}}
.doscol {{ display: grid; gap: 2rem; grid-template-columns: 1fr; align-items: start; }}
@media (min-width: 860px) {{ .doscol {{ grid-template-columns: 1.2fr .8fr; }} }}
.nota {{ color: var(--tinta-baja); font-size: 13px; }}
.nota h3 {{ color: var(--tinta); font-size: .95rem; font-weight: 400;
           letter-spacing: .06em; text-transform: uppercase; margin: 0 0 .6rem; }}
.nota code {{ color: var(--acento); }}

footer {{ margin-top: 4rem; padding-top: 1.25rem; border-top: 1px solid var(--borde);
          color: var(--tinta-baja); font-size: 12px; }}
</style>

<div class="envoltorio">
  <header class="principal">
    <img src="data:image/png;base64,{b64('/tmp/logo.png')}"
         alt="Logo de Temptations, recortado de la pantalla de presentacion del juego">
    <p class="entradilla">Las <strong>29 pantallas</strong> del juego de Topo Soft para MSX,
      dibujadas directamente desde el binario de la cinta. Cada una es un bloque de
      512 bytes: 32 columnas por 16 filas, un byte de tile por casilla.</p>
    <div class="ficha">
      <span>Topo Soft · <b>1988</b></span>
      <span>Programa <b>Luis Lopez Navarro</b></span>
      <span>Musica <b>Gominolas</b></span>
      <span>MSX · 64K</span>
    </div>
  </header>

{chr(10).join(filas)}

  <section class="final">
    <div class="nivel-cab">
      <h2>Pantalla 29<span class="sep">·</span><em>El final</em></h2>
      <p>La recompensa por superar las 28 pantallas.</p>
    </div>
    <div class="doscol">
      <img src="data:image/png;base64,{final_b64}" alt="Pantalla final del juego">
      <div class="nota">
        <h3>El castigo del tramposo</h3>
        <p>El texto dice <em>«Aleluya, oh fray Arnulfo. Superando todos los peligros
        del mal has ganado el cielo. Solum victorius est gloria. ¿Te atreveras con
        Alehop?»</em></p>
        <p>Pero si el juego detecta que has hecho trampas, escribe encima de la
        ultima linea de esta misma pantalla el reproche
        <code>POR QUE NO PRUEBAS SIN POKES</code>. Nunca llega a saltar: ninguna
        instruccion del binario enciende la bandera que lo dispara. Topo la dejo
        armada por si alguien pokeaba ese byte.</p>
      </div>
    </div>
  </section>

  <footer>
    Imagenes generadas con <code>tools/render_maps.py</code> a partir de
    <code>dump/turbo2_ram.bin</code>. Los mapas viven en 0x9000 y ocupan 512 bytes
    cada uno; la direccion de cada pantalla aparece bajo su miniatura.
  </footer>
</div>
"""
    open(out, "w", encoding="utf-8").write(html)
    print(f"{out}: {len(html)//1024} KB")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])
