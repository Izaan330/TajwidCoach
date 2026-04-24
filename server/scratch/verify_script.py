from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor
import torch
import numpy as np

MODEL_ID = "jonatasgrosman/wav2vec2-large-xlsr-53-arabic"
processor = Wav2Vec2Processor.from_pretrained(MODEL_ID)
model = Wav2Vec2ForCTC.from_pretrained(MODEL_ID)

# Test with a dummy waveform (silent/noise) just to see the type of output string
dummy_input = torch.randn(1, 16000)
logits = model(dummy_input).logits
predicted_ids = torch.argmax(logits, dim=-1)
transcription = processor.batch_decode(predicted_ids)[0]

print(f"Transcription type: {type(transcription)}")
print(f"Sample Transcription: '{transcription}'")

# Check if it contains Arabic characters
import re
has_arabic = bool(re.search(r'[\u0600-\u06FF]', transcription))
print(f"Contains Arabic characters: {has_arabic}")
