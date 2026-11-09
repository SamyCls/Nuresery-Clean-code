// ignore_for_file: file_names

class Presence {
  final String enfantId; // Foreign key -> enfant.id
  final DateTime date; // Date of presence
  final String statut; // "Présent" | "Absent"

  const Presence({
    required this.enfantId,
    required this.date,
    required this.statut,
  });

  Map<String, dynamic> toMap() {
    return {
      'enfantId': enfantId,
      'date': date.toIso8601String(),
      'statut': statut,
    };
  }

  factory Presence.fromMap(Map<String, dynamic> map) {
    return Presence(
      enfantId: map['enfantId'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      statut: map['statut'] as String? ?? '',
    );
  }

  Presence copyWith({String? enfantId, DateTime? date, String? statut}) {
    return Presence(
      enfantId: enfantId ?? this.enfantId,
      date: date ?? this.date,
      statut: statut ?? this.statut,
    );
  }
}
