from flask import Flask, request, jsonify
from rag_engine import load_knowledge, search_knowledge
import json
import os

# Set base directory relative to this file
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
memory_path = os.path.join(BASE_DIR, "memory", "public.jsonl")
# Ensure memory directory and file exist
os.makedirs(os.path.dirname(memory_path), exist_ok=True)
open(memory_path, "a", encoding="utf-8").close()

app = Flask(__name__)

# Načti znalosti při startu
knowledge_base = load_knowledge(os.path.join(BASE_DIR, "knowledge"))
print("✅ Znalosti načteny.")

def load_memory():
    if os.path.exists(memory_path):
        with open(memory_path, "r", encoding="utf-8") as f:
            return [json.loads(line) for line in f if line.strip()]
    return []

def append_to_memory(user_msg, ai_response):
    with open(memory_path, "a", encoding="utf-8") as f:
        f.write(json.dumps({"user": user_msg, "jarvik": ai_response}) + "\n")

def search_memory(query, memory_entries):
    results = []
    q = query.lower()
    for entry in reversed(memory_entries):
        if q in entry.get("user", "").lower() or q in entry.get("jarvik", "").lower():
            results.append(entry)
        if len(results) >= 5:
            break
    return results

@app.route("/ask", methods=["POST"])
def ask():
    debug_log = []
    data = request.get_json(silent=True)
    message = (data or {}).get("message", "")

    memory_context = load_memory()
    debug_log.append(f"🧠 Paměť: {len(memory_context)} záznamů")

    rag_context = search_knowledge(message, knowledge_base)
    debug_log.append(f"📚 Kontext z RAG: {len(rag_context)} výsledků")

    # Vytvoření promptu pro model
    prompt = f"Uživatel: {message}\n"
    if rag_context:
        prompt += "\n".join([f"Znalost: {chunk}" for chunk in rag_context])
    if memory_context:
        prompt += "\n" + "\n".join([f"Minulý dotaz: {m['user']} -> {m['jarvik']}" for m in memory_context[-5:]])

    try:
        import requests
        response = requests.post("http://localhost:11434/api/generate", json={
            "model": "mistral",
            "prompt": prompt,
            "stream": False
        })
        result = response.json()
        output = result.get("response", "").strip()
    except Exception as e:
        output = "❌ Chyba při komunikaci s Ollamou"
        debug_log.append(str(e))

    append_to_memory(message, output)
    return jsonify({"response": output, "debug": debug_log})

@app.route("/memory/add", methods=["POST"])
def memory_add():
    data = request.get_json(silent=True) or {}
    user_msg = data.get("user")
    jarvik_msg = data.get("jarvik")
    if not user_msg or not jarvik_msg:
        return jsonify({"error": "user and jarvik required"}), 400
    append_to_memory(user_msg, jarvik_msg)
    return jsonify({"status": "ok"})

@app.route("/memory/search")
def memory_search():
    query = request.args.get("q", "")
    memory_entries = load_memory()
    if not query:
        return jsonify(memory_entries[-5:])
    return jsonify(search_memory(query, memory_entries))

@app.route("/knowledge/search")
def knowledge_search():
    query = request.args.get("q", "")
    if not query:
        return jsonify([])
    return jsonify(search_knowledge(query, knowledge_base))

@app.route("/")
def index():
    return app.send_static_file("index.html")

@app.route("/static/<path:path>")
def static_files(path):
    return app.send_static_file(path)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8010)

