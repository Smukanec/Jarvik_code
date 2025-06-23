import os
import PyPDF2
import docx
import glob

def load_txt_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def load_pdf_file(path):
    text = ""
    with open(path, "rb") as f:
        reader = PyPDF2.PdfReader(f)
        for page in reader.pages:
            text += page.extract_text() or ""
    return text

def load_docx_file(path):
    doc = docx.Document(path)
    return "\n".join([p.text for p in doc.paragraphs])

def load_knowledge(folder):
    chunks = []
    for ext in ("*.txt", "*.pdf", "*.docx"):
        for path in glob.glob(os.path.join(folder, ext)):
            try:
                if ext == "*.txt":
                    content = load_txt_file(path)
                elif ext == "*.pdf":
                    content = load_pdf_file(path)
                elif ext == "*.docx":
                    content = load_docx_file(path)
                else:
                    continue
                chunks.append(content.strip())
            except Exception as e:
                print(f"❌ Nelze načíst {path}: {e}")
    return chunks

def search_knowledge(query, knowledge_chunks):
    results = []
    for chunk in knowledge_chunks:
        if query.lower() in chunk.lower():
            results.append(chunk[:500])  # Zkrať pro prompt
        if len(results) >= 5:
            break
    return results

