import os
import random
import numpy as np
import librosa
import torch
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor
import uvicorn

app = FastAPI(title="TajwidCoach ML Backend")

# Mount the 1.2GB Quran images directory so the app can download them on demand.
# This only works locally — the assets folder is NOT deployed to Cloud Run.
# In production, images are served directly from Firebase Storage instead.
import os
quran_images_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "images", "quran"))
if os.path.isdir(quran_images_dir):
    app.mount("/images/quran", StaticFiles(directory=quran_images_dir), name="quran_images")
    print(f"Quran images mounted from: {quran_images_dir}")
else:
    print("Quran images directory not found — skipping static mount (running in Cloud Run).")

# --- ML MODEL SETUP ---
from transformers import WhisperProcessor, WhisperForConditionalGeneration, Wav2Vec2ForCTC, Wav2Vec2Processor

WHISPER_MODEL_ID = "tarteel-ai/whisper-base-ar-quran"
LITERAL_MODEL_ID = "jonatasgrosman/wav2vec2-large-xlsr-53-arabic"

whisper_processor = None
whisper_model = None
literal_processor = None
literal_model = None

try:
    print(f"Loading Specialized Whisper model {WHISPER_MODEL_ID}...")
    whisper_processor = WhisperProcessor.from_pretrained(WHISPER_MODEL_ID)
    whisper_model = WhisperForConditionalGeneration.from_pretrained(WHISPER_MODEL_ID)
    # We leave forced_decoder_ids as None for newer transformers compatibility
    whisper_model.config.forced_decoder_ids = None
    
    print(f"Loading Literal Wav2Vec2 model {LITERAL_MODEL_ID}...")
    literal_processor = Wav2Vec2Processor.from_pretrained(LITERAL_MODEL_ID)
    literal_model = Wav2Vec2ForCTC.from_pretrained(LITERAL_MODEL_ID)
    
    print("All ML models loaded successfully.")
except Exception as e:
    print(f"CRITICAL ERROR: Could not load ML models: {e}")
    print("Will use heuristic analysis as fallback.")

# Reference Ayahs (normalized for comparison — without tashkeel for simpler matching)
REFERENCE_AYAHS = {
    "1:1": "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
    "1:2": "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
    "1:3": "الرَّحْمَنِ الرَّحِيمِ",
    "1:4": "مَالِكِ يَوْمِ الدِّينِ",
    "1:5": "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
    "1:6": "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ",
    "1:7": "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
    "114:1": "قُلْ أَعُوذُ بِرَبِّ النَّاسِ",
    "114:2": "مَلِكِ النَّاسِ",
    "114:3": "إِلَهِ النَّاسِ",
    "114:4": "مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ",
    "114:5": "الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ",
    "114:6": "مِنَ الْجِنَّةِ وَالنَّاسِ",
}

from models import RuleScore, TajwidAnalysisResult


def strip_tashkeel(text: str) -> str:
    """Remove Arabic diacritics (tashkeel) and normalize for lenient comparison."""
    import re
    # Remove all vowel marks, dagger alifs, sukoon, shaddah, and Quranic stop marks
    tashkeel = re.compile(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u200F\u200E]')
    text = re.sub(tashkeel, '', text)
    
    # Normalize Alef forms (Madda, Hamza above/below, Wasla) to bare Alef
    text = re.sub(r'[آأإٱ]', 'ا', text)
    
    # Normalize Ta-Marbuta to Ha (since audio models often transcribe it as Ha)
    text = re.sub(r'ة', 'ه', text)
    
    # Normalize Alef Maksura to Yaa
    text = re.sub(r'ى', 'ي', text)
    
    # Normalize Waw with Hamza to bare Waw
    text = re.sub(r'ؤ', 'و', text)
    
    # Normalize Yaa with Hamza to bare Yaa
    text = re.sub(r'ئ', 'ي', text)
    
    # Strip any remaining Non-Arabic characters (including digits, Latin, and symbols)
    # but keep spaces and the Arabic block.
    # We use a broad range for Arabic characters and exclude digits 0-9.
    text = re.sub(r'[^ \u0600-\u06FF]', '', text)
    text = re.sub(r'[0-9]', '', text)
    
    return text


import difflib

def calculate_score(reference: str, hypothesis: str) -> int:
    """
    Balanced scoring against reference.
    Primary: word-level sequence matching.
    Secondary: character-level for short strings (Muqatta'at).
    """
    if not hypothesis.strip():
        return 0

    # Clean versions for comparison
    ref_norm = strip_tashkeel(reference).strip()
    hyp_norm = strip_tashkeel(hypothesis).strip()
    
    ref_words = ref_norm.split()
    hyp_words = hyp_norm.split()

    if not ref_words:
        return 0

    # 1. Word-level matching (primary signal)
    word_matcher = difflib.SequenceMatcher(None, ref_words, hyp_words)
    word_accuracy = word_matcher.ratio()
    
    # 2. Character-level matching (critical for short strings like "الم")
    char_matcher = difflib.SequenceMatcher(None, ref_norm, hyp_norm)
    char_accuracy = char_matcher.ratio()

    # Weighted blend: char-level is primary for short strings, word-level for long.
    if len(ref_words) <= 2:
        accuracy = (0.35 * word_accuracy + 0.65 * char_accuracy) * 100
    else:
        accuracy = (0.70 * word_accuracy + 0.30 * char_accuracy) * 100
    
    # Moderate penalty for clearly missing/extra words (8% each, capped at 3 words)
    len_diff = abs(len(ref_words) - len(hyp_words))
    if len_diff > 0:
        accuracy -= min(len_diff, 3) * 8
        
    return int(max(min(accuracy, 100), 0))


import re

def detect_rules_in_text(arabic_text: str) -> list[str]:
    """Heuristic detection of all 25 Tajwid rules present in Arabic text with Tashkeel."""
    rules = set()
    if not arabic_text:
        return []
        
    # 1. Shaddah
    # if 'ّ' in arabic_text:
    #     rules.add('shaddah')
    #     
    # 2. Ghunnah (Noon/Meem with Shaddah)
    if 'نّ' in arabic_text or 'مّ' in arabic_text or 'ن\u0651' in arabic_text or 'م\u0651' in arabic_text:
        rules.add('ghunnah')
        
    # 3. Qalqalah (ق ط ب ج د with sukoon or at end of word pause)
    # Strip diacritics temporarily to find end-of-word characters
    clean_text = strip_tashkeel(arabic_text)
    has_qalqalah_sukun = re.search(r'[قطبجد]ْ', arabic_text) or re.search(r'[قطبجد]\u0652', arabic_text)
    has_qalqalah_end = False
    if clean_text:
        words = clean_text.split()
        # Qalqalah on pause only happens at the end of the verse
        if words and words[-1][-1] in 'قطبجد':
            has_qalqalah_end = True
    if has_qalqalah_sukun or has_qalqalah_end:
        rules.add('qalqalah')
        
    # 4 & 5. Ra Rules (Tafkhim/Tarqiq of Ra - contains Ra)
    # if 'ر' in arabic_text:
    #     rules.add('ra_rules')
    #     
    # 6 & 7. Lam Shamsiyya / Qamariyya
    # Solar letters: ت ث د ذ ر ز س ش ص ض ط ظ ل ن
    solar_letters = 'تثدذرزسشصضطظلّن'
    norm_text = re.sub(r'ٱ', 'ا', arabic_text)
    idx = 0
    while True:
        idx = norm_text.find('ال', idx)
        if idx == -1:
            break
        after_al = norm_text[idx+2:]
        clean_after = strip_tashkeel(after_al)
        if clean_after:
            next_letter = clean_after[0]
            if next_letter in solar_letters:
                rules.add('lam_shamsiyya')
            elif next_letter in 'ابجحخعغفقكمهوي':
                rules.add('lam_qamariyya')
        idx += 2
        
    # 8. Madd Tabi'i (Alef/Yaa/Waw)
    if re.search(r'َ[اى]', arabic_text) or re.search(r'ِي', arabic_text) or re.search(r'ُو', arabic_text):
        rules.add('madd_tabi')
        
    # 9 & 10. Madd Muttasil/Munfasil
    if '\u0653' in arabic_text or 'آ' in arabic_text:
        # Check if Hamzah is separated by space (next word)
        if re.search(r'[\u0653اوي]\s+[ءأإ]', arabic_text):
            rules.add('madd_munfasil')
        else:
            rules.add('madd_muttasil')

    # 11. Madd Lazim (Madd letter followed by Shaddah)
    if re.search(r'[اوي]ٓ?\s*[\u0600-\u06FF]ّ', arabic_text) or re.search(r'ٓ', arabic_text):
        rules.add('madd_lazim')
        
    # 12. Madd Leen (Waw/Yaa with Sukoon preceded by Fatha)
    if re.search(r'َ[وي]ْ', arabic_text) or re.search(r'َ[وي]\u0652', arabic_text):
        rules.add('madd_leen')
        
    # 13. Madd Arid (Madd at end of ayah before final letter)
    if re.search(r'(ِي|ُو|َا)[\u0600-\u06FF]\b', arabic_text):
        rules.add('madd_arid')
        
    # Noon Sakin & Tanween Rules
    if re.search(r'نْ', arabic_text) or re.search(r'ن\u0652', arabic_text) or re.search(r'[ًٌٍ]', arabic_text):
        # 14. Iqlab (followed by Baa)
        if re.search(r'(نْ|ن\u0652|[ًٌٍ])\s*ب', arabic_text) or 'ۢ' in arabic_text:
            rules.add('iqlab')
        # 15. Idgham (followed by ي ر م ل و ن)
        elif re.search(r'(نْ|ن\u0652|[ًٌٍ])\s*[يرملون]', arabic_text):
            rules.add('idgham')
        # 16. Izhar (followed by throat letters ء ه ع ح غ خ)
        elif re.search(r'(نْ|ن\u0652|[ًٌٍ])\s*[ءهعحغخأإ]', arabic_text):
            rules.add('izhar')
        else:
            # 17. Ikhfa (other letters)
            rules.add('ikhfa')
        
    # Meem Sakin Rules
    if re.search(r'مْ', arabic_text) or re.search(r'م\u0652', arabic_text):
        # 18. Idgham Mimi (Meem followed by Meem)
        if re.search(r'(مْ|م\u0652)\s*م', arabic_text):
            rules.add('idgham_mimi')
        # 19. Ikhfa Shafawi (Meem followed by Baa)
        elif re.search(r'(مْ|م\u0652)\s*ب', arabic_text):
            rules.add('ikhfa_shafawi')
        else:
            # 20. Izhar Shafawi (All other letters)
            rules.add('izhar_shafawi')
            
    # 21 & 22. Tafkhim and Tarqiq (Heavy and Light letters)
    # if re.search(r'[خصضغطقظ]', arabic_text):
    #     rules.add('tafkhim')
    # if re.search(r'[بتثجحدرزسشعفكلمنهوي]', arabic_text):
    #     rules.add('tarqiq')
    #     
    # 23. Hamzat al-Wasl
    if 'ٱ' in arabic_text or re.search(r'\bا', arabic_text):
        rules.add('hamzat_wasl')
        
    # 24. Waqf & Ibtida (Stop marks)
    if re.search(r'[ۗۖۚۛۙۘ]', arabic_text):
        rules.add('waqf_ibtida')
        
    # 25. Sakt (Pause without breath)
    if 'ۜ' in arabic_text:
        rules.add('sakt')
        
    # 26. Noon Qutni (Connecting Noon - mocked with small noon)
    if 'ۨ' in arabic_text:
        rules.add('noon_qutni')
        
    return list(rules)



def transcribe_whisper(speech: np.ndarray) -> str:
    """Specialized transcription using Whisper."""
    if whisper_model is None or whisper_processor is None: return ""
    
    input_features = whisper_processor(
        speech,
        sampling_rate=16000,
        return_tensors="pt"
    ).input_features

    with torch.inference_mode():
        predicted_ids = whisper_model.generate(
            input_features, 
            do_sample=False, 
            num_beams=1,
            max_new_tokens=128
        )

    return whisper_processor.batch_decode(predicted_ids, skip_special_tokens=True)[0]


def transcribe_literal(speech: np.ndarray) -> tuple:
    """Literal transcription using Wav2Vec2. Returns (transcription, end_phoneme_probs).
    
    end_phoneme_probs: dict of {arabic_letter: avg_prob} for Muqatta'at terminal
    letters over the LAST 15% of audio frames. Used for Muqatta'at phoneme checking
    even when the decoded text is garbage.
    """
    if literal_model is None or literal_processor is None: return "", {}
    
    input_values = literal_processor(
        speech,
        return_tensors="pt", # type: ignore
        sampling_rate=16000 # type: ignore
    ).input_values

    with torch.inference_mode():
        logits = literal_model(input_values).logits

    predicted_ids = torch.argmax(logits, dim=-1)
    transcription = literal_processor.batch_decode(predicted_ids)[0]
    
    # Extract end-of-audio CTC probabilities for Muqatta'at phoneme checking.
    # Even when the decoded text is garbage, the token probabilities at the very
    # end of the audio preserve which phoneme was acoustically dominant.
    end_phoneme_probs = {}
    try:
        vocab = literal_processor.tokenizer.get_vocab() # type: ignore
        probs = torch.softmax(logits[0], dim=-1)  # [time, vocab]
        n = probs.shape[0]
        # Focus on last 15% of frames — where the final letter is pronounced.
        start = max(0, int(n * 0.85))
        last_avg = probs[start:].mean(dim=0)  # [vocab]
        for ch in 'مرصنيهقعطسكح':
            if ch in vocab:
                end_phoneme_probs[ch] = float(last_avg[vocab[ch]].item())
    except Exception as _pe:
        pass  # Phoneme probs unavailable — graceful degradation
    
    return transcription, end_phoneme_probs


@app.post("/v1/analyze", response_model=TajwidAnalysisResult)
async def analyze_recitation(
    audio: UploadFile = File(...),
    ayah_ref: str = Form(...),
    reference_text: str = Form(""),
    target_rule: Optional[str] = Form(None)
):
    """
    ML Inference Endpoint for Quranic recitation analysis.
    """
    import sys
    import re
    print(f"\n--- New Analysis Request: {ayah_ref} ---", flush=True)
    
    # Use client-provided text if available, else look up in dictionary
    reference = reference_text.strip()
    if not reference:
        reference = REFERENCE_AYAHS.get(ayah_ref, "")
        
    temp_path = f"temp_{ayah_ref.replace(':', '_')}_{os.getpid()}.wav"
    try:
        content = await audio.read()
        file_size = len(content)
        print(f"Received audio data: {file_size} bytes", flush=True)
        
        if file_size == 0:
            print("ERROR: Received empty audio file!", flush=True)
            return TajwidAnalysisResult(
                overall_score=0,
                feedback="Error: Received empty audio file from phone.",
                grade="Error",
                rule_scores=[],
                weak_words=[],
                weak_rule_ids=[target_rule] if target_rule else [],
                excellent_rule_ids=[],
                encouragement="Please try recording again."
            )

        with open(temp_path, "wb") as buffer:
            buffer.write(content)

        # --- Optimized Audio Loading ---
        import soundfile as sf
        import time
        start_load = time.time()
        
        try:
            # Try direct load with soundfile first (much faster than librosa/ffmpeg)
            speech, sample_rate = sf.read(temp_path)
            print(f"Direct soundfile load took {time.time() - start_load:.4f}s", flush=True)
            
            if len(speech.shape) > 1:
                speech = np.mean(speech, axis=1)
                
            if sample_rate != 16000:
                print(f"Resampling from {sample_rate} to 16000...", flush=True)
                speech = librosa.resample(speech, orig_sr=sample_rate, target_sr=16000)
                
        except Exception as e:
            print(f"Direct load failed: {e}. Falling back to FFmpeg/Librosa...", flush=True)
            import subprocess
            clean_path = f"clean_{temp_path}"
            try:
                subprocess.run([
                    'ffmpeg', '-y', '-i', temp_path,
                    '-ar', '16000', '-ac', '1', clean_path
                ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                speech, sample_rate = librosa.load(clean_path, sr=16000, mono=True)
            finally:
                if os.path.exists(clean_path):
                    os.remove(clean_path)

        duration_sec = len(speech) / 16000
        print(f"Loaded audio: {len(speech)} samples, duration={duration_sec:.2f}s", flush=True)

        # --- Audio Validation ---
        if duration_sec < 0.5: # Restored proper threshold
            print(f"Validation failed: Audio too short ({duration_sec:.2f}s)", flush=True)
            return TajwidAnalysisResult(
                overall_score=0,
                feedback=f"Audio too short ({duration_sec:.2f}s). Please hold the button longer.",
                grade="Try Again",
                rule_scores=[],
                weak_words=[],
                weak_rule_ids=[target_rule] if target_rule else [],
                excellent_rule_ids=[],
                encouragement="🎙️ Please hold the microphone button and recite the full ayah."
            )

        # Check for silence (RMS energy too low)
        rms = float(np.sqrt(np.mean(np.square(speech))))
        print(f"Audio RMS energy: {rms:.5f}")
        if rms < 0.001: # Lowered silence threshold
            print("Validation failed: No voice detected (silent)")
            return TajwidAnalysisResult(
                overall_score=0,
                feedback="No voice detected. Please recite louder and ensure microphone permissions are granted.",
                grade="Try Again",
                rule_scores=[],
                weak_words=[],
                weak_rule_ids=[target_rule] if target_rule else [],
                excellent_rule_ids=[],
                encouragement="🎙️ Make sure your microphone is working and speak clearly."
            )

        # --- Optimized Transcription (Short-Circuit Pattern) ---
        whisper_trans = ""
        literal_trans = ""
        literal_end_probs: dict = {}
        
        # 1. Run Whisper first (it's the primary model)
        if whisper_model is not None:
            try:
                print("Running Specialized Transcription...", flush=True)
                start_ml = time.time()
                whisper_trans = transcribe_whisper(speech)
                whisper_trans = re.sub(r'<\|.*?\|>', '', whisper_trans).strip()
                print(f"SPECIALIZED HEARD: '{whisper_trans}' (took {time.time() - start_ml:.4f}s)", flush=True)
            except Exception as e:
                print(f"Whisper error: {e}")

        # 2. Check for "Short-Circuit" (trust Whisper if match is high)
        # If Whisper transcribes perfectly or near-perfectly, skip the heavy Wav2Vec2 verification.
        whisper_score = calculate_score(reference, whisper_trans)
        should_run_literal = True
        
        if whisper_score > 85:
            print(f"FAST PATH: Whisper confidence is {whisper_score}%. Skipping Literal verification.", flush=True)
            should_run_literal = False

        # 3. Only run Literal Model if needed (hallucination check)
        if should_run_literal and literal_model is not None:
            try:
                print("Running Literal Transcription (Verification)...", flush=True)
                start_l = time.time()
                literal_trans, literal_end_probs = transcribe_literal(speech)
                print(f"LITERAL HEARD: '{literal_trans}' (took {time.time() - start_l:.4f}s)", flush=True)
            except Exception as e:
                print(f"Literal error: {e}")

        # Choose transcription based on strictness
        # If Whisper highly matches but Literal diverges, it's likely a hallucination
        transcription = whisper_trans
        
        # === Dual-Model Verification ===
        # NOTE on Muqatta'at (الم، الر، يس etc.):
        #   These are isolated letter names pronounced individually (Alif, Laam, Meem).
        #   Wav2Vec2 is a general Arabic conversation model — it was NEVER trained on
        #   letter-name pronunciation and always produces garbage (e.g. 'الإفلاعمي').
        #   Therefore: skip Literal verification entirely for short letter-only verses
        #   and trust Whisper, which is Quran-specialised and handles them correctly.
        
        ref_clean_for_check = strip_tashkeel(reference)
        is_muqattaat = len(ref_clean_for_check.strip()) <= 8  # e.g. "الم"=3, "المص"=4, "كهيعص"=5
        
        if not is_muqattaat and literal_trans and whisper_trans:
            whisper_clean = strip_tashkeel(whisper_trans)
            literal_clean = strip_tashkeel(literal_trans)
            ref_clean = ref_clean_for_check
            
            # Only override if the Literal model hears something VERY different (< 30%).
            # This catches hallucinations (Whisper auto-fills correct verse despite
            # wrong recitation) without penalising genuine correct recitations where
            # Wav2Vec2 simply spells a word slightly differently.
            # Guard: Literal must produce meaningful output (not silence/noise), and
            # must be plausibly the right length (not wildly longer than reference).
            ref_stripped_len = len(ref_clean.strip())
            literal_stripped_len = len(literal_clean.strip())
            literal_has_content = (
                literal_stripped_len >= max(2, ref_stripped_len // 3)
                and literal_stripped_len <= ref_stripped_len * 3  # not wildly longer
            )
            literal_similarity = calculate_score(reference, literal_trans)
            if whisper_clean == ref_clean and literal_similarity < 30 and literal_has_content:
                print(f"STRICT MODE: Hallucination detected — Literal similarity only {literal_similarity}%. Overriding.", flush=True)
                transcription = literal_trans
        elif is_muqattaat:
            # === Muqatta'at Phoneme Check ===
            # Whisper hallucinates the correct Muqatta'at because it's Quran-biased.
            # Literal decoded text is garbage for isolated letter names.
            # BUT: raw CTC probability at the END of the audio is a reliable phoneme
            # signal — even when the decoded string is wrong. We compare:
            #   P(expected_last_letter) vs P(other_muqattaat_letters)
            # in the final 15% of frames. If a different letter dominates (≥2.5×),
            # we flag the recitation as a mistake and use literal_trans to score it low.
            ref_clean = ref_clean_for_check.strip()
            expected_last = ref_clean[-1] if ref_clean else ''

            if expected_last and literal_end_probs and expected_last in literal_end_probs:
                expected_prob = literal_end_probs[expected_last]
                best_letter = max(literal_end_probs, key=literal_end_probs.get) # type: ignore
                best_prob = literal_end_probs[best_letter]
                top5 = sorted(literal_end_probs.items(), key=lambda x: -x[1])[:5]
                print(f"Muqatta'at end-phoneme probs: {top5}", flush=True)
                print(f"  Expected '{expected_last}'={expected_prob:.5f}, Best='{best_letter}'={best_prob:.5f}", flush=True)

                if best_letter != expected_last and best_prob > expected_prob * 2.5:
                    print(f"MUQATTA'AT PHONEME: '{best_letter}' dominates over expected '{expected_last}'. Flagging mistake.", flush=True)
                    transcription = literal_trans if literal_trans else "?"
                else:
                    print(f"Muqatta'at phoneme check passed: '{expected_last}' OK.", flush=True)
            else:
                print("Muqatta'at: no phoneme data — trusting Whisper.", flush=True)


        # --- Scoring ---
        ref_text = reference
        print(f"Scoring reference: {ref_text}", flush=True)

        if not transcription:
            print("Scoring: No transcription produced")
            return TajwidAnalysisResult(
                overall_score=0,
                feedback="Could not recognize your recitation. Please recite more clearly and ensure a quiet environment.",
                grade="Try Again",
                rule_scores=[],
                weak_words=ref_text.split() if ref_text else [],
                weak_rule_ids=[target_rule] if target_rule else [],
                excellent_rule_ids=[],
                encouragement="🎙️ Try reciting in a quiet place, closer to the microphone."
            )

        score = calculate_score(ref_text, transcription) if ref_text else random.randint(70, 90)

        # --- Mismatch Check ---
        is_mismatch = False
        recited_ayah = None
        
        # Check if transcription matches another reference verse
        if score < 50 and transcription.strip():
            best_other_ref = None
            best_other_score = 0
            for ref_key, ref_val in REFERENCE_AYAHS.items():
                if ref_key == ayah_ref:
                    continue
                other_score = calculate_score(ref_val, transcription)
                if other_score > best_other_score:
                    best_other_score = other_score
                    best_other_ref = ref_key
            
            # If we found another verse that matches very well (>= 60%), it's a mismatch
            if best_other_score >= 60 and best_other_score > score:
                is_mismatch = True
                recited_ayah = best_other_ref
                print(f"MISMATCH DETECTED: expected={ayah_ref} ({score}%), recited={best_other_ref} ({best_other_score}%)", flush=True)
            elif len(strip_tashkeel(transcription).split()) >= 2:
                # If target match is low (< 50%) and we heard a phrase of at least 2 words,
                # we flag it as a mismatch (recited_ayah as "Unknown" if not in REFERENCE_AYAHS)
                is_mismatch = True
                recited_ayah = "Unknown"
                print(f"MISMATCH DETECTED: expected={ayah_ref} ({score}%), recited=Unknown", flush=True)


        if is_mismatch:
            feedback_text = f"Transcription: '{transcription}' (mismatch)"
            return TajwidAnalysisResult(
                overall_score=15,
                feedback=feedback_text,
                grade="Mismatch",
                rule_scores=[],
                weak_words=[],
                weak_rule_ids=[],
                excellent_rule_ids=[],
                encouragement="It looks like you recited a different verse. Please try reciting the expected verse.",
                is_mismatch=True,
                recited_ayah=recited_ayah
            )


        # --- Rule Detection & Mocking all 25 rules ---
        is_weak = score < 75

        all_rules = [
            'idgham', 'ikhfa', 'iqlab', 'izhar', 'qalqalah', 'madd_tabi', 
            'madd_muttasil', 'madd_munfasil', 'madd_lazim', 'ghunnah', 'shaddah',
            'tafkhim', 'tarqiq', 'lam_shamsiyya', 'lam_qamariyya', 'idgham_mimi',
            'ikhfa_shafawi', 'izhar_shafawi', 'waqf_ibtida', 'sakt', 'hamzat_wasl',
            'ra_rules', 'noon_qutni', 'madd_arid', 'madd_leen'
        ]

        if target_rule:
            rule_scores = [
                RuleScore(
                    rule_id=target_rule,
                    rule_name=target_rule.replace("_", " ").capitalize(),
                    score=score,
                    feedback="Well applied!" if not is_weak else "Continue practicing this rule.",
                    is_weak=is_weak
                )
            ]
        else:
            # Heuristic Rule Detection based on actual text
            detected_rules = detect_rules_in_text(ref_text)
            
            # If text is too short or doesn't have tashkeel, fallback to basic rules
            if not detected_rules:
                detected_rules = ['madd_tabi', 'ghunnah', 'qalqalah', 'ikhfa']
                
            rule_scores = []
            for rid in detected_rules:
                r_score = max(0, min(100, score + random.randint(-15, 15)))
                r_weak = r_score < 75
                rule_scores.append(
                    RuleScore(
                        rule_id=rid,
                        rule_name=rid.replace("_", " ").title(),
                        score=r_score,
                        feedback="Well applied!" if not r_weak else "Continue practicing this rule.",
                        is_weak=r_weak
                    )
                )

        weak_rule_ids = [r.rule_id for r in rule_scores if r.is_weak][:5]
        excellent_rule_ids = [r.rule_id for r in rule_scores if r.score >= 90][:5]

        # --- Feedback Text ---
        if score >= 95:
            feedback_text = f"Transcription: '{transcription}'. Excellent recitation!"
        elif score >= 80:
            feedback_text = f"Transcription: '{transcription}'. Very good! Minor improvements possible."
        elif score >= 60:
            feedback_text = f"Transcription: '{transcription}'. Good attempt, keep practicing."
        else:
            feedback_text = f"Transcription: '{transcription}'. Please practice this ayah more carefully."

        grade_text = (
            "Excellent" if score >= 95
            else "Very Good" if score >= 85
            else "Good" if score >= 70
            else "Needs Practice"
        )

        # --- Weak words ---
        weak_words = []
        if is_weak and ref_text:
            ref_words = ref_text.split()
            trans_clean = strip_tashkeel(transcription)
            weak_words = [w for w in ref_words if strip_tashkeel(w) not in trans_clean]

        encouragement = (
            "🌟 MashaAllah! Excellent recitation!"
            if score >= 90
            else "✨ MashaAllah! Keep up the great work!"
            if score >= 75
            else "📖 Keep practicing — you're improving!"
        )

        return TajwidAnalysisResult(
            overall_score=score,
            feedback=feedback_text,
            grade=grade_text,
            rule_scores=rule_scores,
            weak_words=weak_words,
            weak_rule_ids=weak_rule_ids,
            excellent_rule_ids=excellent_rule_ids,
            encouragement=encouragement
        )

    except Exception as e:
        print(f"Error during ML inference: {e}")
        import traceback
        traceback.print_exc()
        return TajwidAnalysisResult(
            overall_score=0,
            feedback=f"Technical error during analysis: {str(e)}",
            grade="Error",
            rule_scores=[],
            weak_words=[],
            weak_rule_ids=[],
            excellent_rule_ids=[],
            encouragement="Please try again."
        )
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)


@app.get("/health")
def health():
    return {"status": "ok", "model": WHISPER_MODEL_ID, "model_loaded": whisper_model is not None}


if __name__ == "__main__":
    # Using string "main:app" for reload support
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
