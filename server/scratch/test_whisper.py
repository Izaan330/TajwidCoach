import torch
import os
import sys

from transformers import WhisperProcessor, WhisperForConditionalGeneration, GenerationConfig

MODEL_ID = "tarteel-ai/whisper-base-ar-quran"
print(f"Loading {MODEL_ID}...")
processor = WhisperProcessor.from_pretrained(MODEL_ID)
model = WhisperForConditionalGeneration.from_pretrained(MODEL_ID)

# Test generate with dummy input
input_features = torch.randn(1, 80, 3000)

print("\n--- Test 5: is_multilingual = True + language ---")
try:
    model.generation_config.is_multilingual = True
    out = model.generate(input_features, language="arabic", task="transcribe", max_new_tokens=10)
    print("Success!")
except Exception as e:
    print(f"Error: {e}")

print("\n--- Test 6: Setting is_multilingual = True in config ---")
try:
    model.config.is_multilingual = True
    out = model.generate(input_features, language="arabic", task="transcribe", max_new_tokens=10)
    print("Success!")
except Exception as e:
    print(f"Error: {e}")

print("\n--- Test 7: Passing language through GenerationConfig ---")
try:
    gen_config = GenerationConfig.from_pretrained(MODEL_ID)
    gen_config.language = "arabic"
    gen_config.task = "transcribe"
    out = model.generate(input_features, generation_config=gen_config, max_new_tokens=10)
    print("Success!")
except Exception as e:
    print(f"Error: {e}")

print("\n--- Test 8: No language (Native only) ---")
try:
    out = model.generate(input_features, max_new_tokens=10)
    print("Success!")
except Exception as e:
    print(f"Error: {e}")

print("\n--- Test 9: Setting language in GenerationConfig directly ---")
try:
    model.generation_config.language = "arabic"
    model.generation_config.task = "transcribe"
    model.generation_config.is_multilingual = True
    out = model.generate(input_features, max_new_tokens=10)
    print("Success!")
except Exception as e:
    print(f"Error: {e}")
