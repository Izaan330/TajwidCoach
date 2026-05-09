class TajweedMapping {
  /// The offset to add to the UI page number to get the asset image number.
  /// UI Page 1 + 9 = assets/images/quran/page_010.png
  static const int assetOffset = 9;

  /// Map of Surah Number to UI Page Number (1 to 615).
  static const Map<int, int> surahStartPages = {
    1: 1,
    26: 366,
    27: 376,
    37: 445,
    38: 452,
    45: 498,
    47: 506,
    69: 567,
    70: 569,
    71: 571,
    72: 573,
    73: 576,
    74: 578,
    75: 580,
    76: 582,
    77: 584,
    78: 586,
    79: 587,
    80: 589,
    81: 590,
    82: 591,
    83: 592,
    84: 594,
    85: 595,
    86: 596,
    87: 597,
    88: 597,
    89: 598,
    90: 600,
    91: 600,
    92: 601,
    93: 602,
    94: 602,
    95: 603,
    96: 603,
    97: 604,
    98: 604,
    99: 605,
    100: 605,
    101: 606,
    102: 606,
    103: 607,
    104: 607,
    105: 607,
    106: 608,
    107: 608,
    108: 608,
    109: 608,
    110: 609,
    111: 609,
    112: 609,
    113: 610,
    114: 610,
  };

  /// Returns the UI Page Number for a given surah.
  static int getStartPage(int surahNumber, int standardPage) {
    if (surahStartPages.containsKey(surahNumber)) {
      return surahStartPages[surahNumber]!;
    }
    
    // For surahs not in the map, we try to estimate
    if (surahNumber < 26) {
      return standardPage; // Al-Fatihah is Page 1
    }
    
    // Default fallback
    return standardPage;
  }
  
  /// Converts a UI Page Number to the actual asset filename page number.
  static String getAssetPageString(int uiPage) {
    final assetPage = uiPage + assetOffset;
    return assetPage.toString().padLeft(3, '0');
  }
}
