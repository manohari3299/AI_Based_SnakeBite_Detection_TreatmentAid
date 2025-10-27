# PowerShell script to start the FastAPI server with custom LLM model path

$env:LLM_MODEL_PATH = "C:\Users\kiran\OneDrive\Desktop\AI_Based_SnakeBite_Detection_TreatmentAid-main\snake_classification\models\mistral-7b-instruct-v0.2.Q2_K.gguf"
$env:SKIP_MODEL_LOADING = "0"

Write-Host "Starting server with LLM_MODEL_PATH: $env:LLM_MODEL_PATH" -ForegroundColor Green
Write-Host "SKIP_MODEL_LOADING is set to: $env:SKIP_MODEL_LOADING" -ForegroundColor Yellow

uvicorn app:app --reload --port 8000

