import '../services/tajweed_engine.dart';

/// Parses tagging formats into TajweedSpans.
/// Supports both Al-Quran.cloud's bracket [h:ID[text]] format and SQLite's HTML <tajweed class=ID>text</tajweed> format.
class TajweedTagParser {
  /// Maps Al-Quran.cloud rule identifiers to our TajweedRule IDs.
  static final Map<String, String> _tagToRuleId = {
    'h': 'hamzat_wasl',
    's': 'silent',
    'l': 'lam_shamsiyya',
    'n': 'madd_natural',
    'p': 'madd_jaiz',
    'm': 'madd_long',
    'o': 'madd_wajib',
    'q': 'qalqalah',
    'c': 'ikhfa_shafawi',
    'f': 'ikhfa',
    'w': 'idgham_shafawi',
    'i': 'iqlab',
    'a': 'idgham_ghunnah',
    'u': 'idgham_no_ghunnah',
    'g': 'ghunnah',
  };

  /// Maps SQLite HTML class names to our TajweedRule IDs.
  static String _mapClassToRuleId(String className) {
    switch (className.toLowerCase()) {
      case 'ham_wasl':
        return 'hamzat_wasl';
      case 'laam_shamsiyah':
        return 'lam_shamsiyya';
      case 'laam_qamariyah':
        return 'lam_qamariyya';
      case 'qalaqah':
        return 'qalqalah';
      case 'madda_obligatory':
        return 'madd_wajib';
      case 'madda_necessary':
        return 'madd_long';
      case 'madda_permissible':
        return 'madd_jaiz';
      case 'madda_normal':
        return 'madd_natural';
      case 'idgham_wo_ghunnah':
        return 'idgham_no_ghunnah';
      case 'idgham_ghunnah':
        return 'idgham_ghunnah';
      case 'idgham_shafawi':
        return 'idgham_mimi';
      case 'ikhafa_shafawi':
        return 'ikhfa_shafawi';
      case 'ikhafa':
        return 'ikhfa';
      case 'ghunnah':
        return 'ghunnah';
      case 'iqlab':
        return 'iqlab';
      case 'slnt':
        return 'silent';
      case 'idgham_mutaqaribayn':
      case 'idgham_mutajanisayn':
        return 'idgham';
      default:
        return className;
    }
  }

  /// Parses a tagged string into TajweedSpans.
  static List<TajweedSpan> parse(String taggedText) {
    // 1. Check for HTML tag format (<tajweed class=...>)
    if (taggedText.contains('<tajweed')) {
      // Remove end spans first (e.g. <span class=end>١</span>)
      String cleanText = taggedText.replaceAll(RegExp(r'<span[^>]*>.*?</span>'), '');
      
      final List<TajweedSpan> spans = [];
      final RegExp tagRegex = RegExp(
        r'<tajweed class=([^>]+)>(.*?)</tajweed>',
        caseSensitive: false,
      );
      
      int currentIndex = 0;
      for (final match in tagRegex.allMatches(cleanText)) {
        final start = match.start;
        final end = match.end;
        
        // Add plain text before the tag
        if (start > currentIndex) {
          spans.add(TajweedSpan(text: cleanText.substring(currentIndex, start)));
        }
        
        final className = match.group(1)!.replaceAll('"', '').replaceAll("'", "").trim();
        final content = match.group(2)!;
        
        final ruleId = _mapClassToRuleId(className);
        final rule = TajweedRules.findById(ruleId);
        
        spans.add(TajweedSpan(text: content, rule: rule));
        currentIndex = end;
      }
      
      // Add remaining text
      if (currentIndex < cleanText.length) {
        spans.add(TajweedSpan(text: cleanText.substring(currentIndex)));
      }
      
      return spans;
    }

    // 2. Bracket tag format [h:14[text]]
    if (!taggedText.contains('[') || !taggedText.contains(']')) {
      return [TajweedSpan(text: taggedText)];
    }

    final List<TajweedSpan> spans = [];
    final RegExp tagStartRegex = RegExp(r'\[([a-z])(?::\d+)?\[');
    
    int currentIndex = 0;
    while (currentIndex < taggedText.length) {
      final nextTagMatch = tagStartRegex.firstMatch(taggedText.substring(currentIndex));
      
      if (nextTagMatch == null) {
        if (currentIndex < taggedText.length) {
          spans.add(TajweedSpan(text: taggedText.substring(currentIndex)));
        }
        break;
      }

      final absoluteStart = currentIndex + nextTagMatch.start;
      if (absoluteStart > currentIndex) {
        spans.add(TajweedSpan(text: taggedText.substring(currentIndex, absoluteStart)));
      }

      final ruleIdent = nextTagMatch.group(1)!;
      final ruleId = _tagToRuleId[ruleIdent];
      final contentStart = absoluteStart + nextTagMatch.group(0)!.length;

      int bracketLevel = 1;
      int searchIndex = contentStart;
      int contentEnd = -1;

      while (searchIndex < taggedText.length && bracketLevel > 0) {
        if (taggedText[searchIndex] == '[') {
          if (tagStartRegex.hasMatch(taggedText.substring(searchIndex))) {
             bracketLevel++;
          }
        } else if (taggedText[searchIndex] == ']') {
          bracketLevel--;
          if (bracketLevel == 0) {
            contentEnd = searchIndex;
          }
        }
        searchIndex++;
      }

      if (contentEnd != -1) {
        final content = taggedText.substring(contentStart, contentEnd);
        if (content.contains('[')) {
          spans.add(TajweedSpan(
             text: _stripTags(content),
             rule: TajweedRules.findById(ruleId ?? ''),
          ));
        } else {
          spans.add(TajweedSpan(
            text: content,
            rule: TajweedRules.findById(ruleId ?? ''),
          ));
        }
        currentIndex = contentEnd + 1;
      } else {
        spans.add(TajweedSpan(text: taggedText.substring(absoluteStart, absoluteStart + 1)));
        currentIndex = absoluteStart + 1;
      }
    }

    return spans;
  }

  static String _stripTags(String text) {
    return text.replaceAll(RegExp(r'\[[a-z](?::\d+)?\[|\]'), '');
  }
}
