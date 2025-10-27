# Snake Detect - FastAPI Backend

This project provides image-based snake species and bite classification plus a treatment assistant.

What's included
- `app.py` - FastAPI server exposing endpoints for species/bite prediction and a chat endpoint.
- `src/model_loader.py` - Loads models and metadata. Paths can be overridden via environment variables.
- `src/chat_utils.py` - Chat helpers (stateless, list-based).

Quick start (Windows PowerShell)

1. Create and activate a virtual environment

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

2. Install dependencies

Note: `torch` / `torchvision` and `fastai` are large and may require platform-specific wheels. For Windows, follow the official PyTorch install instructions: https://pytorch.org/get-started/locally/

To install packages listed in `requirements.txt` (may fail for torch; see note):

```powershell
pip install -r .\requirements.txt
```

If `pip install -r requirements.txt` fails for `torch`, install from the PyTorch website (select your CUDA/CPU preference) then re-run the requirements install without torch/torchvision.

3. Set environment variables if your model/data files are in non-default locations (optional)

```powershell
$env:SNAKE_MODEL_PATH = 'C:\path\to\model.pkl'
$env:BITE_MODEL_PATH = 'C:\path\to\snake_bite_best_densenet.pth'
$env:SPECIES_CSV = 'C:\path\to\species.csv'
$env:TREATMENT_XLSX = 'C:\path\to\snakebite_treatment_aid_100species.csv.xlsx'
$env:LLM_MODEL_PATH = 'C:\path\to\llm.gguf'  # optional
```

4. Run the API

```powershell
uvicorn app:app --reload --port 8000
```

Endpoints
- GET /health
- POST /predict_species (multipart/form-data; field `file`) -> JSON with `pred_class`, `confidence`, `metadata`
- POST /predict_bite (multipart/form-data; field `file`) -> JSON with `label`, `confidence`
- POST /chat -> JSON { user_input, species_name (optional), chat_history (optional list) } returns assistant reply and updated chat history

Security
 - If the environment variable `API_KEY` is set, the API requires callers to send the API key in the `X-API-KEY` HTTP header for protected endpoints (`/predict_species`, `/predict_bite`, `/chat`). The `/health` endpoint remains public.

Docker Compose
 - A `docker-compose.yml` is provided. Prepare a `models/` directory with the required model files (or update paths via environment variables) and start with:

```powershell
docker-compose up --build
```

Environment file
 - Copy `.env.example` to `.env` and edit values before running or mounting into containers.

Example PowerShell curl (test image upload)

```powershell
# Replace with an actual image path
$img = 'C:\path\to\snake.jpg'

# Predict species
curl -X POST "http://127.0.0.1:8000/predict_species" -F "file=@$img" -H "accept: application/json"

# Predict bite
curl -X POST "http://127.0.0.1:8000/predict_bite" -F "file=@$img" -H "accept: application/json"
```

Notes and next steps
- The LLM is optional; if `llama-cpp-python` is not installed or the model path is missing, chat fallback behavior uses local metadata and simple intent checks.
- For production: add proper CORS origins, authentication, rate-limiting, and run with multiple workers (e.g., behind gunicorn/uvicorn workers).
- Consider moving heavy models (LLM) to separate worker processes or using async task queue for responsiveness.

If you'd like, I can:
- Add example client code (JS/Python) that talks to the API
- Add Dockerfile and docker-compose for easier deployment
- Add tests for endpoints
