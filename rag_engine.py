import os
import glob
from difflib import SequenceMatcher

def load_txt_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def load_pdf_file(path):
    try:
        import PyPDF2
    except ImportError:
        raise ImportError("PyPDF2 is required to load PDF files")

    text = ""
    with open(path, "rb") as f:
        reader = PyPDF2.PdfReader(f)
        for page in reader.pages:
            text += page.extract_text() or ""
    return text

def load_docx_file(path):
    try:
        import docx
    except ImportError:
        raise ImportError("python-docx is required to load DOCX files")

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

def search_knowledge(query, knowledge_chunks, threshold=0.6):
    """Return up to five knowledge chunks relevant to *query*.

    A chunk is included when it contains the query substring or when the
    similarity ratio computed via :class:`difflib.SequenceMatcher` exceeds the
    given *threshold*.
    """

    query_lower = query.lower()
    matches = []

    for chunk in knowledge_chunks:
        chunk_lower = chunk.lower()
        ratio = SequenceMatcher(None, query_lower, chunk_lower).ratio()

        if query_lower in chunk_lower or ratio >= threshold:
            matches.append((ratio, chunk[:500]))  # Shorten for the prompt

    matches.sort(key=lambda x: x[0], reverse=True)
    return [m[1] for m in matches[:5]]

