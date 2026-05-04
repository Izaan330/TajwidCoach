import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mushaf_service.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';

class MushafPageView extends StatelessWidget {
  final int pageNumber;
  final bool isZoomEnabled;

  const MushafPageView({
    super.key,
    required this.pageNumber,
    this.isZoomEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final imageProvider = MushafService.getPageImage(pageNumber);

    Color bgColor = Colors.white;
    ColorFilter? filter;

    switch (settings.mushafTheme) {
      case MushafTheme.white:
        bgColor = Colors.white;
        break;
      case MushafTheme.cream:
        bgColor = const Color(0xFFF4ECD8); // Classic cream
        filter = const ColorFilter.mode(Color(0xFFF4ECD8), BlendMode.multiply);
        break;
      case MushafTheme.dark:
        bgColor = const Color(0xFF1A1A1A);
        filter = const ColorFilter.matrix([
          -1,  0,  0, 0, 255,
           0, -1,  0, 0, 255,
           0,  0, -1, 0, 255,
           0,  0,  0, 1,   0,
        ]); // Invert colors
        break;
      case MushafTheme.night:
        bgColor = const Color(0xFF0D1628);
        filter = const ColorFilter.matrix([
          -0.8,    0,    0, 0, 200,
             0, -0.8,    0, 0, 200,
             0,    0, -0.8, 0, 200,
             0,    0,    0, 1,   0,
        ]); // Soft night invert
        break;
    }

    Widget content = ColorFiltered(
      colorFilter: filter ?? const ColorFilter.mode(Colors.transparent, BlendMode.dst),
      child: Image(
        image: imageProvider,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppTheme.primaryGreen,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Page $pageNumber could not be loaded.\nPlease check your internet connection.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (isZoomEnabled) {
      content = InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: content,
      );
    }

    return Container(
      color: bgColor,
      child: content,
    );
  }
}
