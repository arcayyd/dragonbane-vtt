import fitz
from PIL import Image

pdf_path = "Dragonbane - Il Segreto dellImperatore Drago.pdf"
doc = fitz.open(pdf_path)
page = doc[13] # Page 14

# 1. Render the full page at 4x resolution
zoom = 4
mat = fitz.Matrix(zoom, zoom)
pix = page.get_pixmap(matrix=mat)
img_page = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)

# 2. Extract the parchment background image (xref 5457) and resize to page rendering size
base_image = doc.extract_image(5457)
img_parchment = Image.open(fitz.io.BytesIO(base_image["image"]))
img_parchment = img_parchment.resize((pix.width, pix.height), Image.Resampling.LANCZOS)

# 3. Define text areas to cover (in PDF points, will scale by 4)
cover_rects = [
    (50, 60, 600, 265),     # Narrative top section
    (50, 265, 305, 360),    # Top part of left column (covering "distribuiti...")
    (250, 265, 600, 335),   # Right text column (Il Cavalcawarg)
    (50, 360, 250, 565),    # Bottom part of left column (stops at x=250 to avoid Point 3)
    (50, 755, 300, 775),    # Watermark bottom left
]

# Apply patches: copy rect from clean parchment and paste onto the page rendering
for r in cover_rects:
    x0, y0, x1, y1 = [int(val * zoom) for val in r]
    # Crop clean parchment patch
    patch = img_parchment.crop((x0, y0, x1, y1))
    # Paste over the text on the page
    img_page.paste(patch, (x0, y0))

# 4. Crop to get only the map area
crop_y0 = int(300 * zoom)
crop_y1 = int(780 * zoom)
img_map = img_page.crop((0, crop_y0, pix.width, crop_y1))

# 5. Save the final clean map
img_map.save("assets/images/sentiero_tattico.png")
print("Successfully generated clean map assets/images/sentiero_tattico.png")
print(f"Dimensions: {img_map.width}x{img_map.height}")
