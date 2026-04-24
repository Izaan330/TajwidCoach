import sqlite3
import os
import json
import urllib.request
import re

db_path = os.path.join('assets', 'databases', 'quran.db')

def fetch_json(url):
    print(f"Fetching {url}...")
    headers = {'User-Agent': 'Mozilla/5.0'}
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req) as response:
        return json.load(response)

def strip_bismillah(text):
    # Expanded patterns to handle high-fidelity Indo-Pak marks
    patterns = [
        r"^بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\s*", 
        r"^بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\s*",
        r"^بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ\s*",
        r"^بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\s*",
        r"^بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ\s*",
        r"^بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\s*"
    ]
    for p in patterns:
        if re.match(p, text):
            return re.sub(p, "", text).strip()
            
    # Fallback for complex markers
    for marker in ["ٱلرَّحِيمِ", "الرَّحِيمِ", "الرَّحِيْمِ"]:
        if marker in text:
            parts = text.split(marker, 1)
            if len(parts) > 1:
                return parts[1].strip()
    return text.strip()

def main():
    if os.path.exists(db_path):
        os.remove(db_path)
    os.makedirs(os.path.dirname(db_path), exist_ok=True)

    # Fetch data
    arabic_data = fetch_json('https://api.alquran.cloud/v1/quran/quran-uthmani')
    english_data = fetch_json('https://api.alquran.cloud/v1/quran/en.sahih')
    
    # Fetch high-fidelity Indo-Pak from Quran.com
    indopak_api_data = fetch_json('https://api.quran.com/api/v4/quran/verses/indopak')
    indopak_verses = indopak_api_data['verses']

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE ayats (
            id INTEGER PRIMARY KEY,
            sura INTEGER,
            aya INTEGER,
            global_number INTEGER,
            text TEXT,
            indopak_text TEXT,
            translation TEXT,
            juez INTEGER,
            page INTEGER
        )
    ''')

    arabic_surahs = arabic_data['data']['surahs']
    english_surahs = english_data['data']['surahs']

    # Map quran.com verses by verse_key (e.g. "1:1")
    indopak_map = {v['verse_key']: v['text_indopak'] for v in indopak_verses}

    ayah_count = 0
    for s_idx, s_data in enumerate(arabic_surahs):
        surah_num = s_data['number']
        ayahs = s_data['ayahs']
        trans_ayahs = english_surahs[s_idx]['ayahs']
        print(f"Processing Surah {surah_num} ({s_data['englishName']})...")
        for a_idx, a_data in enumerate(ayahs):
            aya_num = a_data['numberInSurah']
            global_num = a_data['number']
            text = a_data['text']
            
            verse_key = f"{surah_num}:{aya_num}"
            indopak_text = indopak_map.get(verse_key, "")
            
            translation = trans_ayahs[a_idx]['text']
            juz = a_data['juz']
            page = a_data['page']

            if aya_num == 1 and surah_num != 1:
                text = strip_bismillah(text)
                indopak_text = strip_bismillah(indopak_text)
            
            # Special Handling for Surah Al-Fatihah (Surah 1) Numbering Shift
            # Standard South Asian / Indo-Pak preference: 
            # 1. Alhamdulillah ..., 6. Siratal ... An'amta alaihim, 7. Ghayril ... Walad dalleen
            if surah_num == 1:
                if aya_num == 1:
                    # Ayah 1 should be the API's Ayah 2 (Alhamdulillah)
                    text = ayahs[1]['text']
                    indopak_text = indopak_map.get("1:2", "")
                elif aya_num == 2:
                    text = ayahs[2]['text']
                    indopak_text = indopak_map.get("1:3", "")
                elif aya_num == 3:
                    text = ayahs[3]['text']
                    indopak_text = indopak_map.get("1:4", "")
                elif aya_num == 4:
                    text = ayahs[4]['text']
                    indopak_text = indopak_map.get("1:5", "")
                elif aya_num == 5:
                    text = ayahs[5]['text']
                    indopak_text = indopak_map.get("1:6", "")
                elif aya_num == 6:
                    # Ayah 6 is the FIRST half of API's Ayah 7
                    raw_7_uthmani = ayahs[6]['text']
                    raw_7_indopak = indopak_map.get("1:7", "")
                    
                    # Robust diacritic-agnostic search for "An'amta 'alayhim"
                    # Matches base letters with any number of optional diacritics in between
                    def find_split_point(text, base_words):
                        # Construct a pattern that matches the words with optional diacritics
                        # \u064b-\u065f are standard diacritics, \u0670 is superscript alif, \u06e0-\u06ed are small signs
                        diacritics = r"[\u0600-\u061f\u064b-\u065f\u0670\u06d6-\u06ed]*"
                        pattern = ""
                        for word in base_words:
                            for char in word:
                                pattern += re.escape(char) + diacritics
                            pattern += r"\s+"
                        pattern = pattern.strip()
                        match = re.search(pattern, text)
                        return match.end() if match else -1

                    u_split = find_split_point(raw_7_uthmani, ["أنعمت", "عليهم"])
                    if u_split != -1:
                        text = raw_7_uthmani[:u_split].strip()
                    else:
                        text = raw_7_uthmani
                        
                    i_split = find_split_point(raw_7_indopak, ["انعمت", "عليهم"])
                    if i_split != -1:
                        indopak_text = raw_7_indopak[:i_split].strip() + " ۙ‏"
                    else:
                        indopak_text = raw_7_indopak
                elif aya_num == 7:
                    # Ayah 7 is the SECOND half of API's Ayah 7
                    raw_7_uthmani = ayahs[6]['text']
                    raw_7_indopak = indopak_map.get("1:7", "")
                    
                    def find_split_point(text, base_words):
                        diacritics = r"[\u064b-\u065f\u0670\u06d6-\u06ed]*"
                        pattern = ""
                        for word in base_words:
                            for char in word:
                                pattern += re.escape(char) + diacritics
                            pattern += r"\s+"
                        pattern = pattern.strip()
                        match = re.search(pattern, text)
                        return match.end() if match else -1

                    u_split = find_split_point(raw_7_uthmani, ["أنعمت", "عليهم"])
                    if u_split != -1:
                        text = raw_7_uthmani[u_split:].strip()
                    else:
                        text = ""
                        
                    i_split = find_split_point(raw_7_indopak, ["انعمت", "عليهم"])
                    if i_split != -1:
                        rest = raw_7_indopak[i_split:].strip()
                        indopak_text = re.sub(r"^[ۙ\s]+", "", rest)
                    else:
                        indopak_text = ""

            cursor.execute('''
                INSERT INTO ayats (sura, aya, global_number, text, indopak_text, translation, juez, page)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (surah_num, aya_num, global_num, text, indopak_text, translation, juz, page))
            ayah_count += 1

    conn.commit()
    conn.close()
    print(f"\nDone! Successfully imported {ayah_count} Ayahs into {db_path}")

if __name__ == "__main__":
    main()
