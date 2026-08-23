import fitz  # PyMuPDF

pdf_path = "Dragonbane - Il Segreto dellImperatore Drago.pdf"
doc = fitz.open(pdf_path)

found_page = -1
for i, page in enumerate(doc):
    text = page.get_text()
    if "MASTRO METEOROLOGO" in text:
        found_page = i
        print(f"Found on page index: {i} (Page {i+1})")
        rect = page.rect
        print(f"Page dimensions: {rect.width}x{rect.height}")
        break

if found_page == -1:
    print("Text not found in PDF!")
