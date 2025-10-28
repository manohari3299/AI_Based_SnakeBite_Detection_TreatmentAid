"""FastAPI backend for snake species/bite classification and treatment assistant.

This file replaces the previous Streamlit-based `app.py`. It exposes API
endpoints for species prediction, bite prediction, and chat-based queries.

Run with:
    uvicorn app:app --reload --port 8000

Note: This is a minimal conversion. For production use add CORS, auth,
rate-limiting and proper model resource constraints.
"""

from fastapi import FastAPI, UploadFile, File, HTTPException, Header, Depends, Form
import json
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
from io import BytesIO
import uuid
import time

import pandas as pd
import os
import logging

from src.model_loader import load_models, predict_species, predict_bite
from src.treatment_utils import get_treatment
from src.chat_utils import append_chat, format_chat

# Chat history storage: conversation_id -> list of messages
chat_histories: Dict[str, List[List[str]]] = {}

# Store user's last identified snake species: user_id -> species name
user_species_context: Dict[str, str] = {}

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = FastAPI(title="Snake Detect API")

# Allow CORS (configurable via ALLOWED_ORIGINS env var)
allowed = os.getenv("ALLOWED_ORIGINS", "*")
if allowed.strip() == "*":
    origins = ["*"]
else:
    origins = [o.strip() for o in allowed.split(",") if o.strip()]
    
logger.debug("Setting up CORS with origins: %s", origins)

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def verify_api_key(x_api_key: Optional[str] = Header(None)):
    """If API_KEY env var is set, require callers to pass it in X-API-KEY header.

    If API_KEY is not set, this dependency allows access without a key.
    """
    api_key = os.getenv("API_KEY")
    if api_key:
        if x_api_key != api_key:
            raise HTTPException(status_code=401, detail="Invalid or missing API key")
    return True


class ChatRequest(BaseModel):
    message: str
    user_id: Optional[str] = "anonymous"
    conversation_id: Optional[str] = None
    species_name: Optional[str] = None
    region: Optional[str] = None
    symptoms: Optional[str] = None


class ChatResponse(BaseModel):
    response: str  # Just the assistant's response, nothing else


# Initialize global variables
SNAKE_MODEL = None
BITE_MODEL = None
SPECIES_DF = None
TREATMENT_DF = None
LLM = None

@app.on_event("startup")
async def startup_event():
    """Load models once when the FastAPI server starts."""
    global SNAKE_MODEL, BITE_MODEL, SPECIES_DF, TREATMENT_DF, LLM
    skip = os.getenv("SKIP_MODEL_LOADING", "0") == "1"
    
    if skip:
        logger.info("SKIP_MODEL_LOADING=1 set; skipping heavy model loading on startup")
        return
        
    try:
        logger.info("Loading models and data...")
        SNAKE_MODEL, BITE_MODEL, SPECIES_DF, TREATMENT_DF, LLM = load_models()
        logger.info("Successfully loaded all models and data")
        
        # Verify data loaded correctly
        if SPECIES_DF is not None:
            logger.info(f"Loaded species data with {len(SPECIES_DF)} entries")
        if TREATMENT_DF is not None:
            logger.info(f"Loaded treatment data with {len(TREATMENT_DF)} entries")
            
    except Exception as e:
        logger.error(f"Error loading models: {str(e)}", exc_info=True)
        # Don't raise the exception - let the app start even if models fail to load
        pass


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/llm_status")
def llm_status():
    """Debug endpoint to check LLM status"""
    return {
        "llm_loaded": LLM is not None,
        "llm_type": str(type(LLM)) if LLM else None,
        "test_prompt": "Testing..." if LLM is None else "LLM available"
    }


@app.get("/test_llm")
def test_llm():
    """Simple test endpoint to verify LLM can generate text"""
    try:
        if LLM is None:
            return {"error": "LLM not loaded"}
        
        prompt = "What is a snake bite?"
        result = LLM(prompt, max_tokens=50)
        return {
            "success": True,
            "prompt": prompt,
            "response": result["choices"][0]["text"]
        }
    except Exception as e:
        logger.error(f"LLM test error: {str(e)}", exc_info=True)
        return {"error": str(e), "type": str(type(e))}


@app.post("/predict_species")
async def api_predict_species(
    file: UploadFile = File(...),
    user_id: Optional[str] = Header(None),
    _=Depends(verify_api_key)
):
    """Predict species from an uploaded image file.
    Returns binomial name, confidence and metadata.
    Stores species context for subsequent chat queries.
    """
    contents = await file.read()
    buf = BytesIO(contents)
    if SNAKE_MODEL is None:
        raise HTTPException(
            status_code=503,
            detail="Species model not loaded. Set SKIP_MODEL_LOADING=0 and ensure model paths are correct."
        )
    try:
        pred_class, pred_idx, probs = predict_species(SNAKE_MODEL, buf)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    if SPECIES_DF is None:
        logger.error("Species data not loaded")
        raise HTTPException(status_code=503, detail="Species data not available")
        
    species_row = SPECIES_DF[SPECIES_DF["class_id"] == int(pred_class)]
    result = {
        "pred_class": int(pred_class),
        "confidence": float(probs[pred_idx]) if hasattr(probs, "__getitem__") else None,
        "metadata": None,
    }
    
    if not species_row.empty:
        row = species_row.iloc[0].to_dict()
        binomial_name = row.get('binomial_name')
        
        # Convert poisonous to venomous for compatibility
        metadata = {k: (v if not pd.isna(v) else None) for k, v in row.items()}
        if 'poisonous' in metadata:
            metadata['venomous'] = metadata['poisonous']  # Add venomous field for Flutter app
        if 'snake_sub_family' in metadata:
            metadata['subfamily'] = metadata['snake_sub_family']  # Add subfamily alias for Flutter app
        
        result["metadata"] = metadata
        
        # Store and log species context
        if user_id and binomial_name:
            user_species_context[user_id] = binomial_name
            logger.info(f"Stored species context for user {user_id}: {binomial_name}")
            
            # Add treatment info to response if available
            if TREATMENT_DF is not None:
                treatment = TREATMENT_DF[TREATMENT_DF["scientific_name"] == binomial_name]
                if not treatment.empty:
                    result["treatment_info"] = treatment.iloc[0].to_dict()
                    logger.info(f"Found treatment data for species {binomial_name}")
                else:
                    logger.info(f"No treatment data found for species {binomial_name}")
    else:
        logger.warning(f"No species data found for class_id {pred_class}")
        
    return JSONResponse(result)


@app.post("/predict_bite")
async def api_predict_bite(file: UploadFile = File(...), _=Depends(verify_api_key)):
    contents = await file.read()
    buf = BytesIO(contents)
    if BITE_MODEL is None:
        raise HTTPException(status_code=503, detail="Bite model not loaded. Set SKIP_MODEL_LOADING=0 and ensure model paths are correct.")
    try:
        label, confidence = predict_bite(BITE_MODEL, buf)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    return {"label": label, "confidence": float(confidence)}


def _generate_fallback_response(message: str, species_info: dict = None, treatment_info: dict = None) -> str:
    """Generate intelligent fallback response when LLM is not available."""
    message_lower = message.lower()
    
    # If we have species and treatment info, provide specific information
    if species_info and treatment_info:
        if any(word in message_lower for word in ['treatment', 'what should', 'what do', 'help', 'first aid']):
            response = f"For {species_info['name']} bite:\n\n"
            if not pd.isna(treatment_info['first_aid']):
                response += f"**Immediate First Aid:**\n{treatment_info['first_aid']}\n\n"
            if not pd.isna(treatment_info['medical_care']):
                response += f"**Medical Care:**\n{treatment_info['medical_care']}\n\n"
            if not pd.isna(treatment_info['antivenom']):
                response += f"**Antivenom:**\n{treatment_info['antivenom']}\n\n"
            response += "⚠️ **CRITICAL: Seek immediate medical attention. Call emergency services now!**"
            return response
        
        elif any(word in message_lower for word in ['venomous', 'dangerous', 'poison']):
            response = f"**{species_info['name']}** - Venomous: {species_info['venomous']}\n\n"
            response += f"Region: {species_info['region']}\n\n"
            if species_info['venomous'] == 'Yes':
                response += "This is a venomous species. If bitten, seek immediate medical attention!"
            else:
                response += "This is a non-venomous species. However, any bite should be evaluated by a medical professional."
            return response
    
    # General snakebite advice
    if any(word in message_lower for word in ['bite', 'bitten', 'emergency', 'help']):
        return (
            "**SNAKEBITE EMERGENCY PROTOCOL:**\n\n"
            "1. **Call Emergency Services Immediately** (911 or local emergency number)\n"
            "2. **Keep the victim calm and still** - movement speeds venom spread\n"
            "3. **Remove jewelry/tight clothing** near the bite before swelling\n"
            "4. **Position the bite below heart level**\n"
            "5. **Clean the wound gently** with soap and water\n"
            "6. **Cover with clean, dry dressing**\n\n"
            "**DO NOT:**\n"
            "❌ Cut the wound\n"
            "❌ Apply ice\n"
            "❌ Apply tourniquet\n"
            "❌ Try to suck out venom\n\n"
            "⚠️ **Time is critical! Get to a hospital immediately!**"
        )
    
    # Symptoms query
    if any(word in message_lower for word in ['symptom', 'sign']):
        return (
            "**Common Venomous Snakebite Symptoms:**\n\n"
            "• Pain and swelling at bite site\n"
            "• Puncture marks (may be faint)\n"
            "• Redness and bruising\n"
            "• Difficulty breathing\n"
            "• Nausea and vomiting\n"
            "• Blurred vision\n"
            "• Sweating and salivating\n"
            "• Numbness or tingling\n\n"
            "**If you experience any of these symptoms after a snakebite, seek immediate medical attention!**"
        )
    
    # Default helpful response
    return (
        "I can help you with snakebite information and treatment guidance. "
        "You can ask me about:\n\n"
        "• First aid for snakebites\n"
        "• Symptoms to watch for\n"
        "• Treatment protocols\n"
        "• Snake species information\n\n"
        "**Remember: For any snakebite emergency, call emergency services immediately!**"
    )


@app.post("/chat", response_model=ChatResponse)
async def api_chat(req: ChatRequest, _=Depends(verify_api_key)):
    """Enhanced chat endpoint with species context, treatment data, and conversation history.
    Only the 'message' field is required. All other fields are optional with defaults.
    """
    logger.debug(f"Received message from user {req.user_id}: {req.message}")
    logger.info(f"[CHAT DEBUG] Starting chat request. LLM is None: {LLM is None}")
    
    try:
        # Initialize or get conversation history
        conv_id = req.conversation_id or str(uuid.uuid4())
        if conv_id not in chat_histories:
            chat_histories[conv_id] = []
        
        # Get species context from various sources
        species_name = req.species_name
        if not species_name and req.user_id in user_species_context:
            species_name = user_species_context[req.user_id]
            logger.debug(f"Retrieved species context for user {req.user_id}: {species_name}")
        else:
            logger.debug(f"No species context found for user {req.user_id}")
            
        # Build comprehensive context
        context_parts = []
        logger.debug("Building context with species_name: %s", species_name)
        
        # Add species and treatment info if available
        treatment_info = None
        species_info = None
        
        if species_name and SPECIES_DF is not None:
            species_data = SPECIES_DF[SPECIES_DF["binomial_name"] == species_name]
            if not species_data.empty:
                row = species_data.iloc[0]
                species_info = {
                    'name': species_name,
                    'region': f"{row.get('country', 'Unknown')} ({row.get('continent', 'Unknown')})",
                    'venomous': 'Yes' if row.get('poisonous') == 1 else 'No'
                }
                context_parts.append(f"Snake Species Information:")
                context_parts.append(f"- Species: {species_name}")
                context_parts.append(f"- Region: {species_info['region']}")
                context_parts.append(f"- Venomous: {species_info['venomous']}")
                
                if TREATMENT_DF is not None:
                    treatment = TREATMENT_DF[TREATMENT_DF["scientific_name"] == species_name]
                    if not treatment.empty:
                        t_row = treatment.iloc[0]
                        treatment_info = {
                            'first_aid': t_row.get('immediate_first_aid_core'),
                            'medical_care': t_row.get('initial_hospital_actions'),
                            'antivenom': t_row.get('antivenom_name_or_type')
                        }
                        context_parts.append("\nTreatment Protocol:")
                        if not pd.isna(treatment_info['first_aid']):
                            context_parts.append(f"- First Aid: {treatment_info['first_aid']}")
                        if not pd.isna(treatment_info['medical_care']):
                            context_parts.append(f"- Medical Care: {treatment_info['medical_care']}")
                        if not pd.isna(treatment_info['antivenom']):
                            context_parts.append(f"- Antivenom: {treatment_info['antivenom']}")
        
        # Add symptom/region based context if no species identified
        elif req.symptoms or req.region:
            context_parts.append("Case Information (No specific species identified):")
            if req.symptoms:
                context_parts.append(f"- Reported Symptoms: {req.symptoms}")
            if req.region:
                context_parts.append(f"- Geographic Location: {req.region}")
                
            # Try to suggest possible species based on region
            if SPECIES_DF is not None and req.region:
                possible_species = SPECIES_DF[
                    SPECIES_DF["country"].str.contains(req.region, case=False, na=False) |
                    SPECIES_DF["continent"].str.contains(req.region, case=False, na=False)
                ]
                if not possible_species.empty:
                    context_parts.append("\nPossible Species in Region:")
                    for _, sp in possible_species.head(3).iterrows():
                        context_parts.append(f"- {sp['binomial_name']} ({sp.get('common_name', 'Unknown common name')})")
                        
        context = "\n".join(context_parts)
        
        # If LLM is not available, provide intelligent fallback response
        if LLM is None:
            logger.info("[CHAT DEBUG] LLM not available, using fallback response")
            response = _generate_fallback_response(req.message, species_info, treatment_info)
            chat_histories[conv_id].append((req.message, response))
            return {
                "response": response,
                "conversation_id": conv_id,
                "species_context": species_name
            }
            
        logger.info("[CHAT DEBUG] LLM is available, continuing...")
                        
        context = "\n".join(context_parts)
        
        # Create system prompt
        system_prompt = (
            "You are an expert snake and snakebite consultant specialized in identification and treatment. "
            "Key responsibilities:\n"
            "1. Provide accurate species and treatment information when available\n"
            "2. Always emphasize seeking immediate medical attention for snakebites\n"
            "3. If species is unknown but symptoms/region provided, suggest possible species and relevant treatments\n"
            "4. Base advice on provided context (species data, treatment protocols, regional information)\n"
            "5. Consider previous conversation history for context continuity\n"
            "6. Always remind that definitive identification and treatment requires medical professionals\n"
        )
        
        # Build full prompt with context and history
        prompt = f"{system_prompt}\n\nContext:\n{context}\n\n"
        
        # Add recent conversation history
        if chat_histories[conv_id]:
            prompt += "Recent Conversation:\n"
            for msg in chat_histories[conv_id][-3:]:  # Last 3 exchanges
                prompt += f"User: {msg[0]}\nAssistant: {msg[1]}\n"
        
        prompt += f"\nUser: {req.message}\nAssistant:"
        
        logger.info(f"[CHAT DEBUG] Calling LLM with prompt length: {len(prompt)}")
        # Get response from LLM
        out = LLM(prompt, max_tokens=1024)
        logger.info(f"[CHAT DEBUG] LLM returned: {type(out)}")
        response = out["choices"][0]["text"].strip()
        logger.info(f"[CHAT DEBUG] Extracted response length: {len(response)}")
        
        # Update conversation history
        chat_histories[conv_id].append([req.message, response])
        
        # Return response with conversation tracking
        return {
            "response": response,
            "conversation_id": conv_id,
            "species_context": species_name
        }
        
    except Exception as e:
        logger.error(f"Error in chat handling: {str(e)}", exc_info=True)
        import traceback
        return {
            "response": "I apologize, but I encountered an error. Please try again in a moment.",
            "conversation_id": req.conversation_id,
            "species_context": None,
            "debug_error": str(e),
            "debug_traceback": traceback.format_exc()
        }

    q = req.user_input.lower()
    # simple intent handling
    if any(k in q for k in ("treatment", "bite", "first aid")):
        if TREATMENT_DF is None:
            assistant = "Treatment data not loaded. Enable model/data paths and restart the server."
        else:
            assistant = get_treatment(req.species_name, TREATMENT_DF, chat, LLM)
    elif any(k in q for k in ("where", "found", "region", "habitat")):
        if SPECIES_DF is None:
            assistant = "Species metadata not loaded. Enable model/data paths and restart the server."
        else:
            meta = SPECIES_DF[SPECIES_DF["binomial_name"] == req.species_name]
            assistant = (
                f"🌍 Found in {meta.iloc[0]['country']} ({meta.iloc[0]['continent']})."
                if not meta.empty
                else f"Sorry, no habitat info for {req.species_name}."
            )
    elif any(k in q for k in ("venom", "poison")):
        if SPECIES_DF is None:
            assistant = "Species metadata not loaded. Enable model/data paths and restart the server."
        else:
            meta = SPECIES_DF[SPECIES_DF["binomial_name"] == req.species_name]
            venomous = (
                "Yes" if (not meta.empty and meta.iloc[0]["poisonous"] == 1) else "No" if not meta.empty else "Unknown"
            )
            assistant = f"☠️ Venomous: {venomous}"
    # Generate response
    try:
        if LLM is not None:
            # Add context about species if provided
            species_context = ""
            if req.species_name and SPECIES_DF is not None:
                meta = SPECIES_DF[SPECIES_DF["binomial_name"] == req.species_name]
                if not meta.empty:
                    row = meta.iloc[0]
                    species_context = f"\nContext: The question is about {req.species_name}, "
                    species_context += f"a snake species found in {row['country']} ({row['continent']}). "
                    species_context += "Venomous: Yes." if row['poisonous'] == 1 else "Venomous: No."
            
            prompt = (
                "You are an expert snake and snakebite consultant. Provide accurate, helpful information about snakes, "
                "their behavior, habitats, and safety precautions. If asked about medical advice, remind users to "
                "seek professional medical help for any snakebite.\n\n"
                f"{format_chat([[msg[0], msg[1]] for msg in chat])}"  # Remove timestamps for prompt
                f"{species_context}\n"
                f"\nUser question: {req.user_input}\n"
                "Assistant: "
            )
            out = LLM(prompt, max_tokens=512)
            assistant = out["choices"][0]["text"].strip()
        else:
            # Fallback to metadata if species is provided
            if req.species_name and SPECIES_DF is not None:
                meta = SPECIES_DF[SPECIES_DF["binomial_name"] == req.species_name]
                if not meta.empty:
                    assistant = (
                        f"I don't have an LLM available, but here's basic info about {req.species_name}: "
                        f"Found in {meta.iloc[0]['country']} ({meta.iloc[0]['continent']}). "
                        "The snake is venomous." if meta.iloc[0]['poisonous'] == 1 else "The snake is not venomous."
                    )
                else:
                    assistant = f"No metadata found for the species {req.species_name}."
            else:
                assistant = "LLM is not available. Please provide a species name to get specific information."
        
        # Save assistant's response with timestamp
        append_chat(chat, "Assistant", assistant)
        chat[-1].append(current_time)
        chat_histories[conv_id] = chat
        
        return {
            "conversation_id": conv_id,
            "assistant": assistant,
            "chat_history": [[msg[0], msg[1]] for msg in chat]  # Remove timestamps from response
        }
    except Exception as e:
        logger.error(f"Error generating response: {str(e)}", exc_info=True)
        if "No GPU detected, using CPU" in str(e):
            assistant = "I'm currently initializing. Please try again in a few moments."
        else:
            assistant = "I apologize, but I encountered an error processing your request. Please try again."
        append_chat(chat, "Assistant", assistant)
        chat[-1].append(current_time)
        chat_histories[conv_id] = chat
        return JSONResponse(
            status_code=500,
            content={
                "conversation_id": conv_id,
                "assistant": assistant,
                "chat_history": [[msg[0], msg[1]] for msg in chat]
            }
        )

    append_chat(chat, "Assistant", assistant)
    return {"assistant": assistant, "chat_history": chat}


@app.post("/chat_form", response_model=ChatResponse)
async def api_chat_form(
    message: str = Form(...),
    _=Depends(verify_api_key),
):
    """Compatibility endpoint that accepts multipart/form-data for Postman testing.
    Only requires the message field.
    """
    try:
        req = ChatRequest(message=message)
        return await api_chat(req, True)
    except Exception as e:
        logger.error(f"Error in chat_form endpoint: {str(e)}", exc_info=True)
        return JSONResponse(
            status_code=500,
            content={
                "response": "I apologize, but I encountered an error. Please try again."
            }
        )


# pandas is required by model_loader and used for metadata formatting
