class Slot {
  const Slot({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.isBooked,
  });

  final String id;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isBooked;

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id']?.toString() ?? '',
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
      isBooked: json['isBooked'] as bool? ?? false,
    );
  }
}
