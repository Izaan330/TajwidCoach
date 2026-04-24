import 'package:flutter/material.dart';
import '../models/tajwid_rule_model.dart';

/// Defines all Tajweed rules with their colors (based on the international standard
/// used by iQuran and similar apps).
class TajweedRules {
  static const List<TajwidRule> all = [
    TajwidRule(
      id: 'ghunnah',
      name: 'Ghunnah',
      arabicName: 'غنة',
      description: 'Nasal sound held for 2 counts on doubled Noon or Meem.',
      colorHex: '#36B552', // Quran.com Green (Exact)
      backgroundHex: '#E8F5E9',
      category: 'Nasal',
      subTypes: ['Mushaddad Noon', 'Mushaddad Meem'],
      exampleWord: 'إِنَّ',
    ),
    TajwidRule(
      id: 'idgham_ghunnah',
      name: 'Idgham with Ghunnah',
      arabicName: 'إدغام بغنة',
      description: 'Merging Noon Sakinah or Tanween into ي,ن,م,و with nasal sound.',
      colorHex: '#36B552', // Quran.com Green (Exact)
      backgroundHex: '#E8F5E9',
      category: 'Nun Rules',
      subTypes: ['Yaa', 'Noon', 'Meem', 'Waw'],
      exampleWord: 'مَنْ يَقُولُ',
    ),
    TajwidRule(
      id: 'idgham_no_ghunnah',
      name: 'Idgham without Ghunnah',
      arabicName: 'إدغام بلا غنة',
      description: 'Merging Noon Sakinah or Tanween into ل or ر without nasalization.',
      colorHex: '#AAAAAA', // Quran.com Gray (Exact)
      backgroundHex: '#F5F5F5',
      category: 'Nun Rules',
      subTypes: ['Lam', 'Ra'],
      exampleWord: 'مِنْ رَبِّهِمْ',
    ),
    TajwidRule(
      id: 'ikhfa',
      name: 'Ikhfa',
      arabicName: 'إخفاء',
      description: 'Partial concealment of Noon Sakinah or Tanween before 15 letters.',
      colorHex: '#36B552', // Quran.com Green (Exact)
      backgroundHex: '#E8F5E9',
      category: 'Nun Rules',
      subTypes: [],
      exampleWord: 'مَنْ كَفَرَ',
    ),
    TajwidRule(
      id: 'iqlab',
      name: 'Iqlab',
      arabicName: 'إقلاب',
      description: 'Converting Noon Sakinah or Tanween into Meem before Baa.',
      colorHex: '#36B552', // Quran.com Green (Exact)
      backgroundHex: '#E8F5E9',
      category: 'Nun Rules',
      subTypes: [],
      exampleWord: 'أَنْبِيَاءَ',
    ),
    TajwidRule(
      id: 'izhar',
      name: 'Izhar',
      arabicName: 'إظهار',
      description: 'Clear pronunciation of Noon Sakinah or Tanween before throat letters.',
      colorHex: '#000000', // Clear (Black)
      backgroundHex: '#FFFFFF',
      category: 'Nun Rules',
      subTypes: [],
      exampleWord: 'مَنْ أَرَادَ',
    ),
    TajwidRule(
      id: 'qalqalah',
      name: 'Qalqalah',
      arabicName: 'قلقلة',
      description: 'Echoing bounce on letters ق ط ب ج د when they are Sakin.',
      colorHex: '#00AFEB', // Quran.com Light Blue (Exact)
      backgroundHex: '#E1F5FE',
      category: 'Articulation',
      subTypes: ['Sughra (minor)', 'Kubra (major)'],
      exampleWord: 'أَحَطتُّ',
    ),
    TajwidRule(
      id: 'madd_natural',
      name: 'Natural Madd',
      arabicName: 'مد طبيعي',
      description: 'Elongation of ا,و,ي for 2 counts when unaffected by Hamza or Sukoon.',
      colorHex: '#BF9B30', // Quran.com Gold (Exact)
      backgroundHex: '#FFF8E1',
      category: 'Prolongation',
      subTypes: [],
      exampleWord: 'قَالَ',
    ),
    TajwidRule(
      id: 'madd_wajib',
      name: 'Madd Wajib Muttasil',
      arabicName: 'مد واجب متصل',
      description: 'Obligatory elongation for 4-5 counts when a Madd letter is followed by a Hamza in the same word.',
      colorHex: '#FF4040', // Quran.com Light Red (Exact)
      backgroundHex: '#FFEBEE',
      category: 'Prolongation',
      subTypes: [],
      exampleWord: 'جَاءَ',
    ),
    TajwidRule(
      id: 'madd_jaiz',
      name: 'Madd Jaiz Munfasil',
      arabicName: 'مد جائز منفصل',
      description: 'Permissible elongation of 4-5 counts when Madd letter and Hamza are in separate words.',
      colorHex: '#FF841A', // Quran.com Orange (Exact)
      backgroundHex: '#FFF3E0',
      category: 'Prolongation',
      subTypes: [],
      exampleWord: 'إِنَّا أَعْطَيْنَاكَ',
    ),
    TajwidRule(
      id: 'madd_long',
      name: 'Long Madd',
      arabicName: 'مد طويل',
      description: 'Longer elongation (4-6 counts) indicated by the wavy Maddah sign.',
      colorHex: '#D1000B', // Quran.com Dark Red (Exact)
      backgroundHex: '#FFEBEE',
      category: 'Prolongation',
      subTypes: [],
      exampleWord: 'السَّمَاءِ',
    ),
    TajwidRule(
      id: 'stop_sign',
      name: 'Stop Sign',
      arabicName: 'علامات الوقف',
      description: 'Small signs indicating whether to stop or continue reading.',
      colorHex: '#757575',
      backgroundHex: '#F5F5F5',
      category: 'Pausing',
      subTypes: [],
      exampleWord: 'ط',
    ),
    TajwidRule(
      id: 'sajdah',
      name: 'Sajdah',
      arabicName: 'سجدة',
      description: 'Point of prostration.',
      colorHex: '#D32F2F',
      backgroundHex: '#FFEBEE',
      category: 'Special',
      subTypes: [],
      exampleWord: '۩',
    ),
    TajwidRule(
      id: 'lam_shamsiyya',
      name: 'Shamsiyya (Sun Letter)',
      arabicName: 'لام شمسية',
      description: 'The definite article ال where the Lam is assimilated into the following letter.',
      colorHex: '#AAAAAA', // Quran.com Gray (Exact)
      backgroundHex: '#F5F5F5',
      category: 'Lam Rules',
      subTypes: [],
      exampleWord: 'الشَّمْسُ',
    ),
    TajwidRule(
      id: 'lam_qamariyya',
      name: 'Qamariyya (Moon Letter)',
      arabicName: 'لام قمرية',
      description: 'The definite article ال where the Lam is pronounced clearly.',
      colorHex: '#000000', // Clear (Black)
      backgroundHex: '#FFFFFF',
      category: 'Lam Rules',
      subTypes: [],
      exampleWord: 'الْقَمَرُ',
    ),
  ];

  static TajwidRule? findById(String id) {
    try {
      return all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  static Color colorFromHex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

/// Represents a span of text with an optional Tajweed rule
class TajweedSpan {
  final String text;
  final TajwidRule? rule; // null = normal text

  const TajweedSpan({required this.text, this.rule});
}

/// Lightweight Tajweed engine that applies Unicode regex-based pattern matching
/// to identify Tajweed positions in Arabic text.
class TajweedEngine {
  // Letters that trigger Qalqalah when Sakin
  static const String _qalqalahLetters = 'قطبجد';

  // Noon Sakinah / Tanween followed by Ikhfa letters
  static const String _ikhfaLetters = 'تثجدذزسشصضطظفقك';

  // Sun letters (shamsiyya) – the Lam of ال is assimilated
  static const String _sunLetters = 'تثدذرزسشصضطظلن';

  // Idgham and Izhar letters
  static const String _idghamGhunnahLetters = 'ينمو';
  static const String _idghamNoGhunnahLetters = 'لر';
  static const String _izharLetters = 'ءهعحغخ';
  
  // Stop signs range
  // Stop signs range
  static const String _stopSignsRange = r'[\u06D6-\u06ED]';
  // Maddah wave
  static const String _maddahChar = '\u0653';
  // Sajdah marker
  static const String _sajdahChar = '\u06e9';
  static const String _sajdahWord = '۩';
  static const String _zwj = '\u200D';

  /// Annotate Arabic text with Tajweed spans for rendering without breaking diacritics
  static List<TajweedSpan> annotate(String arabicText) {
    if (arabicText.isEmpty) return [TajweedSpan(text: arabicText)];

    final List<TajweedSpan> spans = [];
    final chars = arabicText.runes.map((r) => String.fromCharCode(r)).toList();
    StringBuffer buffer = StringBuffer();
    
    int i = 0;
    while (i < chars.length) {
      final char = chars[i];
      
      // Fast check for Sajdah Word ۩
      if (char == _sajdahWord) {
        _flush(buffer, spans);
        spans.add(TajweedSpan(
          text: char,
          rule: TajweedRules.findById('sajdah'),
        ));
        i++;
        continue;
      }
      
      // NEW: Bypass for the word "Allah" and "Lillah" to protect ligatures
      final allahEnd = _checkAllahBypass(chars, i);
      if (allahEnd > i) {
        buffer.write(chars.sublist(i, allahEnd).join());
        i = allahEnd;
        continue;
      }
      
      // Fast check for Ghunnah (نّ or مّ)
      if (char == 'ن' || char == 'م') {
        int end = _consumeCombiningMarks(chars, i);
        String cluster = chars.sublist(i, end).join();
        if (cluster.contains('\u0651')) {
          _flush(buffer, spans);
          spans.add(TajweedSpan(
            text: cluster,
            rule: TajweedRules.findById('ghunnah'),
          ));
          i = end;
          continue;
        }
      }

      // Fast check for Qalqalah (قطبجد followed by Sukoon)
      if (_qalqalahLetters.contains(char)) {
        int end = _consumeCombiningMarks(chars, i);
        String cluster = chars.sublist(i, end).join();
        if (cluster.contains('\u0652')) {
          _flush(buffer, spans);
          spans.add(TajweedSpan(
            text: cluster,
            rule: TajweedRules.findById('qalqalah'),
          ));
          i = end;
          continue;
        }
      }

      // Check Ikhfa / Idgham / Izhar for Noon Sakinah or Tanween
      // Patterns: 
      // 1. Noon + (Sukoon or no marks)
      // 2. Tanween (ً ٌ ٍ)
      bool isNoon = char == 'ن';
      bool isTanween = '\u064b\u064c\u064d'.contains(char);

      if (isNoon || isTanween) {
        int endCluster = _consumeCombiningMarks(chars, i);
        String cluster = chars.sublist(i, endCluster).join();
        
        // Ensure Noon is Sakin (either has Sukoon \u0652 or no marks at all)
        bool isValidNoon = false;
        if (isNoon) {
          // If Noon is followed by a Vowel/Shadda, it's not Sakin
          if (!RegExp(r'[\u064e\u064f\u0650\u0651]').hasMatch(cluster)) {
            isValidNoon = true;
          }
        }

        if (isValidNoon || isTanween) {
          int j = endCluster;
          while (j < chars.length && chars[j] == ' ') {
            j++; // skip spaces
          }
          
          if (j < chars.length) {
            String nextChar = chars[j];
            String? ruleId;

            if (nextChar == 'ب') {
              ruleId = 'iqlab';
            } else if (_idghamGhunnahLetters.contains(nextChar)) {
              ruleId = 'idgham_ghunnah';
            } else if (_idghamNoGhunnahLetters.contains(nextChar)) {
              ruleId = 'idgham_no_ghunnah';
            } else if (_ikhfaLetters.contains(nextChar)) {
              ruleId = 'ikhfa';
            } else if (_izharLetters.contains(nextChar)) {
              ruleId = 'izhar';
            }

            if (ruleId != null) {
              _flush(buffer, spans);
              spans.add(TajweedSpan(
                text: cluster,
                rule: TajweedRules.findById(ruleId),
              ));
              i = endCluster;
              continue;
            }
          }
        }
      }

      // Check Shamsiyya/Qamariyya (ال) - Only at start of word
      if (char == 'ا' && (i == 0 || chars[i - 1] == ' ')) {
        int endA = _consumeCombiningMarks(chars, i);
        if (endA < chars.length && chars[endA] == 'ل') {
          int endL = _consumeCombiningMarks(chars, endA);
          if (endL < chars.length) {
            String nextChar = chars[endL];
            // Identify sun/moon letters
            if (_sunLetters.contains(nextChar)) {
              _flush(buffer, spans);
              spans.add(TajweedSpan(
                text: chars.sublist(i, endL).join(),
                rule: TajweedRules.findById('lam_shamsiyya'),
              ));
              i = endL;
              continue;
            } else if (!' \u064b\u064c\u064d\u064e\u064f\u0650\u0651\u0652'.contains(nextChar)) {
              _flush(buffer, spans);
              spans.add(TajweedSpan(
                text: chars.sublist(i, endL).join(),
                rule: TajweedRules.findById('lam_qamariyya'),
              ));
              i = endL;
              continue;
            }
          }
        }
      }

      // Natural Madd: In Flutter, placing the Harakat in a different span from its 
      // base consonant breaks rendering (harakat floats or goes missing).
      // So instead of highlighting the fatha+alif, we highlight the entire consonant+marks+alif cluster.
      if (char == 'ا' || char == 'و' || char == 'ي') {
        // Did the buffer have a consonant ending with the matching harakat?
        if (buffer.isNotEmpty) {
          final bufferStr = buffer.toString();
          // Extract the last base consonant cluster from the buffer using regex
          final clusterMatch = RegExp(r'([^ ]+[\u064e\u064f\u0650\u0651\u0670\u06D6-\u06ED]+)$').firstMatch(bufferStr);
          if (clusterMatch != null) {
            final cluster = clusterMatch.group(1)!;
            final isMaddA = char == 'ا' && cluster.contains('\u064e');
            final isMaddW = char == 'و' && cluster.contains('\u064f');
            final isMaddY = char == 'ي' && cluster.contains('\u0650');

            if (isMaddA || isMaddW || isMaddY) {
              int end = _consumeCombiningMarks(chars, i);
              String marksOnMadd = chars.sublist(i + 1, end).join();
              
              // If the madd letter has its own Harakat (Fatha, Damma, Kasra, Tanween),
              // it's acting as a consonant, not a madd letter.
              if (RegExp(r'[\u064B-\u0650]').hasMatch(marksOnMadd)) {
                // Not a madd, just a consonant with a vowel
              } else {
                final newBuffer = bufferStr.substring(0, bufferStr.length - cluster.length);
                buffer.clear();
                if (newBuffer.isNotEmpty) buffer.write(newBuffer);
                _flush(buffer, spans);

                spans.add(TajweedSpan(
                  text: cluster + chars.sublist(i, end).join(),
                  rule: TajweedRules.findById('madd_natural'),
                ));
                i = end;
                continue;
              }
            }
          }
        }
      }

      // Check for Maddah (Long Madd) wave above
      int endAllMarks = _consumeCombiningMarks(chars, i);
      String allMarks = chars.sublist(i + 1, endAllMarks).join();
      if (allMarks.contains(_maddahChar)) {
        _flush(buffer, spans);
        spans.add(TajweedSpan(
          text: chars.sublist(i, endAllMarks).join(),
          rule: TajweedRules.findById('madd_long'),
        ));
        i = endAllMarks;
        continue;
      }

      // Check for standalone Stop Signs
      if (RegExp(_stopSignsRange).hasMatch(char)) {
        String? ruleId;
        if (char == _sajdahChar) {
          ruleId = 'sajdah';
        } else {
          ruleId = 'stop_sign';
        }
        
        _flush(buffer, spans);
        spans.add(TajweedSpan(
          text: char,
          rule: TajweedRules.findById(ruleId),
        ));
        i++;
        continue;
      }

      // Default: add base letter and ALL its following diacritics to buffer together
      int endMarks = _consumeCombiningMarks(chars, i);
      buffer.write(chars.sublist(i, endMarks).join());
      i = endMarks;
    }

    _flush(buffer, spans);
    
    // NEW: Post-process spans to ensure ligatures are maintained across color boundaries
    // In Flutter RichText, if a span ends with a joining character, we can add a ZWJ
    return _applyLigatureJoining(spans);
  }

  /// Post-process spans to ensure Arabic shaping is maintained across RichText spans 
  /// by strategically inserting Zero Width Joiners (ZWJ) if a span ends/starts in a word.
  static List<TajweedSpan> _applyLigatureJoining(List<TajweedSpan> spans) {
    if (spans.length <= 1) return spans;
    
    final List<TajweedSpan> joined = [];
    // Characters that do NOT connect to the next character (to their left in memory)
    const String nonLeftJoiners = 'ادرذزو\u0621\u0622\u0623\u0624\u0625\u0671'; 

    for (int i = 0; i < spans.length; i++) {
      String text = spans[i].text;
      String current = text;
      
      // 1. If this is not the first span, does it connect to the PREVIOUS span?
      if (i > 0) {
        final prevLastChar = spans[i - 1].text.characters.last;
        final currentFirstChar = text.characters.first;
        
        // If previous ends with joiner and current starts with joiner, add ZWJ to start
        if (!nonLeftJoiners.contains(prevLastChar) && _isArabicLetter(currentFirstChar)) {
          current = _zwj + current;
        }
      }
      
      // 2. If this is not the last span, does it connect to the NEXT span?
      if (i < spans.length - 1) {
        final currentLastChar = text.characters.last;
        final nextFirstChar = spans[i + 1].text.characters.first;
        
        // If current ends with joiner and next starts with joiner, add ZWJ to end
        if (!nonLeftJoiners.contains(currentLastChar) && _isArabicLetter(nextFirstChar)) {
          current = current + _zwj;
        }
      }

      joined.add(TajweedSpan(text: current, rule: spans[i].rule));
    }
    return joined;
  }

  static bool _isArabicLetter(String c) {
    int code = c.runes.first;
    return (code >= 0x0621 && code <= 0x064A) || (code >= 0x066E && code <= 0x06D5);
  }

  /// Helper to consume all Arabic combining marks following a base character.
  /// Returns the index of the next NON-combining character.
  static int _consumeCombiningMarks(List<String> chars, int startIndex) {
    int idx = startIndex + 1; // Start checking character *after* the base one
    while (idx < chars.length) {
      final c = chars[idx];
      // Arabic Harakat and Quranic marks range
      if (RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u08F0-\u08FF]').hasMatch(c)) {
        idx++;
      } else {
        break;
      }
    }
    return idx;
  }

  /// Detects if the current position is the start of the word "Allah" or "Lillah".
  /// Returns the end index of the word if found, otherwise returns -1.
  static int _checkAllahBypass(List<String> chars, int startIndex) {
    // We look for: (Alef/Wasla)? + Lam + Lam + Heh
    // with any number of combining marks in between.
    
    int i = startIndex;
    String firstChar = chars[i];
    bool startsWithAlef = (firstChar == 'ا' || firstChar == '\u0671');
    bool startsWithLam = (firstChar == 'ل');
    
    if (!startsWithAlef && !startsWithLam) return -1;
    
    int current = i;
    
    // 1. Skip Alef/Wasla if present
    if (startsWithAlef) {
      current = _consumeCombiningMarks(chars, current);
      if (current >= chars.length || chars[current] != 'ل') return -1;
    }
    
    // 2. First Lam
    if (chars[current] == 'ل') {
      current = _consumeCombiningMarks(chars, current);
    } else {
      return -1;
    }
    
    // 3. Second Lam
    if (current < chars.length && chars[current] == 'ل') {
      current = _consumeCombiningMarks(chars, current);
    } else {
      return -1;
    }
    
    // 4. Heh
    if (current < chars.length && chars[current] == 'ه') {
      current = _consumeCombiningMarks(chars, current);
      // We found it!
      return current;
    }
    
    return -1;
  }

  static void _flush(StringBuffer buffer, List<TajweedSpan> spans) {
    if (buffer.isNotEmpty) {
      spans.add(TajweedSpan(text: buffer.toString()));
      buffer.clear();
    }
  }
}
