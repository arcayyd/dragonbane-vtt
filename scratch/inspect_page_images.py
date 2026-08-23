import fitz

pdf_path = "Dragonbane - Il Segreto dellImperatore Drago.pdf"
doc = fitz.open(pdf_path)
page = doc[13] # Page 14

image_list = page.get_images(full=True)
print(f"Number of images on page 14: {len(image_list)}")

for img_idx, img in enumerate(image_list):
    xref = img[0]
    base_image = doc.extract_image(xref)
    image_bytes = base_image["image"]
    image_ext = base_image["ext"]
    print(f"Image {img_idx}: xref={xref}, ext={image_ext}, size={len(image_bytes)} bytes, width={base_image['width']}, height={base_image['height']}")
