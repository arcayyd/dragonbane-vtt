import fitz

doc = fitz.open("Dragonbane - Il Segreto dellImperatore Drago.pdf")
with open("scratch/page_14_15.txt", "w", encoding="utf-8") as f:
    for i in [13, 14, 15]: # pages 14, 15, 16
        f.write(f"=== PAGE {i+1} ===\n")
        f.write(doc[i].get_text())
        f.write("\n\n")
print("Saved pages 14-16 to scratch/page_14_15.txt")
