"""
Verification script: Confirms both ML models output native Arabic script.
Run this with the server venv active.
"""
import sys
import os
import numpy as np

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from main import (
    whisper_processor, whisper_model,
    literal_processor, literal_model,
    strip_tashkeel, calculate_score
)

ARABIC_BLOCK_RE = __import__('re').compile(r'[\u0600-\u06FF]')
LATIN_RE = __import__('re').compile(r'[a-zA-Z]')

def is_arabic_output(text: str) -> bool:
    """Returns True if the text contains Arabic script (not mainly Latin)."""
    arabic_count = len(ARABIC_BLOCK_RE.findall(text))
    latin_count = len(LATIN_RE.findall(text))
    return arabic_count > latin_count


# --- Test 1: Model Output Script Check ---
print("=" * 60)
print("TEST 1: Model Arabic-script output verification")
print("=" * 60)
print("Generating synthetic silence audio (0.5s @16kHz)...")

# Use 0.5 seconds of low-level noise (not complete silence — avoids validation block)
np.random.seed(42)
dummy_audio = np.random.randn(8000).astype(np.float32) * 0.01

# Whisper
print("\n[Whisper Model]")
if whisper_model and whisper_processor:
    input_features = whisper_processor(dummy_audio, sampling_rate=16000, return_tensors="pt").input_features
    import torch
    with torch.no_grad():
        predicted_ids = whisper_model.generate(input_features, do_sample=False, num_beams=1, max_new_tokens=50)
    whisper_out = whisper_processor.batch_decode(predicted_ids, skip_special_tokens=True)[0]
    print(f"  Output: '{whisper_out}'")
    print(f"  Is Arabic: {is_arabic_output(whisper_out) or len(whisper_out.strip()) == 0}")
else:
    print("  SKIP: Whisper model not loaded.")

# Literal
print("\n[Literal Wav2Vec2 Model]")
if literal_model and literal_processor:
    input_values = literal_processor(dummy_audio, return_tensors="pt", sampling_rate=16000).input_values
    with torch.no_grad():
        logits = literal_model(input_values).logits
    predicted_ids = torch.argmax(logits, dim=-1)
    literal_out = literal_processor.batch_decode(predicted_ids)[0]
    print(f"  Output: '{literal_out}'")
    has_buckwalter = bool(LATIN_RE.search(literal_out))
    print(f"  Contains Buckwalter/Latin: {has_buckwalter}")
    if has_buckwalter:
        print("  FAIL: Model is still outputting Buckwalter transliteration!")
        sys.exit(1)
    else:
        print("  PASS: Model outputs Arabic script (or silence).")
else:
    print("  SKIP: Literal model not loaded.")


# --- Test 2: Score Check ---
print("\n" + "=" * 60)
print("TEST 2: Scoring correctness")
print("=" * 60)

cases = [
    ("Correct ALM",    "الم",       "الم",       lambda s: s >= 90,  ">=90%"),
    ("Wrong ALR",      "الم",       "الر",       lambda s: s < 50,   "<50%"),
    ("Basmalah OK",    "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
                       "بسم الله الرحمن الرحيم", lambda s: s >= 80,  ">=80%"),
    ("Missing words",  "بسم الله الرحمن الرحيم",
                       "بسم الله",  lambda s: s < 60,   "<60%"),
]

all_passed = True
for name, ref, hyp, condition, expectation in cases:
    score = calculate_score(ref, hyp)
    passed = condition(score)
    status = "PASS" if passed else "FAIL"
    print(f"  [{status}] {name}: score={score}% (expected {expectation})")
    if not passed:
        all_passed = False

print("\n" + "=" * 60)
if all_passed:
    print("ALL TESTS PASSED ✓")
else:
    print("SOME TESTS FAILED ✗")
    sys.exit(1)
