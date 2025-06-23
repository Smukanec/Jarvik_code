from flask import Flask, request, jsonify
from rag_engine import load_knowledge, search_knowledge
import json
import os
import logging

app = Flask(__name__)
memory_path = "memory/public.jsonl"
debug_log = []

logging.basicConfig(
    filename="flask.log",
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)
logger = logging.getLogger(__name__)

# Načti znalosti při startu
knowledge_base = load_knowledge("knowledge")
print("✅ Znalosti načteny.")

def load_memory():
    if os.path.exists(memory_path):
        with open(memory_path, "r", encoding="utf-8") as f:
            return [json.loads(line) for line in f if line.strip()]
    return []

def append_to_memory(user_msg, ai_response):
    with open(memory_path, "a", encoding="utf-8") as f:
        f.write(json.dumps({"user": user_msg, "jarvik": ai_response}) + "\n")

@app.route("/ask", methods=["POST"])
def ask():
    data = request.get_json()
    message = data.get("message", "")
    logger.info("Incoming request: %s", message)
    debug_log.clear()

    memory_context = load_memory()
    debug_log.append(f"🧠 Paměť: {len(memory_context)} záznamů")

    rag_context = search_knowledge(message, knowledge_base)
    debug_log.append(f"📚 Kontext z RAG: {len(rag_context)} výsledků")
    logger.info(
        "Memory entries: %d, RAG results: %d",
        len(memory_context),
        len(rag_context),
    )

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
        logger.exception("Error communicating with Ollama")

    append_to_memory(message, output)
    logger.info("Response: %s", output)
    return jsonify({"response": output, "debug": debug_log})

@app.route("/")
def index():
    return app.send_static_file("index.html")

@app.route("/static/<path:path>")
def static_files(path):
    return app.send_static_file(path)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8010)

