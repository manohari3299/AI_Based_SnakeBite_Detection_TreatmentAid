@echo off
cd /d "%~dp0"
echo Starting SnakeBite AI Backend Server...
echo.
echo Loading AI models (this may take a minute)...
echo.
echo Server will be available at:
echo   - Local:   http://localhost:8000
echo   - Network: http://10.123.198.19:8000
echo.

set SKIP_MODEL_LOADING=0
set API_KEY=changeme
set ALLOWED_ORIGINS=*

python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload
