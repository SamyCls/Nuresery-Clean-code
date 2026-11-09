class Accompagnateur {
  final int? id;
  final String enfantId;
  final String nomPrenom;
  final String telephone;
  final String cin;

  const Accompagnateur({
    this.id,
    required this.enfantId,
    required this.nomPrenom,
    required this.telephone,
    required this.cin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'enfantId': enfantId,
      'nomPrenom': nomPrenom,
      'telephone': telephone,
      'cin': cin,
    };
  }

  factory Accompagnateur.fromMap(Map<String, dynamic> map) {
    return Accompagnateur(
      id: map['id'] as int?,
      enfantId: map['enfantId'] as String? ?? '',
      nomPrenom: map['nomPrenom'] as String? ?? '',
      telephone: map['telephone'] as String? ?? '',
      cin: map['cin'] as String? ?? '',
    );
  }

  Accompagnateur copyWith({
    int? id,
    String? enfantId,
    String? nomPrenom,
    String? telephone,
    String? cin,
  }) {
    return Accompagnateur(
      id: id ?? this.id,
      enfantId: enfantId ?? this.enfantId,
      nomPrenom: nomPrenom ?? this.nomPrenom,
      telephone: telephone ?? this.telephone,
      cin: cin ?? this.cin,
    );
  }
}
