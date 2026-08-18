#!/usr/bin/env python3
"""Genera la portada de la web, en ingles y en castellano.

El diseno es el mismo que el de los demas desensamblados de la serie y vive en
tools/estilo_web.py: aqui solo va el contenido de este juego.

Todo el material visual sale del propio binario -incluido el logo de la
cabecera, recortado de la pantalla de presentacion- y las imagenes van
embebidas como data URI, de modo que cada pagina es un fichero autocontenido.

  python3 tools/make_web.py <bloque del juego.bin> <dir imagenes> <salida.html> [en|es]

La inglesa se escribe en docs/index.html y la castellana en docs/es/index.html.
"""
import tempfile
import base64
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from estilo_web import ESTILO          # noqa: E402
from render_maps import PALETA, png    # noqa: E402

# El temporal del sistema: en Windows no hay /tmp.
TMP = tempfile.gettempdir()

REPO = "https://github.com/antxiko/AleHop-disassembly"

# Juego de graficos "B", el de la pantalla de presentacion, de donde se recorta
# el logo de la cabecera.
GFX_B = [(0x6D35, 0x0000), (0x7137, 0x2000), (0x74CF, 0x0800),
         (0x7BE9, 0x2800), (0x5FEE, 0x1000), (0x66C9, 0x3000)]
MAPA_PRESENTACION = 0x4000

# Los textos de los dos idiomas van juntos a proposito: si se toca uno, se ve
# enseguida que el otro se ha quedado descolgado.
T = {
    "en": dict(
        titulo="Ale Hop! (1988) — a commented disassembly",
        claim="A 1988 cassette tape, taken apart one instruction at a time. "
              "<b>All 42,645 bytes of the game are accounted for</b>.",
        ficha=["Topo Soft · <b>1988</b>", "Code <b>Alberto L. Navarro</b>",
               "Graphics <b>LuigiLopez</b>", "MSX1 · <b>48K</b>"],
        nav=[("#numbers", "The numbers"), ("#findings", "Findings"),
             ("#screens", "The levels"), ("#method", "How it was done")],
        docnav=[("GETTING-STARTED.html", "Getting started"),
                ("THE-GAME.html", "The game"), ("THE-TAPE.html", "The tape"),
                ("THE-CODE.html", "The code"), ("FINDINGS.html", "Findings"),
                ("DEAD-BYTES.html", "Dead bytes")],
        otro=("es/", "En castellano"),
        h_num="The game in numbers", h_find="What turned up when we took it apart",
        h_scr="The six levels", h_met="How it was done",
        cifras=[("100%", "of the binary accounted for"), ("57", "routines identified"),
                ("6", "level maps"), ("4,588", "bytes of code"),
                ("38,057", "bytes of data"), ("0", "bytes unidentified")],
        nota_num="Only 11% being code doesn't mean anything is missing: this game is "
                 "<b style='color:var(--tinta);font-weight:400'>89% data</b>. The "
                 "graphics, six level strips of 256 columns each and their parallax "
                 "backgrounds.",
        nota_scr="These aren't screen captures. They're drawn from the game's own "
                 "data: decompressing the graphics with the routine the game uses "
                 "and assembling the maps. Each level is a 256-column strip of "
                 "which only 32 are ever on screen.",
        nivel="Level", tira="Full strip", pantalla="On screen",
        pie_leg="Documentation and preservation work on a 1988 game. The code and "
                "artwork belong to their authors and to Topo Soft. The tape image "
                "is not distributed.",
    ),
    "es": dict(
        titulo="Ale Hop! (1988) — desensamblado comentado",
        claim="Una cinta de cassette de 1988, desmontada instrucción a instrucción. "
              "<b>Los 42.645 bytes del juego están explicados</b>.",
        ficha=["Topo Soft · <b>1988</b>", "Programa <b>Alberto L. Navarro</b>",
               "Gráficos <b>LuigiLopez</b>", "MSX1 · <b>48K</b>"],
        nav=[("#numbers", "Las cifras"), ("#findings", "Hallazgos"),
             ("#screens", "Los niveles"), ("#method", "Cómo se hizo")],
        docnav=[("EMPEZAR.html", "Empezar"), ("EL-JUEGO.html", "El juego"),
                ("LA-CINTA.html", "La cinta"), ("EL-CODIGO.html", "El código"),
                ("HALLAZGOS.html", "Hallazgos"),
                ("BYTES-MUERTOS.html", "Bytes muertos")],
        otro=("../", "In English"),
        h_num="El juego en cifras", h_find="Lo que apareció al desmontarlo",
        h_scr="Los seis niveles", h_met="Cómo se hizo",
        cifras=[("100%", "del binario explicado"), ("57", "rutinas identificadas"),
                ("6", "mapas de nivel"), ("4.588", "bytes de código"),
                ("38.057", "bytes de datos"), ("0", "bytes sin identificar")],
        nota_num="Que solo el 11% sea código no significa que falte nada: este juego es "
                 "<b style='color:var(--tinta);font-weight:400'>89% datos</b>. Los "
                 "gráficos, seis tiras de nivel de 256 columnas cada una y sus fondos "
                 "de parallax.",
        nota_scr="No son capturas de pantalla. Están dibujadas a partir de los "
                 "datos del propio juego: descomprimiendo los gráficos con la "
                 "misma regla que usa él y montando los mapas. Cada nivel es una "
                 "tira de 256 columnas de las que solo se ven 32 a la vez.",
        nivel="Nivel", tira="Tira completa", pantalla="En pantalla",
        pie_leg="Trabajo de documentación y preservación sobre un juego de 1988. "
                "El código y los gráficos son de sus autores y de Topo Soft. La "
                "imagen de cinta no se distribuye.",
    ),
}

# (titulo, cuerpo html) por idioma
HALLAZGOS = {
    "en": [
        ("The game loads on top of the ROM",
         "<p>A 64 KB MSX doesn't have 64 KB within reach: the bottom page, 0x0000 to "
         "0x3FFF, is occupied by the BIOS ROM. The usual move for a tape game is not "
         "to bother and load from 0x4000 up.</p>"
         "<p><i>Ale Hop!</i> does the opposite. It puts all 42,645 bytes <b>into page "
         "0</b>, on top of where the BIOS lives, then moves three chunks up into high "
         "RAM and covers what's left with the ROM again. The 35 KB of graphics and "
         "maps spend nearly all their time hidden under the BIOS; the game uncovers "
         "them for an instant each time it loads a level and covers them straight "
         "back up.</p>"
         "<p>It's the decision that shapes everything else, including why this "
         "disassembly is five listings instead of one.</p>"),
        ("A message almost nobody got to read",
         "<p>Clear the sixth and last level and a text scrolls past. The screen "
         "framing it has two <b>empty</b> boxes: the text isn't drawn anywhere. It "
         "sits in ASCII at 0xC3F0, and a routine reads it letter by letter, pulls "
         "each glyph's bitmap back out of video memory, and shifts it one pixel per "
         "frame.</p>{mensaje}"
         "<p>The sign-off advertises another game Topo Soft had published the year "
         "before, which in turn ended by pointing at this one.</p>"),
        ("Parallax in one instruction",
         "<p>The background moves four times slower than the track. Both blit "
         "routines read the same camera-column variable, but the background's does "
         "an <code>and 0x3F</code> on it and its map is 64 columns wide, while the "
         "track's uses the whole byte over a 256-column map. That's the entire "
         "trick.</p>"),
        ("135 bytes that never execute",
         "<p>Four stretches of perfectly coherent Z80 that no path reaches. Among "
         "them a full-screen colour effect that turns every black into transparent — "
         "3,673 of the screen's 6,144 colour bytes — which only makes sense paired "
         "with a change of backdrop colour. Half a fade that got left out.</p>"
         "{efecto}"
         "<p>Also in there: the sound library's own interrupt handler, sitting unused "
         "because the game has its own. That's the best evidence the music player "
         "arrived as a reusable library rather than as code written for this game.</p>"),
        ("Room for two levels that don't exist",
         "<p>Background maps are located with <code>0x3000 + level * 0x200</code>. "
         "There's space for eight, but only six have data: the 1,024 bytes levels 7 "
         "and 8 would occupy are 0xFF filler, and the loader stops at the sixth.</p>"),
    ],
    "es": [
        ("El juego se carga encima de la ROM",
         "<p>Un MSX de 64 KB no tiene los 64 KB a mano: la página de abajo, de 0x0000 "
         "a 0x3FFF, la ocupa la ROM del BIOS. Lo habitual en un juego de cinta es no "
         "complicarse y cargar a partir de 0x4000.</p>"
         "<p><i>Ale Hop!</i> hace lo contrario. Mete los 42.645 bytes <b>en la página "
         "0</b>, encima de donde está el BIOS, y después mueve tres trozos a RAM alta "
         "y vuelve a tapar lo que queda con la ROM. Los 35 KB de gráficos y mapas "
         "están escondidos debajo del BIOS casi todo el tiempo; el juego los destapa "
         "un instante cada vez que carga un nivel y los vuelve a tapar.</p>"
         "<p>Es la decisión que da forma a todo lo demás, incluido que este "
         "desensamblado sean cinco listados en vez de uno.</p>"),
        ("Un mensaje que casi nadie llegó a leer",
         "<p>Al superar el sexto y último nivel pasa un texto haciendo scroll. La "
         "pantalla que lo enmarca tiene dos recuadros <b>vacíos</b>: el texto no está "
         "dibujado en ninguna parte. Está en ASCII en 0xC3F0, y una rutina lo lee "
         "letra a letra, saca el dibujo de cada una de la memoria de vídeo y lo "
         "desplaza un píxel por fotograma.</p>{mensaje}"
         "<p>La despedida anuncia otro juego que Topo Soft había publicado el año "
         "anterior, que a su vez terminaba señalando a éste.</p>"),
        ("El parallax cabe en una instrucción",
         "<p>El fondo se mueve cuatro veces más despacio que la pista. Las dos "
         "rutinas de volcado leen la misma variable de columna de cámara, pero la del "
         "fondo le hace un <code>and 0x3F</code> y su mapa tiene 64 columnas, "
         "mientras que la de la pista usa el byte entero sobre un mapa de 256. Ese es "
         "todo el truco.</p>"),
        ("135 bytes que no se ejecutan nunca",
         "<p>Cuatro trozos de código Z80 perfectamente coherente a los que no llega "
         "ningún camino. Entre ellos, un efecto de color a pantalla completa que "
         "convierte todo el negro en transparente —3.673 de los 6.144 bytes de color— "
         "y que solo tiene sentido acompañado de un cambio del color de fondo. Medio "
         "fundido que se quedó fuera.</p>{efecto}"
         "<p>También está ahí el manejador de interrupción de la librería de sonido, "
         "sin usar porque el juego tiene el suyo. Es la mejor prueba de que el "
         "reproductor llegó como librería reutilizable y no como código escrito para "
         "este juego.</p>"),
        ("Sitio para dos niveles que no existen",
         "<p>Los mapas de fondo se buscan con <code>0x3000 + nivel * 0x200</code>. "
         "Hay espacio para ocho, pero solo seis tienen datos: los 1.024 bytes que "
         "ocuparían el 7 y el 8 son relleno 0xFF, y el cargador corta en el sexto.</p>"),
    ],
}

METODO = {
    "en": "<p>The game's own loader was used as the decoder: rather than "
          "reimplementing Topo Soft's turbo tape format, the original tape is loaded "
          "in openMSX and RAM is dumped at each stage. What comes out is exactly what "
          "the game sees in memory — and it matches the bytes extracted from the tape "
          "file, byte for byte.</p>"
          "<p>From there the code is traced by following control flow from the entry "
          "points, never by disassembling linearly: 35 KB of graphics decoded as "
          "instructions would throw everything out of alignment. Regions known to be "
          "data are declared off-limits, because one bad seed sends the tracer into "
          "the artwork and inflates coverage with nonsense.</p>"
          "<p>Two separate checks guard the result. <b>Reproducibility</b>: every "
          "listing reassembles to the original binary, byte for byte. And a "
          "<b>budget</b>: every byte must be either traced code or a data range named "
          "in the notes. The second one exists because the first can't see "
          "misinterpretation — if graphics get marked as code, the bytes still come "
          "out identical and only the listing lies.</p>",
    "es": "<p>Se usó el propio cargador del juego como decodificador: en vez de "
          "reimplementar el formato turbo de Topo Soft, la cinta original se carga en "
          "openMSX y se vuelca la RAM en cada etapa. Lo que sale es exactamente lo "
          "que el juego ve en memoria, y coincide byte a byte con lo extraído del "
          "fichero de cinta.</p>"
          "<p>A partir de ahí el código se traza siguiendo el flujo desde los puntos "
          "de entrada, nunca desensamblando en línea recta: 35 KB de gráficos leídos "
          "como instrucciones desalinean todo lo que venga detrás. Las zonas que se "
          "saben de datos se declaran prohibidas, porque una sola semilla mala mete "
          "al trazador en los dibujos e infla la cobertura con basura.</p>"
          "<p>El resultado lo vigilan dos controles distintos. La "
          "<b>reproducibilidad</b>: cada listado reensambla al binario original, byte "
          "a byte. Y el <b>presupuesto</b>: cada byte tiene que ser o código trazado o "
          "un rango de datos con nombre en las notas. El segundo existe porque el "
          "primero no ve los errores de interpretación: si unos gráficos se marcan "
          "como código, los bytes siguen saliendo idénticos y el que miente es el "
          "listado.</p>",
}


def descomprime(d, origen):
    """El RLE del juego: word LE, 0xFFFF fin, bit 15 = repeticion."""
    out = bytearray()
    i = origen
    while True:
        bc = d[i] | (d[i + 1] << 8)
        i += 2
        if bc == 0xFFFF:
            return bytes(out)
        if bc & 0x8000:
            out += bytes([d[i]]) * (bc & 0x7FFF)
            i += 1
        else:
            out += d[i:i + bc]
            i += bc


def recorta(d, col0, fila0, ncols, nfilas, escala=3):
    """Recorta un trozo de la pantalla de presentacion, ya montada."""
    v = bytearray(0x4000)
    for org, dest in GFX_B:
        v[dest:dest + 0x800] = descomprime(d, org)
    v[0x1800:0x1800 + 768] = d[MAPA_PRESENTACION:MAPA_PRESENTACION + 768]
    w, h = ncols * 8 * escala, nfilas * 8 * escala
    fondo = PALETA[1]
    img = [[fondo] * w for _ in range(h)]
    for fy in range(nfilas):
        t = (fila0 + fy) // 8
        for fx in range(ncols):
            tile = v[0x1800 + (fila0 + fy) * 32 + col0 + fx]
            for l in range(8):
                pat = v[t * 0x800 + tile * 8 + l]
                col = v[0x2000 + t * 0x800 + tile * 8 + l]
                c1 = fondo if (col >> 4) == 0 else PALETA[col >> 4]
                c0 = fondo if (col & 15) == 0 else PALETA[col & 15]
                for b in range(8):
                    rgb = c1 if pat & (0x80 >> b) else c0
                    for sy in range(escala):
                        for sx in range(escala):
                            img[(fy * 8 + l) * escala + sy][(fx * 8 + b) * escala + sx] = rgb
    return w, h, img


def b64(p):
    return base64.b64encode(open(p, "rb").read()).decode()


def img(p, alt):
    return f'<img src="data:image/png;base64,{b64(p)}" alt="{alt}" loading="lazy">'


def main(binpath, imgdir, out, idioma="en"):
    d = open(binpath, "rb").read()
    t = T[idioma]

    w, h, im = recorta(d, 6, 2, 20, 6, escala=3)      # el rotulo ALE HOP! con su marco
    png(f"{TMP}/_al_logo.png", w, h, im)

    subs = dict(
        mensaje=f'<figure style="margin:1.25rem 0">'
                f'{img(os.path.join(imgdir, "mensaje-final.png"), "Ending message")}'
                f'</figure>',
        efecto=f'<figure style="margin:1.25rem 0">'
               f'{img(os.path.join(imgdir, "efecto-muerto.png"), "Unused colour effect")}'
               f'</figure>',
    )

    hallazgos = "".join(
        f'<div class="hall"><h3>{tit}</h3>{cuerpo.format(**subs)}</div>'
        for tit, cuerpo in HALLAZGOS[idioma])

    galeria = ""
    for n in range(6):
        tira = os.path.join(imgdir, "niveles", f"tira_nivel{n+1}.png")
        pant = os.path.join(imgdir, "niveles", f"pantalla_nivel{n+1}.png")
        galeria += (
            f'<div class="nivel"><h3>{t["nivel"]} {n+1}<span class="sep">·</span>'
            f'<em>{0x0000 + n*0x800:#06x}</em></h3>'
            f'<div class="rejilla" style="grid-template-columns:1fr">'
            f'<figure>{img(tira, f"{t["nivel"]} {n+1}")}'
            f'<figcaption><span>{t["tira"]}</span>'
            f'<span class="dir">256 x 8</span></figcaption></figure></div>'
            f'<div class="rejilla" style="margin-top:.9rem;max-width:540px">'
            f'<figure>{img(pant, f"{t["nivel"]} {n+1}")}'
            f'<figcaption><span>{t["pantalla"]}</span>'
            f'<span class="dir">32 x 24</span></figcaption></figure></div></div>')

    nav = "".join(f'<a href="{h_}">{x}</a>' for h_, x in t["nav"])
    docnav = "".join(f'<a href="{h_}">{x}</a>' for h_, x in t["docnav"])
    docnav += f'<a href="{REPO}">GitHub</a>'
    docnav += (f'<a href="{t["otro"][0]}" style="margin-left:auto;color:var(--oro)">'
               f'{t["otro"][1]}</a>')

    doc = f"""<title>{t["titulo"]}</title>
<style>{ESTILO}</style>
<div class="w">
<header class="top">
  {img(f"{TMP}/_al_logo.png", "Ale Hop! logo")}
  <p class="claim">{t["claim"]}</p>
  <div class="ficha">{"".join(f"<span>{x}</span>" for x in t["ficha"])}</div>
</header>
<nav>{nav}</nav>
<nav class="docs">{docnav}</nav>

<section id="numbers">
  <h2>{t["h_num"]}</h2>
  <div class="cifras">{"".join(f'<div class="cifra"><b>{a}</b><span>{b}</span></div>'
                                for a, b in t["cifras"])}</div>
  <p class="n" style="margin-top:1.5rem;color:var(--suave)">{t["nota_num"]}</p>
</section>

<section id="findings"><h2>{t["h_find"]}</h2>{hallazgos}</section>

<section id="screens">
  <h2>{t["h_scr"]}</h2>
  <p class="n" style="color:var(--suave)">{t["nota_scr"]}</p>
  {galeria}
</section>

<section id="method"><h2>{t["h_met"]}</h2>
  <div class="n">{METODO[idioma]}</div>
</section>

<footer>{t["pie_leg"]}</footer>
</div>
"""
    open(out, "w", encoding="utf-8").write(doc)
    print(f"  {out}: {len(doc)//1024} KB ({idioma})")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3],
         sys.argv[4] if len(sys.argv) > 4 else "en")
