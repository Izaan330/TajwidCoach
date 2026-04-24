import 'package:flutter/material.dart';
import '../services/mushaf_service.dart';

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
    final imageProvider = MushafService.getPageImage(pageNumber);

    Widget content = Image(
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
    );

    if (isZoomEnabled) {
      content = InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: content,
      );
    }

    return Container(
      color: Colors.white,
      child: content,
    );
  }
}
