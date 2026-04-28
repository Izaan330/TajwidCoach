import 'package:flutter/material.dart';
import '../services/tajweed_engine.dart';
import '../models/tajwid_rule_model.dart';
import '../utils/tajweed_tag_parser.dart';
import '../theme/app_theme.dart';

/// Renders Arabic Quran text with color-coded Tajweed rule highlighting.
/// When [showTajweed] is false, renders plain text identically to a regular Text widget.
class TajweedText extends StatelessWidget {
  final String text; // Plain text (fallback)
  final String? tajweedTagText; // Professional tagged text (Al-Quran.cloud format)
  final int? ayahNumber;
  final double fontSize;
  final String fontFamily;
  final double lineHeight;
  final bool showTajweed;
  final TextDirection textDirection;
  final TextAlign textAlign;

  const TajweedText({
    super.key,
    required this.text,
    this.tajweedTagText,
    this.ayahNumber,
    this.fontSize = 28,
    this.fontFamily = 'UthmanicHafs',
    this.lineHeight = 2.4, // Increased from 1.9 for better shaping support
    this.showTajweed = true,
    this.textDirection = TextDirection.rtl,
    this.textAlign = TextAlign.right,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIndoPak = fontFamily == 'IndoPak';

    // For Indo-Pak text, strip only trailing "junk" characters that produce
    // the font's ghost circle (stop signs, direction marks, BOM, PUA chars).
    // Diacritics (shadda, fatha, madda, etc.) are NOT stripped.
    String displayText = text;
    if (isIndoPak) {
      int keepUntil = text.length;
      for (int i = text.length - 1; i >= 0; i--) {
        if (!_isTrailingJunk(text.codeUnitAt(i))) {
          keepUntil = i + 1;
          break;
        }
      }
      displayText = text.substring(0, keepUntil);
    }

    final fixedText = _fixLigatures(displayText);

    final List<TajweedSpan> spans;
    if (showTajweed) {
      if (tajweedTagText != null && tajweedTagText!.isNotEmpty) {
        spans = TajweedTagParser.parse(tajweedTagText!);
      } else {
        spans = TajweedEngine.annotate(fixedText);
      }
    } else {
      spans = [TajweedSpan(text: fixedText)];
    }

    final List<InlineSpan> inlineSpans =
        spans.map((span) => _buildSpan(span)).toList();

    // Append ayah end marker
    if (ayahNumber != null) {
      if (isIndoPak) {
        // Use a custom-painted circle widget — completely font-independent,
        // so the IndoPak font can never inject its own decorative circle.
        inlineSpans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _AyahMarkerCircle(
                number: ayahNumber!,
                size: fontSize * 0.85,
              ),
            ),
          ),
        );
      } else {
        // Uthmani mode: use the standard \u06DD glyph from UthmanicHafs font.
        inlineSpans.add(
          TextSpan(
            text: ' \u06DD${_toArabicDigits(ayahNumber!)}',
            style: TextStyle(
              fontFamily: 'UthmanicHafs',
              fontSize: fontSize * 0.9,
              height: lineHeight,
              color: const Color(0xFFC09941),
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }
    }

    return RichText(
      textDirection: textDirection,
      textAlign: textAlign,
      text: TextSpan(children: inlineSpans),
    );
  }

  InlineSpan _buildSpan(TajweedSpan span) {
    if (span.rule == null) {
      return TextSpan(
        text: span.text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          height: lineHeight,
          color: AppTheme.textPrimary,
        ),
      );
    }

    final color = TajweedRules.colorFromHex(span.rule!.colorHex);
    return TextSpan(
      text: span.text,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        height: lineHeight,
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  String _toArabicDigits(int number) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String s = number.toString();
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(englishDigits[i], arabicDigits[i]);
    }
    return s;
  }

  /// Returns true for characters that should be stripped from the end of
  /// Indo-Pak text to prevent the font's ghost circle.  Diacritics (harakat,
  /// shadda, madda, sukun, etc.) are NOT junk and will be preserved.
  static bool _isTrailingJunk(int code) {
    if (code >= 0x06D6 && code <= 0x06DE) return true;  // stop signs, end-of-ayah, rub-el-hizb
    if (code == 0x06E9) return true;                      // place of sajdah
    if (code >= 0x200B && code <= 0x200F) return true;    // zero-width chars, direction marks
    if (code >= 0x202A && code <= 0x202F) return true;    // more direction/formatting marks
    if (code == 0xFEFF) return true;                      // BOM
    if (code == 0x00A0 || code == 0x0020) return true;    // spaces
    if (code >= 0xE000 && code <= 0xF8FF) return true;    // private use area
    return false;
  }

  /// Fixes degenerate Lam-Alif sequences (Lam + Marks + Alif) by replacing them
  /// with pre-composed Unicode ligatures. This ensures correct "crossed" shaping
  /// instead of separate vertical strokes, especially in Indo-Pak/Nastaliq fonts.
  static String _fixLigatures(String input) {
    if (input.isEmpty) return input;

    String result = input;

    // Table of Lam-Alif variants
    // 1. Lam (\u0644) + [Marks] + Alif (\u0627) -> Ligature (\uFEFB) + [Marks]
    result = result.replaceAllMapped(
        RegExp(r'\u0644([\u064b-\u065f\u0670]*)\u0627'),
        (match) => '\uFEFB${match.group(1)}');

    // 2. Lam + [Marks] + Alif with Madda Above (\u0622) -> Ligature (\uFEF9) + [Marks]
    result = result.replaceAllMapped(
        RegExp(r'\u0644([\u064b-\u065f\u0670]*)\u0622'),
        (match) => '\uFEF9${match.group(1)}');

    // 3. Lam + [Marks] + Alif with Hamza Above (\u0623) -> Ligature (\uFEF5) + [Marks]
    result = result.replaceAllMapped(
        RegExp(r'\u0644([\u064b-\u065f\u0670]*)\u0623'),
        (match) => '\uFEF5${match.group(1)}');

    // 4. Lam + [Marks] + Alif with Hamza Below (\u0625) -> Ligature (\uFEF7) + [Marks]
    result = result.replaceAllMapped(
        RegExp(r'\u0644([\u064b-\u065f\u0670]*)\u0625'),
        (match) => '\uFEF7${match.group(1)}');

    return result;
  }
}

/// A custom-painted ayah number circle — completely font-independent.
/// Draws a gold circle with the ayah number (in Arabic-Indic digits) centred inside.
class _AyahMarkerCircle extends StatelessWidget {
  final int number;
  final double size;

  const _AyahMarkerCircle({required this.number, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AyahCirclePainter(number: number),
    );
  }
}

class _AyahCirclePainter extends CustomPainter {
  final int number;
  _AyahCirclePainter({required this.number});

  static String _toArabicDigits(int n) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => digits[int.parse(c)]).join();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle — gold border
    final borderPaint = Paint()
      ..color = const Color(0xFFC09941)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 1, borderPaint);

    // Number text
    final textPainter = TextPainter(
      text: TextSpan(
        text: _toArabicDigits(number),
        style: TextStyle(
          fontSize: size.width * 0.48,
          color: const Color(0xFFC09941),
          fontWeight: FontWeight.w600,
          fontFamily: 'UthmanicHafs',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _AyahCirclePainter old) => old.number != number;
}

/// A compact card showing the legend for Tajweed colors, shown at the top of the reading screen.
class TajweedLegend extends StatefulWidget {
  const TajweedLegend({super.key});

  @override
  State<TajweedLegend> createState() => _TajweedLegendState();
}

class _TajweedLegendState extends State<TajweedLegend> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: AppTheme.backgroundSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.palette_rounded, size: 18, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  const Text(
                    'Tajweed Color Guide',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Legend chips — collapsed: show first row, expanded: all
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: TajweedRules.all.map((rule) => _RuleChip(rule: rule)).toList(),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                children: TajweedRules.all
                    .take(6)
                    .map((rule) => _RuleChip(rule: rule))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _RuleChip extends StatelessWidget {
  final TajwidRule rule;
  const _RuleChip({required this.rule});

  @override
  Widget build(BuildContext context) {
    final color = TajweedRules.colorFromHex(rule.colorHex);
    return Tooltip(
      message: '${rule.name}: ${rule.description}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(120), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              rule.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
