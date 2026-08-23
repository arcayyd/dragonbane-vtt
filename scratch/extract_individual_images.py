import fitz

doc = fitz.open("Dragonbane - Il Segreto dellImperatore Drago.pdf")

for xref in [5457, 6279, 6288]:
    base_image = doc.extract_image(xref)
    image_bytes = base_image["image"]
    ext = base_image["ext"]
    
    out_name = f"scratch/img_{xref}.{ext}"
    with open(out_name, "wb") as f:
        f.write(image_bytes)
    print(f"Saved {out_name}")
