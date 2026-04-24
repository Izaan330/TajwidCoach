import '../services/tajweed_engine.dart';

/// Parses Al-Quran.cloud's [h:ID[text]] tagging format into TajweedSpans.
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

  /// Parses a tagged string like "بِرَبِّ [h:14[ٱ][l[ل][g[نّ][p[َا]سِ"
  static List<TajweedSpan> parse(String taggedText) {
    if (!taggedText.contains('[') || !taggedText.contains(']')) {
      return [TajweedSpan(text: taggedText)];
    }

    final List<TajweedSpan> spans = [];
    final RegExp tagStartRegex = RegExp(r'\[([a-z])(?::\d+)?\[');
    
    int currentIndex = 0;
    while (currentIndex < taggedText.length) {
      final nextTagMatch = tagStartRegex.firstMatch(taggedText.substring(currentIndex));
      
      if (nextTagMatch == null) {
        // No more tags, add remaining text
        if (currentIndex < taggedText.length) {
          spans.add(TajweedSpan(text: taggedText.substring(currentIndex)));
        }
        break;
      }

      final absoluteStart = currentIndex + nextTagMatch.start;
      
      // Add plain text before the tag
      if (absoluteStart > currentIndex) {
        spans.add(TajweedSpan(text: taggedText.substring(currentIndex, absoluteStart)));
      }

      final ruleIdent = nextTagMatch.group(1)!;
      final ruleId = _tagToRuleId[ruleIdent];
      final contentStart = absoluteStart + nextTagMatch.group(0)!.length;

      // Find the closing bracket for this tag
      // Note: Tags can be nested, but for Al-Quran.cloud, they are often sequential clusters.
      int bracketLevel = 1;
      int searchIndex = contentStart;
      int contentEnd = -1;

      while (searchIndex < taggedText.length && bracketLevel > 0) {
        if (taggedText[searchIndex] == '[') {
          // Check if it's a new start tag vs just literal [
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
        // Recursive parse for nested content or simple rule application
        if (content.contains('[')) {
          // Apply current rule to nested content if applicable, or just flatten
          // For now, Al-Quran.cloud's sequential nesting usually means only the innermost rule is visible visually.
          // We'll simplify and apply the ruleId of the match to the whole block.
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
        // Malformed tag, treat as text
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
