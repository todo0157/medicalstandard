class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.clinicName,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String specialty;
  final String clinicName;
  final String? imageUrl;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final clinic = json['clinic'] as Map<String, dynamic>? ?? {};
    return Doctor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      clinicName: clinic['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}
