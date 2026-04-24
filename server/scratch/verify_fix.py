import sys
import os

# Add parent dir to path to import from main
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from main import strip_tashkeel, calculate_score

def test_normalization():
    print("Testing Text Normalization...")
    
    # Test 1: Arabic diacritics
    text1 = "بِسْمِ اللَّهِ"
    norm1 = strip_tashkeel(text1)
    print(f"Original: {text1} -> Normalized: {norm1}")
    assert norm1 == "بسم الله", f"Expected 'بسم الله', got '{norm1}'"
    
    # Test 2: Buckwalter/Latin characters leak
    text2 = "بسم الله >ls/lAmm"
    norm2 = strip_tashkeel(text2)
    print(f"Original: {text2} -> Normalized: {norm2}")
    assert norm2 == "بسم الله ", f"Expected 'بسم الله ', got '{norm2}'"
    
    # Test 3: Mixed characters (including digits)
    text3 = "الحمد لله abc 123"
    norm3 = strip_tashkeel(text3)
    print(f"Original: {text3} -> Normalized: {norm3}")
    assert norm3 == "الحمد لله  ", f"Expected 'الحمد لله  ', got '{norm3}'"
    
    print("Normalization tests passed!\n")

def test_scoring():
    print("Testing Scoring Logic...")
    
    ref = "الم"
    hyp_correct = "الم"
    hyp_wrong = "الر" # A common mistake the literal model should catch
    
    score_perfect = calculate_score(ref, hyp_correct)
    score_wrong = calculate_score(ref, hyp_wrong)
    
    print(f"Reference: {ref}")
    print(f"Correct Hypothesis: {hyp_correct} -> Score: {score_perfect}")
    print(f"Wrong Hypothesis: {hyp_wrong} -> Score: {score_wrong}")
    
    assert score_perfect == 100
    assert score_wrong < 50 # SequenceMatcher for 2/3 characters is 0.66, but minus penalty for wrong letters?
    # Wait, SequenceMatcher for 'الم' and 'الر' is 0.66.
    # calculate_score uses min(word_accuracy, char_accuracy)
    # word_accuracy: Match 'الم' with 'الر' is 0 (one word different).
    # char_accuracy: 0.66.
    # Result: 0.
    
    print("Scoring tests passed!\n")

if __name__ == "__main__":
    try:
        test_normalization()
        test_scoring()
        print("All verification tests passed!")
    except AssertionError as e:
        print(f"Verification FAILED: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"An error occurred: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
