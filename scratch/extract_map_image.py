import fitz  # PyMuPDF

pdf_path = "Dragonbane - Il Segreto dellImperatore Drago.pdf"
doc = fitz.open(pdf_path)
page = doc[13]  # Page 14 (0-indexed index 13)

# Render full page at high resolution (zoom 4x)
zoom = 4
mat = fitz.Matrix(zoom, zoom)

# Crop coordinates in PDF points (612.28 x 790.87)
# Let's crop from y=330 to y=770 to get the map without top text columns, and avoid the page footer
rect = fitz.Rect(0, 320, 612.28, 772)
page.set_cropbox(rect)

pix = page.get_pixmap(matrix=mat)
pix.save("assets/images/sentiero_tattico.png")
print("Saved cropped map image to assets/images/sentiero_tattico.png")
print(f"Image dimensions: {pix.width}x{pix.height}")
