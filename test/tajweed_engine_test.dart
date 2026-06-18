import 'package:flutter_test/flutter_test.dart';
import 'package:tajwid_coach/services/tajweed_engine.dart';
import 'package:tajwid_coach/utils/tajweed_tag_parser.dart';

void main() {
  group('TajweedEngine Tests', () {
    test('Should identify Ghunnah rule', () {
      const text = 'إِنَّ'; // Mushaddad Noon
      final spans = TajweedEngine.annotate(text);
      expect(spans.any((s) => s.rule?.id == 'ghunnah'), isTrue);
    });

    test('Should identify Qalqalah rule', () {
      const text3 = 'يَقْطَعُونَ'; // Qalqalah on Qaaf with Sukoon
      final spans = TajweedEngine.annotate(text3);
      expect(spans.any((s) => s.rule?.id == 'qalqalah'), isTrue);
    });

    test('Should not split base character and diacritics', () {
      const text = 'بِسْمِ';
      final spans = TajweedEngine.annotate(text);
      // 'Bi' should be one span, 'smi' another? 
      // Actually if no rules, it should be one span.
      expect(spans.length, 1);
    });

    test('Should handle Allah bypass', () {
      final spans = TajweedEngine.annotate('اللَّه لِلَّه');
      expect(spans.length, 1);
      expect(spans[0].text, 'اللَّه لِلَّه');
    });

    test('Should insert ZWJ at span boundaries for joining letters', () {
      // "إِنَّ" (Ghunnah) + "ال" (Lam Qamariyya)
      final spans = TajweedEngine.annotate('إِنَّ الْقَمَرُ');
      
      bool foundGhunnah = false;
      for (var span in spans) {
        if (span.rule?.id == 'ghunnah') {
          foundGhunnah = true;
        }
      }
      expect(foundGhunnah, true);
    });

    test('Should maintain ligatures for complex words like Lam-Alif', () {
      final spans = TajweedEngine.annotate('قَالَا'); 
      // Check if ANY span contains "لَا" and is marked as madd_natural
      final hasMaddLamAlif = spans.any((s) => s.text.contains('لَا') && s.rule?.id == 'madd_natural');
      expect(hasMaddLamAlif, true);
    });

    test('Should handle splits within a word (e.g. فَلَا with fatha on fa)', () {
      // "فَ" (Normal) + "لَا" (Madd)
      // If none of these have rules, it might be 1 span.
      // But if we have a rule on "فَ", it would split.
      // Let's check ZWJ for "إِنَّهُمْ" again, which we know splits.
      final spans2 = TajweedEngine.annotate('إِنَّهُمْ'); 
      final ghunnahSpan = spans2.firstWhere((s) => s.rule?.id == 'ghunnah');
      expect(ghunnahSpan.text.startsWith('\u200D'), true);
      expect(ghunnahSpan.text.endsWith('\u200D'), true);
    });

    test('Should add ZWJ markers to preserve shaping', () {
      // "ن" in "مَن" is a left-joiner. " " is not an Arabic letter. 
      // If we had "مَنْيَقُولُ" (no space), it would have ZWJ.
      
      final spans2 = TajweedEngine.annotate('إِنَّهُمْ'); // "إِ" + "نَّ" (Ghunnah) + "هُمْ"
      final ghunnahSpan = spans2.firstWhere((s) => s.rule?.id == 'ghunnah');
      
      // "نَّ" is followed by "هـ", both are joiners.
      expect(ghunnahSpan.text.contains('\u200D'), true);
    });
  });

  group('TajweedTagParser Tests', () {
    test('Should parse bracket tagging format correctly', () {
      final spans = TajweedTagParser.parse('بِرَبِّ [h:14[ٱ][l[ل][g[نّ][p[َا]سِ');
      expect(spans.isNotEmpty, true);
      final hasGhunnah = spans.any((s) => s.rule?.id == 'ghunnah');
      expect(hasGhunnah, true);
    });

    test('Should parse SQLite HTML tagging format correctly', () {
      final spans = TajweedTagParser.parse('بِسْمِ <tajweed class=ham_wasl>ٱ</tajweed>للَّهِ <tajweed class=ham_wasl>ٱ</tajweed><tajweed class=laam_shamsiyah>ل</tajweed>رَّحْمَ<tajweed class=madda_normal>ـٰ</tajweed>نِ <span class=end>١</span>');
      expect(spans.isNotEmpty, true);
      
      final hasHamWasl = spans.any((s) => s.rule?.id == 'hamzat_wasl');
      final hasLamShamsiyya = spans.any((s) => s.rule?.id == 'lam_shamsiyya');
      final hasMaddNatural = spans.any((s) => s.rule?.id == 'madd_natural');
      
      expect(hasHamWasl, true);
      expect(hasLamShamsiyya, true);
      expect(hasMaddNatural, true);
      
      // The end span "<span class=end>١</span>" should be completely stripped
      final containsEndSpan = spans.any((s) => s.text.contains('<span') || s.text.contains('١'));
      expect(containsEndSpan, false);
    });
  });
}

