import os, traceback

model_path = os.getenv('LLM_MODEL_PATH')
print('LLM_MODEL_PATH =', model_path)

try:
    from llama_cpp import Llama
    print('llama_cpp imported, version:', getattr(Llama, '__module__', 'unknown'))
    print('Attempting to create Llama instance...')
    llm = Llama(model_path=model_path, n_ctx=1024, n_threads=1)
    print('Successfully created Llama instance')
    # try a small prompt
    resp = llm('Hello', max_tokens=5)
    print('LLM responded:', resp)
except Exception as e:
    print('Failed to load Llama:')
    traceback.print_exc()
