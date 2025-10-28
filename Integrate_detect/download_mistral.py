"""Download Mistral 7B Instruct GGUF model from Hugging Face."""
import os
from huggingface_hub import hf_hub_download

# Model details
REPO_ID = "TheBloke/Mistral-7B-Instruct-v0.2-GGUF"
FILENAME = "mistral-7b-instruct-v0.2.Q4_K_M.gguf"  # Quantized 4-bit model (~4GB)
LOCAL_DIR = "models"

print(f"Downloading {FILENAME} from {REPO_ID}...")
print("This is a ~4GB file and may take several minutes depending on your connection.")

try:
    # Download the model
    model_path = hf_hub_download(
        repo_id=REPO_ID,
        filename=FILENAME,
        local_dir=LOCAL_DIR,
        local_dir_use_symlinks=False
    )
    
    print(f"\n✅ Successfully downloaded model to: {model_path}")
    print(f"\nModel size: {os.path.getsize(model_path) / (1024**3):.2f} GB")
    print("\nTo use this model, update your env.json or .env file:")
    print(f'  "LLM_MODEL_PATH": "{FILENAME}"')
    
except Exception as e:
    print(f"\n❌ Error downloading model: {e}")
    print("\nAlternative: You can manually download from:")
    print(f"  https://huggingface.co/{REPO_ID}/blob/main/{FILENAME}")
    print(f"  Save it to: {os.path.abspath(LOCAL_DIR)}/")
