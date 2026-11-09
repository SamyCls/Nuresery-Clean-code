class Enfant {
  final String id;
  final String nom;
  final String prenom;
  final String classe;
  final String telephone;
  bool estActif;

  // Additional profile information
  final String? dateNaissance;
  final String? sexe;
  final String? adresse;
  String? photoPath;

  // Registration date
  DateTime? dateInscription;

  // Father's information
  final String? nomPrenomPere;
  final String? telPere;
  final String? professionPere;
  final String? adressePere;

  // Mother's information
  final String? nomPrenomMere;
  final String? telMere;
  final String? professionMere;
  final String? statutFamilial;

  // Health information
  final String? allergies;
  final String? commentairesMedicaux;
  final String? dossierMedicalPath;

  // Payments and attendance history
  final List<Paiement>? paiements;
  final Map<DateTime, String>? historiquePresence;

  // Academic progression
  List<Evaluation>? evaluations;

  Enfant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.classe,
    required this.telephone,
    required this.estActif,
    this.dateNaissance,
    this.sexe,
    this.adresse,
    this.photoPath,
    this.dateInscription,
    this.nomPrenomPere,
    this.telPere,
    this.professionPere,
    this.adressePere,
    this.nomPrenomMere,
    this.telMere,
    this.professionMere,
    this.statutFamilial,
    this.allergies,
    this.commentairesMedicaux,
    this.dossierMedicalPath,
    this.historiquePresence,
    this.paiements,
    this.evaluations,
  });

  String get nomComplet => '$nom $prenom';
  String get statut => estActif ? 'ACTIF' : 'INACTIF';

  Enfant copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? classe,
    String? telephone,
    bool? estActif,
    String? dateNaissance,
    String? sexe,
    String? adresse,
    String? photoPath,
    DateTime? dateInscription,
    String? nomPrenomPere,
    String? telPere,
    String? professionPere,
    String? adressePere,
    String? nomPrenomMere,
    String? telMere,
    String? professionMere,
    String? statutFamilial,
    String? allergies,
    String? commentairesMedicaux,
    String? dossierMedicalPath,
    List<Paiement>? paiements,
    Map<DateTime, String>? historiquePresence,
    List<Evaluation>? evaluations,
  }) {
    return Enfant(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      classe: classe ?? this.classe,
      telephone: telephone ?? this.telephone,
      estActif: estActif ?? this.estActif,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      sexe: sexe ?? this.sexe,
      adresse: adresse ?? this.adresse,
      photoPath: photoPath ?? this.photoPath,
      dateInscription: dateInscription ?? this.dateInscription,
      nomPrenomPere: nomPrenomPere ?? this.nomPrenomPere,
      telPere: telPere ?? this.telPere,
      professionPere: professionPere ?? this.professionPere,
      adressePere: adressePere ?? this.adressePere,
      nomPrenomMere: nomPrenomMere ?? this.nomPrenomMere,
      telMere: telMere ?? this.telMere,
      professionMere: professionMere ?? this.professionMere,
      statutFamilial: statutFamilial ?? this.statutFamilial,
      allergies: allergies ?? this.allergies,
      commentairesMedicaux: commentairesMedicaux ?? this.commentairesMedicaux,
      dossierMedicalPath: dossierMedicalPath ?? this.dossierMedicalPath,
      paiements: paiements ?? this.paiements,
      historiquePresence: historiquePresence ?? this.historiquePresence,
      evaluations: evaluations ?? this.evaluations,
    );
  }
}

enum StatutPaiements { paye, impaye, partiel }

class Paiement {
  final DateTime date;
  final String mois;
  int montantPaye;
  int reste;
  int montantdu;
  StatutPaiements statut;

  Paiement({
    required this.date,
    required this.mois,
    required this.montantdu,
    required this.montantPaye,
    required this.reste,
    required this.statut,
  });
}

class Evaluation {
  final String enfantId;
  final DateTime date;
  String competence;
  bool valeur;
  String? texte;

  Evaluation({
    required this.enfantId,
    required this.date,
    required this.competence,
    this.valeur = false,
    this.texte,
  });

  Map<String, dynamic> toMap() {
    return {
      'enfantId': enfantId,
      'date': date.millisecondsSinceEpoch,
      'competence': competence,
      'valeur': valeur ? 1 : 0,
      'texte': texte,
    };
  }

  factory Evaluation.fromMap(Map<String, dynamic> map) {
    return Evaluation(
      enfantId: map['enfantId'] as String? ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(
        map['date'] is int
            ? map['date'] as int
            : int.tryParse(map['date'].toString()) ?? 0,
      ),
      competence: map['competence'] as String? ?? '',
      valeur: map['valeur'] == 1,
      texte: map['texte'] as String?,
    );
  }
}

final emptyEnfant = Enfant(
  id: '',
  nom: '',
  prenom: '',
  classe: '',
  telephone: '',
  estActif: true,
  dateNaissance: '',
  sexe: '',
  adresse: '',
  photoPath: '',
  dateInscription: null,
  nomPrenomPere: '',
  telPere: '',
  professionPere: '',
  adressePere: '',
  nomPrenomMere: '',
  telMere: '',
  professionMere: '',
  statutFamilial: '',
  allergies: '',
  commentairesMedicaux: '',
  evaluations: [],
);
