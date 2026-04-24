import os
import fitz  # PyMuPDF
import requests
from io import BytesIO

PDF_URL = "https://archive.org/download/holy-quran-in-high-quality-colour-coded-tajweed-rules-15-lines/Holy%20Quran%20In%20High%20Quality%20Colour%20Coded%20Tajweed%20Rules%20%5B15-Lines%5D.pdf"
OUTPUT_DIR = os.path.join("assets", "images", "quran")

def download_and_extract():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    print(f"Downloading Tajweed Quran PDF from {PDF_URL}...")
    print("This may take a few minutes depending on your connection speed (approx 150MB).")
    
    response = requests.get(PDF_URL, stream=True)
    response.raise_for_status()

    # Read into memory
    pdf_bytes = BytesIO(response.content)
    print("Download complete. Opening PDF for extraction...")

    try:
        doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    except Exception as e:
        print(f"Failed to open PDF: {e}")
        return

    # The PDF usually has some cover pages. We need to find the first actual Quran page.
    # The standard 15-line Mushaf has 604 pages plus some intro/outro.
    # Often, page 1 (Fatiha) starts at a specific index. Let's extract all of them first,
    # or just name them sequentially. 
    # Usually, page 1 is PDF page 3 or 4. We will just dump them as is and the developer can adjust,
    # or we can extract exactly the last 604 pages, or from index 2.
    
    num_pages = len(doc)
    print(f"PDF contains {num_pages} pages.")
    
    # Let's extract all pages but give a generic name so we don't accidentally overwrite exact 1-604 if offsets are wrong.
    # Wait, TajwidCoach's MushafService expects page_001.png to page_604.png.
    # We will just write a best guess: The actual Quran pages (1-604) are usually offset by ~2.
    # Example: Fatiha is on page 3.
    # So we want PDF page 3 to be page_001.png.
    # Let's do a simple mapping.
    
    start_offset = 0 # e.g. PDF page 2 (0-indexed) is page 1 of mushaf
    
    print("Processing pages...")
    extracted_count = 0
    for i in range(start_offset, num_pages):
        quran_page_num = i - start_offset + 1
        page = doc.load_page(i)
        
        # Render page to an image
        # zoom=2 for higher resolution
        mat = fitz.Matrix(2, 2)
        pix = page.get_pixmap(matrix=mat)
        
        filename = f"page_{quran_page_num:03d}.png"
        filepath = os.path.join(OUTPUT_DIR, filename)
        pix.save(filepath)
        extracted_count += 1
        if extracted_count % 50 == 0:
            print(f"Extracted {extracted_count} pages...")
            
    print(f"Successfully extracted {extracted_count} pages into {OUTPUT_DIR}.")

if __name__ == "__main__":
    download_and_extract()
