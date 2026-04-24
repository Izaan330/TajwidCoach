from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor
import sys

MODEL_ID = "jonatasgrosman/wav2vec2-large-xlsr-53-arabic"

print(f"Downloading {MODEL_ID}... This will take a few minutes (~1.2GB).")
try:
    processor = Wav2Vec2Processor.from_pretrained(MODEL_ID)
    model = Wav2Vec2ForCTC.from_pretrained(MODEL_ID)
    print("\nDownload complete!")
except Exception as e:
    print(f"\nError downloading model: {e}")
    sys.exit(1)
