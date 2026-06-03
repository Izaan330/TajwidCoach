enum SheikhTier { basic, pro, madrasa }

class SheikhModel {
  final String id;
  final String name;
  final String englishName;
  final String phone;
  final String email;
  final String? photoUrl;
  final String masjid;
  final String city;
  final String country;
  final double rating;
  final int totalStudents;
  final int currentStudents;
  final bool isVerified;
  final bool isAvailable;
  final List<String> specializations; // e.g. ['Hafs', 'Warsh', 'Tajwid']
  final String bio;
  final List<String> students; // Student UIDs
  final String? nextAvailable;
  final int pricePerSession; // INR
  final bool offersGroupClasses;
  final int groupClassSize; // Max 5
  final SheikhTier tier;

  const SheikhModel({
    required this.id,
    required this.name,
    required this.englishName,
    required this.phone,
    this.email = '',
    this.photoUrl,
    required this.masjid,
    required this.city,
    this.country = 'India',
    this.rating = 0.0,
    this.totalStudents = 0,
    this.currentStudents = 0,
    this.isVerified = false,
    this.isAvailable = true,
    this.specializations = const [],
    this.bio = '',
    this.students = const [],
    this.nextAvailable,
    this.pricePerSession = 0,
    this.offersGroupClasses = false,
    this.groupClassSize = 5,
    this.tier = SheikhTier.basic,
  });

  factory SheikhModel.fromMap(Map<String, dynamic> map) {
    return SheikhModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      englishName: map['englishName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      masjid: map['masjid'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? 'India',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalStudents: map['totalStudents'] ?? 0,
      currentStudents: map['currentStudents'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      isAvailable: map['isAvailable'] ?? true,
      specializations: List<String>.from(map['specializations'] ?? []),
      bio: map['bio'] ?? '',
      students: List<String>.from(map['students'] ?? []),
      nextAvailable: map['nextAvailable'],
      pricePerSession: map['pricePerSession'] ?? 0,
      offersGroupClasses: map['offersGroupClasses'] ?? false,
      groupClassSize: map['groupClassSize'] ?? 5,
      tier: SheikhTier.values.firstWhere(
        (t) => t.name == (map['tier'] ?? 'basic'),
        orElse: () => SheikhTier.basic,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'englishName': englishName,
    'phone': phone,
    'email': email,
    'photoUrl': photoUrl,
    'masjid': masjid,
    'city': city,
    'country': country,
    'rating': rating,
    'totalStudents': totalStudents,
    'currentStudents': currentStudents,
    'isVerified': isVerified,
    'isAvailable': isAvailable,
    'specializations': specializations,
    'bio': bio,
    'students': students,
    'nextAvailable': nextAvailable,
    'pricePerSession': pricePerSession,
    'offersGroupClasses': offersGroupClasses,
    'groupClassSize': groupClassSize,
    'tier': tier.name,
  };
}

