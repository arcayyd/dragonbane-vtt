import fitz

doc = fitz.open("Dragonbane - Il Segreto dellImperatore Drago.pdf")
page = doc[13]

# Get bounding boxes of images on the page
images = page.get_images(full=True)
for img in images:
    xref = img[0]
    rects = page.get_image_rects(xref)
    if rects:
        print(f"Xref: {xref}, Rect on page: {rects[0]}")
