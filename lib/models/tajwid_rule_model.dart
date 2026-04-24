class TajwidRule {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final String colorHex;
  final String backgroundHex;
  final String category;
  final List<String> subTypes;
  final String exampleWord;
  final String? videoUrl;

  const TajwidRule({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.colorHex,
    required this.backgroundHex,
    required this.category,
    required this.subTypes,
    required this.exampleWord,
    this.videoUrl,
  });
}

class TajwidAnalysisResult {
  final int overallScore;
  final String feedback;
  final String grade;
  final List<RuleScore> ruleScores;
  final List<String> weakWords;
  final List<String> weakRuleIds;
  final List<String> excellentRuleIds;
  final String encouragement;

  const TajwidAnalysisResult({
    required this.overallScore,
    required this.feedback,
    required this.grade,
    required this.ruleScores,
    required this.weakWords,
    required this.weakRuleIds,
    required this.excellentRuleIds,
    required this.encouragement,
  });

  factory TajwidAnalysisResult.fromJson(Map<String, dynamic> json) {
    return TajwidAnalysisResult(
      overallScore: json['overall_score'] ?? 0,
      feedback: json['feedback'] ?? '',
      grade: json['grade'] ?? '',
      ruleScores: (json['rule_scores'] as List? ?? [])
          .map((e) => RuleScore.fromJson(e))
          .toList(),
      weakWords: List<String>.from(json['weak_words'] ?? []),
      weakRuleIds: List<String>.from(json['weak_rule_ids'] ?? []),
      excellentRuleIds: List<String>.from(json['excellent_rule_ids'] ?? []),
      encouragement: json['encouragement'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'overall_score': overallScore,
        'feedback': feedback,
        'grade': grade,
        'rule_scores': ruleScores.map((e) => e.toJson()).toList(),
        'weak_words': weakWords,
        'weak_rule_ids': weakRuleIds,
        'excellent_rule_ids': excellentRuleIds,
        'encouragement': encouragement,
      };

  String get letterGrade {
    if (overallScore >= 95) return 'A+';
    if (overallScore >= 90) return 'A';
    if (overallScore >= 85) return 'B+';
    if (overallScore >= 80) return 'B';
    if (overallScore >= 70) return 'C';
    return 'D';
  }
}

class RuleScore {
  final String ruleId;
  final String ruleName;
  final int score; // 0-100
  final String feedback;
  final bool isWeak;

  const RuleScore({
    required this.ruleId,
    required this.ruleName,
    required this.score,
    required this.feedback,
    required this.isWeak,
  });

  factory RuleScore.fromJson(Map<String, dynamic> json) {
    return RuleScore(
      ruleId: json['rule_id'] ?? '',
      ruleName: json['rule_name'] ?? '',
      score: json['score'] ?? 0,
      feedback: json['feedback'] ?? '',
      isWeak: json['is_weak'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'rule_id': ruleId,
        'rule_name': ruleName,
        'score': score,
        'feedback': feedback,
        'is_weak': isWeak,
      };
}

