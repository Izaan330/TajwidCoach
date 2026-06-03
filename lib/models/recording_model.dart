class RecordingModel {
  final String id;
  final String userId;
  final String ayahReference; // e.g. "2:255"
  final String surahName;
  final int tajwidScore;
  final List<String> weakWords;
  final List<String> weakRuleIds;
  final String? audioUrl;
  final String? audioLocalPath;
  final DateTime timestamp;
  final String? sheikhFeedback;
  final String? sheikhId;
  final bool sheikhApproved;
  final int durationSeconds;

  const RecordingModel({
    required this.id,
    required this.userId,
    required this.ayahReference,
    required this.surahName,
    required this.tajwidScore,
    this.weakWords = const [],
    this.weakRuleIds = const [],
    this.audioUrl,
    this.audioLocalPath,
    required this.timestamp,
    this.sheikhFeedback,
    this.sheikhId,
    this.sheikhApproved = false,
    this.durationSeconds = 0,
  });

  String get gradeLabel {
    if (tajwidScore >= 95) return 'Excellent';
    if (tajwidScore >= 85) return 'Very Good';
    if (tajwidScore >= 75) return 'Good';
    if (tajwidScore >= 60) return 'Needs Work';
    return 'Keep Practicing';
  }

  factory RecordingModel.fromMap(Map<String, dynamic> map) {
    return RecordingModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      ayahReference: map['ayahReference'] ?? '',
      surahName: map['surahName'] ?? '',
      tajwidScore: map['tajwidScore'] ?? 0,
      weakWords: List<String>.from(map['weakWords'] ?? []),
      weakRuleIds: List<String>.from(map['weakRuleIds'] ?? []),
      audioUrl: map['audioUrl'],
      audioLocalPath: map['audioLocalPath'],
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      sheikhFeedback: map['sheikhFeedback'],
      sheikhId: map['sheikhId'],
      sheikhApproved: map['sheikhApproved'] ?? false,
      durationSeconds: map['durationSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'ayahReference': ayahReference,
    'surahName': surahName,
    'tajwidScore': tajwidScore,
    'weakWords': weakWords,
    'weakRuleIds': weakRuleIds,
    'audioUrl': audioUrl,
    'timestamp': timestamp.toIso8601String(),
    'sheikhFeedback': sheikhFeedback,
    'sheikhId': sheikhId,
    'sheikhApproved': sheikhApproved,
    'durationSeconds': durationSeconds,
  };
}

