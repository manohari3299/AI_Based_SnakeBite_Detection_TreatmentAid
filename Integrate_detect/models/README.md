# Model Files

This directory should contain the following ML model files:

## Required Models

1. **model.pkl** (~173 MB)
   - FastAI learner for snake species classification
   - 135 snake species supported
   
2. **snake_bite_best_densenet.pth** (~27 MB)
   - DenseNet-121 model for bite detection
   - PyTorch format

## Optional LLM Model (Recommended)

3. **mistral-7b-instruct-v0.2.Q4_K_M.gguf** (~4 GB)
   - Mistral 7B Instruct model for chat assistant
   - Provides medical protocol suggestions after snake classification
   - 4-bit quantized GGUF format for efficient CPU inference
   
### Download Mistral 7B

**Option 1: Automatic Download (Recommended)**
```bash
cd Integrate_detect
python -c "from huggingface_hub import hf_hub_download; hf_hub_download(repo_id='TheBloke/Mistral-7B-Instruct-v0.2-GGUF', filename='mistral-7b-instruct-v0.2.Q4_K_M.gguf', local_dir='models')"
```

**Option 2: Manual Download**
1. Visit: https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF
2. Download: `mistral-7b-instruct-v0.2.Q4_K_M.gguf` (4.37 GB)
3. Place in: `Integrate_detect/models/`

**Note:** The download is ~4GB and may take 5-15 minutes depending on your internet speed.

## Note

These files are excluded from git due to their large size.
Download or train these models separately and place them in this directory.

## Environment Configuration

Update your `env.json` or `.env` file to point to these models:
```json
{
  "SNAKE_MODEL_PATH": "models/model.pkl",
  "BITE_MODEL_PATH": "models/snake_bite_best_densenet.pth",
  "LLM_MODEL_PATH": "models/mistral-7b-instruct-v0.2.Q4_K_M.gguf"
}
```

If you don't want to use the LLM, simply omit `LLM_MODEL_PATH` - the server will work without it, but chat responses will be basic fallbacks.

## Training Instructions

See the main README.md or documentation for model training instructions.
