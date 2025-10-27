"""Simple example client for the Snake Detect API.

Usage:
    python scripts/client_example.py predict_species C:\path\to\image.jpg
    python scripts/client_example.py predict_bite C:\path\to\image.jpg
    python scripts/client_example.py chat "Is this venomous?" --species "Naja naja"

This script shows how to call the API endpoints.
"""
import sys
import requests
from pathlib import Path

import os
import json

API = os.getenv("SNAKE_API_URL", "http://127.0.0.1:8000")
API_KEY = os.getenv("API_KEY", None)
CHAT_HISTORY_FILE = Path(".chat_history.json")


def _headers(api_key=None):
    headers = {}
    key = api_key or API_KEY
    if key:
        headers["X-API-KEY"] = key
    return headers


def predict_species(image_path):
    with open(image_path, "rb") as f:
        files = {"file": (Path(image_path).name, f, "image/jpeg")}
        r = requests.post(f"{API}/predict_species", files=files, headers=_headers())
    print(r.status_code, r.text)


def predict_bite(image_path):
    with open(image_path, "rb") as f:
        files = {"file": (Path(image_path).name, f, "image/jpeg")}
        r = requests.post(f"{API}/predict_bite", files=files, headers=_headers())
    print(r.status_code, r.text)


def load_history(species_key="global"):
    if CHAT_HISTORY_FILE.exists():
        data = json.loads(CHAT_HISTORY_FILE.read_text())
        return data.get(species_key, [])
    return []


def save_history(history, species_key="global"):
    data = {}
    if CHAT_HISTORY_FILE.exists():
        data = json.loads(CHAT_HISTORY_FILE.read_text())
    data[species_key] = history
    CHAT_HISTORY_FILE.write_text(json.dumps(data, indent=2))


def chat(user_input, species_name=None, api_key=None):
    species_key = species_name or "global"
    history = load_history(species_key)
    payload = {"user_input": user_input, "species_name": species_name, "chat_history": history}
    r = requests.post(f"{API}/chat", json=payload, headers=_headers(api_key))
    print(r.status_code, r.text)
    if r.status_code == 200:
        j = r.json()
        save_history(j.get("chat_history", []), species_key)


def main():
    if len(sys.argv) < 3:
        print("Usage: client_example.py [predict_species|predict_bite|chat] args...")
        return
    cmd = sys.argv[1]
    if cmd == "predict_species":
        predict_species(sys.argv[2])
    elif cmd == "predict_bite":
        predict_bite(sys.argv[2])
    elif cmd == "chat":
        user_input = sys.argv[2]
        species = None
        if "--species" in sys.argv:
            idx = sys.argv.index("--species")
            if idx + 1 < len(sys.argv):
                species = sys.argv[idx + 1]
        chat(user_input, species)
    else:
        print("Unknown command")


if __name__ == "__main__":
    main()
