import fitz

doc = fitz.open("Dragonbane - Il Segreto dellImperatore Drago.pdf")

for xref in [488, 489, 490, 128, 129, 5802, 5806, 5810]:
    try:
        base_image = doc.extract_image(xref)
        image_bytes = base_image["image"]
        ext = base_image["ext"]
        out_name = f"scratch/img_{xref}.{ext}"
        with open(out_name, "wb") as f:
            f.write(image_bytes)
        print(f"Saved {out_name}")
    except Exception as e:
        print(f"Error extracting {xref}: {e}")
