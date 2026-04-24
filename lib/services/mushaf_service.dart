import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MushafService {
  // Point to the local backend during development to download the 1.2GB images on-demand.
  static const String _localUrl = 'http://192.168.29.237:8000/images/quran';
  static const String _prodUrl = 'https://tajwid-backend-73260634451.asia-south1.run.app/images/quran';

  static const String baseUrl = kDebugMode ? _localUrl : _prodUrl;

  /// Returns the image provider for a given page number.
  /// Uses CachedNetworkImageProvider to maintain offline access after first load.
  static ImageProvider getPageImage(int pageNumber) {
    final pageStr = pageNumber.toString().padLeft(3, '0');
    return CachedNetworkImageProvider('$baseUrl/page_$pageStr.png');
  }
}
