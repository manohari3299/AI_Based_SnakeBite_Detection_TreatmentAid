@echo off
REM Batch script to start the FastAPI server with custom LLM model path

set LLM_MODEL_PATH=C:\Users\kiran\OneDrive\Desktop\AI_Based_SnakeBite_Detection_TreatmentAid-main\snake_classification\models\mistral-7b-instruct-v0.2.Q2_K.gguf
set SKIP_MODEL_LOADING=0

echo Starting server with LLM_MODEL_PATH: %LLM_MODEL_PATH%
echo SKIP_MODEL_LOADING is set to: %SKIP_MODEL_LOADING%

uvicorn app:app --reload --port 8000

