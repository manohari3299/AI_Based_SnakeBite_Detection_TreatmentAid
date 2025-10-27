import os, json, sys
# Ensure project root is on sys.path so local imports work when running this script
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from src.model_loader import load_models
import app

# Ensure models are loaded (uses defaults from model_loader if env vars not set)
print('Loading models... this can take a while')
SNAKE_MODEL, BITE_MODEL, SPECIES_DF, TREATMENT_DF, LLM = load_models()
# Inject into app module globals so handlers use them
app.SNAKE_MODEL = SNAKE_MODEL
app.BITE_MODEL = BITE_MODEL
app.SPECIES_DF = SPECIES_DF
app.TREATMENT_DF = TREATMENT_DF
app.LLM = LLM

# Build a chat request (species can be overridden via SPECIES_NAME env var)
species = os.getenv('SPECIES_NAME', 'Naja naja')
req = app.ChatRequest(user_input='Hello assistant, what should I do if bitten?', species_name=species, chat_history=[])

print('Calling chat handler...')
resp = app.api_chat(req, True)
print('\nResponse:\n')
print(json.dumps(resp, indent=2, ensure_ascii=False))
