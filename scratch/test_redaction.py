import fitz

doc = fitz.open("Dragonbane - Il Segreto dellImperatore Drago.pdf")
page = doc[13] # Page 14

# Let's search for text and redact it, excluding the map numbers and banner
# We want to redact:
# 1. "UNA FRECCIA NERA SU MASTRO METEOROLOGO" block (y=74 to 260)
# 2. "L'IMBOSCATA" and the left narrative block (y=278 to 560, x < 300)
# 3. "Il Cavalcawarg" block (y=269 to 331, x > 300)
# 4. Watermark "Giuseppe Celeste - 555154" at the bottom (y > 750, x < 200)

redact_rects = [
    fitz.Rect(50, 70, 600, 265),     # Mastro Meteorologo text block
    fitz.Rect(50, 265, 300, 570),    # L'Imboscata and left column text
    fitz.Rect(300, 265, 600, 335),   # Il Cavalcawarg text block
    fitz.Rect(50, 750, 200, 780),    # Watermark
]

for rect in redact_rects:
    page.add_redact_annot(rect, fill=None)  # fill=None preserves the background

page.apply_redactions()

# Now set cropbox to the map area
rect_crop = fitz.Rect(0, 320, 612.28, 772)
page.set_cropbox(rect_crop)

# Render at 4x resolution
mat = fitz.Matrix(4, 4)
pix = page.get_pixmap(matrix=mat)
pix.save("assets/images/sentiero_tattico.png")
print("Saved clean redacted map image to assets/images/sentiero_tattico.png")
