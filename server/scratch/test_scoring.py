import difflib
import re

def strip_tashkeel(text: str) -> str:
    """Remove Arabic diacritics (tashkeel) and normalize for lenient comparison."""
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
    
    return text

def calculate_score(reference: str, hypothesis: str) -> int:
    if not hypothesis.strip():
        return 0

    ref_clean = strip_tashkeel(reference).split()
    hyp_clean = strip_tashkeel(hypothesis).split()

    print(f"Ref clean: {ref_clean}")
    print(f"Hyp clean: {hyp_clean}")

    if not ref_clean:
        return 0

    matcher = difflib.SequenceMatcher(None, ref_clean, hyp_clean)
    accuracy = matcher.ratio() * 100
    
    return int(min(accuracy, 100))

# Test Alif Lam Mim vs Alif Lam Ra
ref = "الم"
hyp = "الر"
score = calculate_score(ref, hyp)
print(f"Score for {ref} vs {hyp}: {score}%")

# Test with various common symbols
ref2 = "الٓمٓ"
hyp2 = "الٓرٓ"
score2 = calculate_score(ref2, hyp2)
print(f"Score for {ref2} vs {hyp2}: {score2}%")
