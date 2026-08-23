import fitz

def search_pdf(pdf_path, query, out_file):
    doc = fitz.open(pdf_path)
    out_file.write(f"=== SEARCHING FOR '{query}' IN {pdf_path} ===\n")
    for i, page in enumerate(doc):
        text = page.get_text()
        if query.lower() in text.lower():
            out_file.write(f"--- Page {i+1} ---\n")
            out_file.write(text)
            out_file.write("\n\n")

with open("scratch/statblock_results.txt", "w", encoding="utf-8") as f:
    search_pdf("Dragonbane - Il Segreto dellImperatore Drago.pdf", "goblin", f)
    search_pdf("Dragonbane - Il Segreto dellImperatore Drago.pdf", "warg", f)
    search_pdf("Dragonbane-Manuale-Base.pdf", "goblin", f)
    search_pdf("Dragonbane-Manuale-Base.pdf", "warg", f)

print("Saved search results to scratch/statblock_results.txt")
