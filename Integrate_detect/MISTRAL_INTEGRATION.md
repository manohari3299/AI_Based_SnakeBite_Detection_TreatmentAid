# Mistral 7B LLM Integration for Snake Bite Assistant

## Overview

The Mistral 7B Instruct model provides intelligent, context-aware responses in the chat assistant, especially after snake classification. It generates personalized medical protocol suggestions based on:

- Identified snake species
- Regional data
- Venom type and severity
- Treatment protocols from the database
- User symptoms (if provided)

## How It Works

### 1. After Snake Identification

When a user captures a photo and the snake is classified:

```
User takes photo → API identifies species → Results page shows:
  ├─ Snake species (e.g., "Naja naja" - Indian Cobra)
  ├─ Confidence score
  ├─ Venomous status
  └─ Geographic region
```

### 2. Chat Assistant Enhancement

When the user opens the chat assistant, the LLM receives full context:

**Input to Mistral:**
```
System: You are an expert snake and snakebite consultant...

Context:
Species: Naja naja (Indian Cobra)
Region: India (Asia)
Venomous: Yes
Treatment Protocol:
- First Aid: Keep victim calm, immobilize bitten limb...
- Medical Care: Seek immediate medical attention...
- Antivenom: Polyvalent antivenom required

User: What should I do if bitten?
```

**LLM Response:**
```
If bitten by an Indian Cobra (Naja naja), immediate action is critical:

IMMEDIATE FIRST AID:
1. Keep the victim calm and still - movement spreads venom
2. Immobilize the bitten limb at heart level
3. Remove jewelry/tight clothing near the bite
4. Do NOT apply tourniquet or ice
5. Do NOT attempt to suck out venom

URGENT MEDICAL CARE:
- Call emergency services immediately (108 in India)
- This species has neurotoxic venom affecting breathing
- Polyvalent antivenom is required within 4-6 hours
- Monitor breathing - be prepared for CPR

CRITICAL: Get to a hospital with antivenom NOW. Cobra bites 
can be fatal without treatment. Time is life-threatening.
```

### 3. Contextual Follow-up Questions

The LLM maintains conversation history and species context:

```
User: How long does the venom take to act?

LLM: Naja naja (Indian Cobra) venom typically shows effects within:
- Local pain/swelling: 15-30 minutes
- Neurological symptoms (ptosis, difficulty breathing): 1-2 hours
- Severe respiratory paralysis: 4-6 hours if untreated

This is a medical emergency. Don't wait for symptoms - 
seek antivenom treatment immediately after any cobra bite.
```

## Benefits Over Simple Responses

### Without LLM (Fallback Mode):
```
User: What should I do if bitten?
Response: "This is a venomous snake. Seek immediate medical attention."
```

### With Mistral 7B:
```
User: What should I do if bitten?
Response: [Detailed, species-specific protocol with timelines, 
symptoms to watch for, regional emergency numbers, antivenom 
requirements, and critical warnings based on actual venom type]
```

## Implementation Details

### Model Specifications
- **Model**: Mistral-7B-Instruct-v0.2
- **Quantization**: Q4_K_M (4-bit, medium quality)
- **Size**: 4.37 GB
- **Context Window**: 4096 tokens (adjustable: 4096 → 2048 → 1024 based on system)
- **Threads**: Auto-detected (CPU cores, optimized for performance)

### API Endpoint: `/chat`

**Request:**
```json
{
  "message": "What are the symptoms of this snake's bite?",
  "conversation_id": "uuid-here",
  "species_name": "Naja naja",
  "user_id": "user123",
  "region": "India",
  "symptoms": "swelling, numbness"
}
```

**Response:**
```json
{
  "response": "Based on Naja naja (Indian Cobra) identification...",
  "conversation_id": "uuid-here",
  "species_context": "Naja naja"
}
```

### Context Building (Automatic)

The backend automatically enriches the LLM prompt with:

1. **Species Data** (if identified):
   - Scientific and common names
   - Geographic distribution
   - Venomous classification
   - Medical significance

2. **Treatment Protocols** (from database):
   - First aid procedures
   - Medical interventions
   - Antivenom requirements
   - Regional availability

3. **Conversation History**:
   - Last 3 exchanges for context continuity
   - Species context from previous classification

4. **User-Provided Context**:
   - Symptoms (if reported)
   - Location (for regional species matching)

## System Prompt

The LLM operates with strict medical safety guidelines:

```
You are an expert snake and snakebite consultant specialized in 
identification and treatment. Key responsibilities:

1. Provide accurate species and treatment information when available
2. ALWAYS emphasize seeking immediate medical attention for snakebites
3. If species unknown but symptoms/region provided, suggest possible 
   species and relevant treatments
4. Base advice on provided context (species data, treatment protocols,
   regional information)
5. Consider previous conversation history for context continuity
6. Always remind that definitive identification and treatment requires
   medical professionals
```

## Performance Optimization

### CPU Inference (llama-cpp-python)
- Optimized for CPU-only systems
- No GPU required
- Multi-threaded processing
- Adaptive context sizing for low-memory systems

### Fallback Strategy
If LLM fails to load (insufficient memory, missing file):
- Server continues running
- Chat returns basic database responses
- No service interruption
- Warning logged for debugging

## Testing the Integration

### 1. Check Model Loading
```bash
cd Integrate_detect
python -m uvicorn app:app --host 0.0.0.0 --port 8000
```

Look for:
```
INFO:app:Successfully loaded all models and data
INFO:app:LLM model loaded with context size: 4096
```

### 2. Test Chat Endpoint
```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: changeme" \
  -d '{
    "message": "What should I do if bitten?",
    "species_name": "Naja naja"
  }'
```

### 3. Mobile App Testing
1. Take photo → Get species classification
2. Open chat assistant
3. Ask: "What are the symptoms?"
4. Verify: Detailed, species-specific response

## Resource Requirements

### Minimum:
- RAM: 6 GB (4 GB model + 2 GB overhead)
- CPU: 4 cores (or 2 cores with patience)
- Disk: 4.5 GB free space

### Recommended:
- RAM: 8+ GB
- CPU: 6+ cores
- SSD for faster model loading

### Performance:
- First response: 3-10 seconds (model loading + inference)
- Subsequent responses: 1-3 seconds
- Latency depends on prompt complexity and CPU speed

## Troubleshooting

### "LLM model not loaded"
- Check file exists: `Integrate_detect/models/mistral-7b-instruct-v0.2.Q4_K_M.gguf`
- Check size: Should be ~4.37 GB
- Check RAM: Ensure 6+ GB available
- Check logs for specific error

### Slow Responses
- Reduce context window (edit model_loader.py: n_ctx=2048)
- Reduce threads (n_threads=2)
- Use smaller quantization (Q2_K instead of Q4_K_M)

### Out of Memory
- Close other applications
- Use Q2_K model (smaller, ~2.5 GB)
- Reduce n_ctx to 1024 or 512

## Future Enhancements

1. **Multi-language Support**: Mistral supports multiple languages
2. **Image Analysis**: Combine with vision model for bite wound assessment
3. **Emergency Contacts**: Auto-suggest local hospitals with antivenom
4. **Symptom Progression**: Predictive timeline based on species
5. **Treatment Plans**: Generate PDFs with step-by-step protocols

---

**Note**: This LLM integration dramatically improves user experience by providing intelligent, context-aware medical guidance. However, it should ALWAYS be paired with the warning that professional medical care is required for actual snake bites.
