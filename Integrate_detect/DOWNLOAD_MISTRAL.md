# Alternative Download Methods for Mistral 7B

Due to the large file size (4.37 GB) and potential network timeouts, here are alternative download methods:

## Method 1: Direct Browser Download (Recommended)

1. Open this URL in your browser:
   ```
   https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf
   ```

2. Your browser will start downloading the file
3. Save it to: `c:\Users\aryan\Desktop\snakebite_ai_assistant\Integrate_detect\models\`
4. Rename to: `mistral-7b-instruct-v0.2.Q4_K_M.gguf`

**Advantage**: Browsers handle resume automatically if connection drops

## Method 2: Using PowerShell with Progress (Auto-Resume)

```powershell
cd c:\Users\aryan\Desktop\snakebite_ai_assistant\Integrate_detect\models

# Download with auto-resume capability
$url = "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf"
$output = "mistral-7b-instruct-v0.2.Q4_K_M.gguf"

# Use BITS (Background Intelligent Transfer Service) - handles network interruptions
Start-BitsTransfer -Source $url -Destination $output -DisplayName "Mistral 7B Download" -Description "Downloading LLM model"
```

**Advantage**: BITS automatically resumes if network drops, shows progress

## Method 3: Using curl (if installed)

```powershell
cd c:\Users\aryan\Desktop\snakebite_ai_assistant\Integrate_detect\models

curl -L -C - -o mistral-7b-instruct-v0.2.Q4_K_M.gguf "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf"
```

**Advantage**: `-C -` flag auto-resumes from where it left off

## Method 4: Split Download (if all fail)

Download a smaller quantized version first to test the system:

```powershell
# Q2_K version (2.5 GB instead of 4.4 GB)
cd c:\Users\aryan\Desktop\snakebite_ai_assistant\Integrate_detect\models

python -c "from huggingface_hub import hf_hub_download; hf_hub_download(repo_id='TheBloke/Mistral-7B-Instruct-v0.2-GGUF', filename='mistral-7b-instruct-v0.2.Q2_K.gguf', local_dir='models')"
```

Then update `model_loader.py` line 88:
```python
default_llm = "models/mistral-7b-instruct-v0.2.Q2_K.gguf"  # Smaller version
```

**Advantage**: Smaller file, faster download, still works well

## Verify Download

After download completes, verify:

```powershell
cd c:\Users\aryan\Desktop\snakebite_ai_assistant\Integrate_detect\models
Get-Item mistral-7b-instruct-v0.2.Q4_K_M.gguf | Select-Object Name, Length, @{Name="SizeGB";Expression={[math]::Round($_.Length/1GB, 2)}}
```

Should show: **~4.37 GB**

## Next Steps After Download

1. Restart the backend server
2. Check logs for: `INFO:app:LLM model loaded with context size: 4096`
3. Test the chat endpoint
4. Run the Flutter app and try the assistant

---

**Current Issue**: Network timeout during large file download  
**Recommended Solution**: Use Method 1 (browser) or Method 2 (BITS) for reliable download with auto-resume
