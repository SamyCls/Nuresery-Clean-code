enum StatutPaiement { paye, impaye }

class PaiementEmploye {
  DateTime datePaiement;
  String mois;
  double salaireBase;
  double prime;
  double montantPaye;
  StatutPaiement statut;

  PaiementEmploye({
    required this.datePaiement,
    required this.mois,
    required this.salaireBase,
    this.prime = 0.0,
    required this.montantPaye,
    required this.statut,
  });

  double get salaireTotal => salaireBase + prime;
}

class Employe {
  String id;
  String nom;
  String prenom;
  DateTime dateNaissance;
  DateTime dateEmbauche;
  String poste;
  double salaire;
  String telephone;
  String adresse;
  bool estActif;
  String photoUrl;
  List<PaiementEmploye> paiements;

  Employe({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.dateEmbauche,
    required this.poste,
    required this.salaire,
    required this.telephone,
    required this.adresse,
    required this.estActif,
    required this.photoUrl,
    required this.paiements,
  });

  String get nomComplet => '$nom $prenom';

  Employe copyWith({
    String? id,
    String? nom,
    String? prenom,
    DateTime? dateNaissance,
    DateTime? dateEmbauche,
    String? poste,
    double? salaire,
    String? telephone,
    String? adresse,
    bool? estActif,
    String? photoUrl,
    List<PaiementEmploye>? paiements,
  }) {
    return Employe(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      dateEmbauche: dateEmbauche ?? this.dateEmbauche,
      poste: poste ?? this.poste,
      salaire: salaire ?? this.salaire,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      estActif: estActif ?? this.estActif,
      photoUrl: photoUrl ?? this.photoUrl,
      paiements: paiements ?? this.paiements,
    );
  }
}

final Employe emptyEmployee = Employe(
  id: '',
  nom: '',
  prenom: '',
  dateNaissance: DateTime.now(),
  dateEmbauche: DateTime.now(),
  poste: '',
  salaire: 0.0,
  telephone: '',
  adresse: '',
  estActif: true,
  photoUrl: '',
  paiements: [],
);
