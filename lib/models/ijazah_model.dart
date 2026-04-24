class IjazahCertificate {
  final String id;
  final String studentId;
  final String studentName;
  final String sheikhId;
  final String sheikhName;
  final String sheikhSignature;
  final String masjid;
  final String attestation;
  final DateTime issuedDate;

  IjazahCertificate({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.sheikhId,
    required this.sheikhName,
    required this.sheikhSignature,
    required this.masjid,
    required this.attestation,
    required this.issuedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'sheikhId': sheikhId,
      'sheikhName': sheikhName,
      'sheikhSignature': sheikhSignature,
      'masjid': masjid,
      'attestation': attestation,
      'issuedDate': issuedDate.toIso8601String(),
    };
  }

  factory IjazahCertificate.fromMap(Map<String, dynamic> map) {
    return IjazahCertificate(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      sheikhId: map['sheikhId'] ?? '',
      sheikhName: map['sheikhName'] ?? '',
      sheikhSignature: map['sheikhSignature'] ?? '',
      masjid: map['masjid'] ?? '',
      attestation: map['attestation'] ?? '',
      issuedDate: DateTime.parse(map['issuedDate']),
    );
  }
}
