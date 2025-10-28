import torch
from torchvision import models, transforms
import os
import warnings
from typing import Optional
import torch
from torchvision import models, transforms
from fastai.vision.all import load_learner, PILImage
try:
    from llama_cpp import Llama
except Exception:
    Llama = None
import pandas as pd
import pathlib
from pathlib import Path

# Fix PosixPath issue on Windows for fastai
pathlib.PosixPath = pathlib.WindowsPath


def _resolve_path(env_var: str, default: str, required: bool = True) -> Optional[Path]:
    """Resolve a path from an environment variable with a fallback.
    
    Handles both absolute and relative paths. For relative paths, resolves them
    relative to the project root directory (one level up from this file).
    
    Returns a pathlib.Path if the file exists. If required is False and the
    file is missing, returns None. Raises FileNotFoundError if required and
    missing.
    """
    # Get the project root directory (one level up from this file)
    project_root = Path(__file__).parent.parent.absolute()
    
    # Get path from environment or use default
    path_str = os.getenv(env_var, default)
    p = Path(path_str)
    
    # If path is relative, make it relative to project root
    if not p.is_absolute():
        p = project_root / p
    
    # Normalize the path
    p = p.resolve()
    
    if p.exists():
        return p
    if required:
        raise FileNotFoundError(
            f"Required file for {env_var} not found at {p}\n"
            f"Looked for file relative to {project_root}"
        )
    warnings.warn(f"Optional file for {env_var} not found at {p}; continuing with None")
    return None


def load_models(
    snake_model_path_env: str = "SNAKE_MODEL_PATH",
    bite_model_path_env: str = "BITE_MODEL_PATH",
    species_csv_env: str = "SPECIES_CSV",
    treatment_xlsx_env: str = "TREATMENT_XLSX",
    llm_model_env: str = "LLM_MODEL_PATH",
) -> tuple:
    """Load models and data files used by the API.
    
    Default paths (if not set in environment):
    - Snake classification model: models/snake_bite_best_densenet.pth
    - Bite detection model: models/model.pkl
    - Species data: archive/species.csv
    - Treatment data: archive/snakebite_treatment_aid_100species.csv.xlsx
    - LLM model: optional, set via LLM_MODEL_PATH
    
    All relative paths are resolved relative to the project root directory.
    """
    """Load models and data used by the API.

    Paths can be overridden with environment variables. The LLM is optional
    and will be set to None if its model file is missing or the llama_cpp
    package isn't installed.
    """
    import logging
    logger = logging.getLogger(__name__)
    logger.debug("Starting model loading...")
    # Default paths relative to project root
    default_snake = "models/model.pkl"
    default_bite = "models/snake_bite_best_densenet.pth"
    default_species = "archive/species.csv"
    default_treatment = "archive/snakebite_treatment_aid_100species.csv.xlsx"
    default_llm = "models/mistral-7b-instruct-v0.2.Q4_K_M.gguf"  # Optional - Mistral 7B Instruct (Q4 quantized, ~4GB)

    # ------------------- Snake Classifier (FastAI) -------------------
    snake_model_path = _resolve_path(snake_model_path_env, default_snake, required=True)
    snake_model = load_learner(snake_model_path)

    # ------------------- Bite Classifier (Densenet PyTorch) -------------------
    bite_model_path = _resolve_path(bite_model_path_env, default_bite, required=True)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    bite_model = models.densenet121(pretrained=False)
    num_features = bite_model.classifier.in_features
    bite_model.classifier = torch.nn.Linear(num_features, 2)  # NonVenomous / Venomous

    # Load checkpoint safely
    checkpoint = torch.load(str(bite_model_path), map_location=device)
    if isinstance(checkpoint, dict) and "model" in checkpoint:
        bite_model.load_state_dict(checkpoint["model"])
    else:
        bite_model.load_state_dict(checkpoint)
    bite_model.to(device)
    bite_model.eval()

    # ------------------- Species Metadata & Treatment -------------------
    species_csv = _resolve_path(species_csv_env, default_species, required=True)
    treatment_xlsx = _resolve_path(treatment_xlsx_env, default_treatment, required=True)

    species_df = pd.read_csv(species_csv)
    # read_excel may need openpyxl engine
    treatment_df = pd.read_excel(treatment_xlsx)

    # ------------------- LLaMA/Mistral LLM (optional) -------------------
    llm_model = _resolve_path(llm_model_env, default_llm, required=False)
    
    llm = None
    if llm_model and Llama is not None:
        # Try multiple LLM init configurations (n_ctx, n_threads) to improve
        # chance of success on machines with limited memory or CPU.
        logger.info(f"Attempting to load LLM from {llm_model}")
        cpu_count = max(1, os.cpu_count() or 1)
        attempts = [
            (4096, min(6, cpu_count)),
            (2048, min(4, cpu_count)),
            (1024, 1),
        ]
        last_exc = None
        for n_ctx, n_threads in attempts:
            try:
                logger.info(f"Trying LLM with n_ctx={n_ctx}, n_threads={n_threads}")
                llm = Llama(
                    model_path=str(llm_model),
                    n_ctx=n_ctx,
                    n_threads=n_threads,
                    n_batch=512,
                    verbose=True,  # Enable verbose to see loading details
                )
                # success
                logger.info(f"LLM loaded successfully with n_ctx={n_ctx}, n_threads={n_threads}")
                break
            except Exception as e:
                logger.warning(f"LLM init failed with n_ctx={n_ctx}, n_threads={n_threads}: {e}")
                last_exc = e
                llm = None
        if llm is None and last_exc is not None:
            logger.error(f"Failed to load LLM model after multiple attempts: {last_exc}; continuing with llm=None")
    else:
        if llm_model and Llama is None:
            logger.warning("llama_cpp package not available; LLM functionality disabled")
        elif not llm_model:
            logger.info("No LLM model path configured; LLM functionality disabled")

    return snake_model, bite_model, species_df, treatment_df, llm


# ------------------------------- Helper Functions -------------------------------


def predict_species(snake_model, uploaded_file):
    img = PILImage.create(uploaded_file)
    pred_class, pred_idx, probs = snake_model.predict(img)
    return int(pred_class), pred_idx, probs


def predict_bite(bite_model, uploaded_file):
    """Predict whether bite image indicates poisonous or non-poisonous bite."""
    from PIL import Image

    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])
    img = Image.open(uploaded_file).convert("RGB")
    input_tensor = transform(img).unsqueeze(0)
    device = next(bite_model.parameters()).device
    input_tensor = input_tensor.to(device)

    with torch.no_grad():
        output = bite_model(input_tensor)
        probs = torch.softmax(output, dim=1)
        class_idx = torch.argmax(probs, dim=1).item()
        confidence = probs[0, class_idx].item()

    label = "Venomous" if class_idx == 1 else "NonVenomous"
    return label, confidence
