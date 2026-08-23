import fitz

doc = fitz.open("Dragonbane - Il Segreto dellImperatore Drago.pdf")
page = doc[13]

blocks = page.get_text("blocks")
for b in blocks:
    rect = fitz.Rect(b[:4])
    text = b[4].strip()
    print(f"Block: rect={rect}, text_preview={text[:50]!r}")
