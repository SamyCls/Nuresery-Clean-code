import 'package:uuid/uuid.dart';

class Depense {
  String id;
  String categorie;
  String description;
  double montant;
  DateTime date;
  String attestation;

  Depense({
    String? id,
    required this.categorie,
    required this.description,
    required this.montant,
    required this.date,
    required this.attestation,
  }) : id = id ?? const Uuid().v4();

  Depense copyWith({
    String? id,
    String? categorie,
    String? description,
    double? montant,
    DateTime? date,
    String? attestation,
  }) {
    final depense = Depense(
      id: id ?? this.id,
      categorie: categorie ?? this.categorie,
      description: description ?? this.description,
      montant: montant ?? this.montant,
      date: date ?? this.date,
      attestation: attestation ?? this.attestation,
    );
    return depense;
  }
}
