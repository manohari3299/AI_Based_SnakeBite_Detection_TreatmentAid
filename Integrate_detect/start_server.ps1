# PowerShell script to start the FastAPI server with custom LLM model path

$env:LLM_MODEL_PATH = "C:\Users\aryan\Desktop\snakebite_ai_assistant\Integrate_detect\models\mistral-7b-instruct-v0.2.Q4_K_M.gguf"
$env:SKIP_MODEL_LOADING = "0"

Write-Host "Starting server with LLM_MODEL_PATH: $env:LLM_MODEL_PATH" -ForegroundColor Green
Write-Host "SKIP_MODEL_LOADING is set to: $env:SKIP_MODEL_LOADING" -ForegroundColor Yellow
Write-Host "Server will be accessible on mobile hotspot at: http://192.168.137.1:8000" -ForegroundColor Cyan

# Bind to 0.0.0.0 to make server accessible from mobile hotspot
uvicorn app:app --reload --port 8000 --host 0.0.0.0

