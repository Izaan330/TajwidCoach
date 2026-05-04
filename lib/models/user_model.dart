class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final int streakDays;
  final int longestStreak;
  final String? lastPracticeDate;
  final List<int> juzProgress; // 0-100 for each of 30 Juz
  final List<String> weakRules;
  final List<String> masteredRules;
  final String premiumStatus; // 'free', 'premium', 'family', 'lifetime'
  final String? premiumExpiry;
  final String role; // 'student', 'sheikh'
  final String? sheikhId; // If student, assigned sheikh
  final List<String> sheikhStudents; // If sheikh, list of student UIDs
  final int totalRecordings;
  final double averageScore;
  final List<String> badges; // Earned badge IDs
  final int streakFreezes;
  final String? masjid;
  final String? city;
  final String? familyCode;
  final int sheikhCredits;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.lastPracticeDate,
    this.juzProgress = const [],
    this.weakRules = const [],
    this.masteredRules = const [],
    this.premiumStatus = 'free',
    this.premiumExpiry,
    this.role = 'student',
    this.sheikhId,
    this.sheikhStudents = const [],
    this.totalRecordings = 0,
    this.averageScore = 0.0,
    this.badges = const [],
    this.streakFreezes = 2,
    this.masjid,
    this.city,
    this.familyCode,
    this.sheikhCredits = 0,
  });

  bool get isPremium => premiumStatus != 'free';
  bool get isSheikh => role == 'sheikh';
  bool get hasActiveStreak => streakDays > 0;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      photoUrl: map['photoUrl'],
      streakDays: map['streakDays'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastPracticeDate: map['lastPracticeDate'],
      juzProgress: List<int>.from(map['juzProgress'] ?? List.filled(30, 0)),
      weakRules: List<String>.from(map['weakRules'] ?? []),
      masteredRules: List<String>.from(map['masteredRules'] ?? []),
      premiumStatus: map['premiumStatus'] ?? 'free',
      premiumExpiry: map['premiumExpiry'],
      role: map['role'] ?? 'student',
      sheikhId: map['sheikhId'],
      sheikhStudents: List<String>.from(map['sheikhStudents'] ?? []),
      totalRecordings: map['totalRecordings'] ?? 0,
      averageScore: (map['averageScore'] ?? 0.0).toDouble(),
      badges: List<String>.from(map['badges'] ?? []),
      streakFreezes: map['streakFreezes'] ?? 2,
      masjid: map['masjid'],
      city: map['city'],
      familyCode: map['familyCode'],
      sheikhCredits: map['sheikhCredits'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'streakDays': streakDays,
      'longestStreak': longestStreak,
      'lastPracticeDate': lastPracticeDate,
      'juzProgress': juzProgress,
      'weakRules': weakRules,
      'masteredRules': masteredRules,
      'premiumStatus': premiumStatus,
      'premiumExpiry': premiumExpiry,
      'role': role,
      'sheikhId': sheikhId,
      'sheikhStudents': sheikhStudents,
      'totalRecordings': totalRecordings,
      'averageScore': averageScore,
      'badges': badges,
      'streakFreezes': streakFreezes,
      'masjid': masjid,
      'city': city,
      'familyCode': familyCode,
      'sheikhCredits': sheikhCredits,
    };
  }

  UserModel copyWith({
    String? name,
    int? streakDays,
    int? longestStreak,
    String? lastPracticeDate,
    List<int>? juzProgress,
    List<String>? weakRules,
    List<String>? masteredRules,
    String? premiumStatus,
    List<String>? badges,
    int? totalRecordings,
    double? averageScore,
    int? streakFreezes,
    String? role,
    String? masjid,
    String? city,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone,
      email: email,
      photoUrl: photoUrl,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      juzProgress: juzProgress ?? this.juzProgress,
      weakRules: weakRules ?? this.weakRules,
      masteredRules: masteredRules ?? this.masteredRules,
      premiumStatus: premiumStatus ?? this.premiumStatus,
      premiumExpiry: premiumExpiry,
      role: role ?? this.role,
      sheikhId: sheikhId,
      sheikhStudents: sheikhStudents,
      totalRecordings: totalRecordings ?? this.totalRecordings,
      averageScore: averageScore ?? this.averageScore,
      badges: badges ?? this.badges,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      masjid: masjid ?? this.masjid,
      city: city ?? this.city,
      familyCode: familyCode, // Pass through
      sheikhCredits: sheikhCredits,
    );
  }
}

