from PIL import Image

src_path = r"C:\Users\eleon\.gemini\antigravity\brain\4f2c939c-05eb-427c-b76c-7ac5fdc5a81e\sentiero_tattico_generato_1783181435107.jpg"
dst_path = r"C:\Users\eleon\Documents\antigravity\calm-babbage\assets\images\sentiero_tattico.png"

# Convert JPG to PNG
img = Image.open(src_path)
img.save(dst_path, "PNG")
print("Converted and saved new battle map as PNG to assets/images/sentiero_tattico.png")
print(f"Dimensions: {img.width}x{img.height}")
