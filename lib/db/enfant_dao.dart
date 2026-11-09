import '../models/enfant.dart';
import 'database_helper.dart';

class EnfantDao {
  static const String _tableEnfants = 'enfants';
  static const String _tablePaiements = 'paiements';
  static const String _tablePresences = 'presences';

  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  // ---------------- ENFANT CRUD Operations ----------------

  Future<int> insertEnfant(Enfant enfant) async {
    final db = await dbHelper.database;
    return await db.insert(_tableEnfants, _enfantToMap(enfant));
  }

  Future<int> updateEnfant(Enfant enfant) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableEnfants,
      _enfantToMap(enfant),
      where: 'id = ?',
      whereArgs: [enfant.id],
    );
  }

  Future<int> deleteEnfant(String id) async {
    final db = await dbHelper.database;

    // Delete related payments and presences before deleting the child
    await db.delete(_tablePaiements, where: 'enfant_id = ?', whereArgs: [id]);
    await db.delete(_tablePresences, where: 'enfantId = ?', whereArgs: [id]);

    return await db.delete(_tableEnfants, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Enfant>> getAllEnfants() async {
    final db = await dbHelper.database;
    final result = await db.query(_tableEnfants, orderBy: 'nom ASC');
    return result.map(_mapToEnfant).toList();
  }

  Future<Enfant?> getEnfantById(String id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      _tableEnfants,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return _mapToEnfant(result.first);
    }
    return null;
  }

  Future<int> editEnfant(String id, Map<String, dynamic> updates) async {
    final db = await dbHelper.database;

    if (updates.containsKey('estActif') && updates['estActif'] is bool) {
      updates['estActif'] = (updates['estActif'] as bool) ? 1 : 0;
    }

    return await db.update(
      _tableEnfants,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Enfant?> getEnfantWithPaiements(String enfantId) async {
    final db = await dbHelper.database;

    final enfantResult = await db.query(
      _tableEnfants,
      where: 'id = ?',
      whereArgs: [enfantId],
    );

    if (enfantResult.isEmpty) return null;

    final enfant = _mapToEnfant(enfantResult.first);
    final paiementsResult = await db.query(
      _tablePaiements,
      where: 'enfant_id = ?',
      whereArgs: [enfantId],
      orderBy: 'date DESC',
    );

    final paiements = paiementsResult.map(_mapToPaiement).toList();

    return enfant.copyWith(paiements: paiements);
  }

  // ---------------- PAIEMENT CRUD Operations ----------------

  Future<int> insertPaiement(String enfantId, Paiement paiement) async {
    final db = await dbHelper.database;
    return await db.insert(_tablePaiements, _paiementToMap(paiement, enfantId));
  }

  Future<int> updatePaiement(String enfantId, Paiement paiement) async {
    final db = await dbHelper.database;
    return await db.update(
      _tablePaiements,
      _paiementToMap(paiement, enfantId),
      where: 'id = ? AND enfant_id = ?',
      whereArgs: [
        '${enfantId}_${paiement.mois}_${paiement.date.millisecondsSinceEpoch}',
        enfantId,
      ],
    );
  }

  Future<int> deletePaiement(String paiementId, String enfantId) async {
    final db = await dbHelper.database;
    return await db.delete(
      _tablePaiements,
      where: 'id = ? AND enfant_id = ?',
      whereArgs: [paiementId, enfantId],
    );
  }

  Future<List<Paiement>> getPaiementsByEnfantId(String enfantId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      _tablePaiements,
      where: 'enfant_id = ?',
      whereArgs: [enfantId],
      orderBy: 'date DESC',
    );
    return result.map(_mapToPaiement).toList();
  }

  Future<Paiement?> getPaiementById(String paiementId, String enfantId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      _tablePaiements,
      where: 'id = ? AND enfant_id = ?',
      whereArgs: [paiementId, enfantId],
    );
    if (result.isNotEmpty) {
      return _mapToPaiement(result.first);
    }
    return null;
  }

  Future<List<Paiement>> getPaiementsByMonth(String mois, int annee) async {
    final db = await dbHelper.database;
    final result = await db.query(
      _tablePaiements,
      where: 'mois = ? AND strftime("%Y", date) = ?',
      whereArgs: [mois, annee.toString()],
      orderBy: 'date DESC',
    );
    return result.map(_mapToPaiement).toList();
  }

  Future<List<Paiement>> getPaiementsByStatus(StatutPaiements statut) async {
    final db = await dbHelper.database;
    final result = await db.query(
      _tablePaiements,
      where: 'statut = ?',
      whereArgs: [statut.index],
      orderBy: 'date DESC',
    );
    return result.map(_mapToPaiement).toList();
  }

  // ---------------- Private Mapping Helpers ----------------

  Map<String, dynamic> _enfantToMap(Enfant e) {
    return {
      'id': e.id,
      'nom': e.nom,
      'prenom': e.prenom,
      'classe': e.classe,
      'telephone': e.telephone,
      'estActif': e.estActif ? 1 : 0,
      'dateNaissance': e.dateNaissance,
      'sexe': e.sexe,
      'adresse': e.adresse,
      'photoPath': e.photoPath,
      'nomPrenomPere': e.nomPrenomPere,
      'telPere': e.telPere,
      'professionPere': e.professionPere,
      'adressePere': e.adressePere,
      'nomPrenomMere': e.nomPrenomMere,
      'telMere': e.telMere,
      'professionMere': e.professionMere,
      'statutFamilial': e.statutFamilial,
      'allergies': e.allergies,
      'commentairesMedicaux': e.commentairesMedicaux,
      'dossierMedicalPath': e.dossierMedicalPath,
      'dateInscription': e.dateInscription?.toIso8601String(),
    };
  }

  Enfant _mapToEnfant(Map<String, dynamic> map) {
    return Enfant(
      id: map['id'] as String? ?? '',
      nom: map['nom'] as String? ?? '',
      prenom: map['prenom'] as String? ?? '',
      classe: map['classe'] as String? ?? '',
      telephone: map['telephone'] as String? ?? '',
      estActif: map['estActif'] == 1,
      dateNaissance: map['dateNaissance'] as String?,
      sexe: map['sexe'] as String?,
      adresse: map['adresse'] as String?,
      photoPath: map['photoPath'] as String?,
      nomPrenomPere: map['nomPrenomPere'] as String?,
      telPere: map['telPere'] as String?,
      professionPere: map['professionPere'] as String?,
      adressePere: map['adressePere'] as String?,
      nomPrenomMere: map['nomPrenomMere'] as String?,
      telMere: map['telMere'] as String?,
      professionMere: map['professionMere'] as String?,
      statutFamilial: map['statutFamilial'] as String?,
      allergies: map['allergies'] as String?,
      commentairesMedicaux: map['commentairesMedicaux'] as String?,
      dossierMedicalPath: map['dossierMedicalPath'] as String?,
      dateInscription: map['dateInscription'] != null
          ? DateTime.tryParse(map['dateInscription'] as String)
          : null,
    );
  }

  Map<String, dynamic> _paiementToMap(Paiement p, String enfantId) {
    return {
      'id': '${enfantId}_${p.mois}_${p.date.millisecondsSinceEpoch}',
      'enfant_id': enfantId,
      'date': p.date.toIso8601String(),
      'mois': p.mois,
      'montantdu': p.montantdu,
      'montantPaye': p.montantPaye,
      'reste': p.reste,
      'statut': p.statut.index,
    };
  }

  Paiement _mapToPaiement(Map<String, dynamic> map) {
    final statutIndex = map['statut'] is int
        ? map['statut'] as int
        : int.tryParse(map['statut'].toString()) ?? 0;

    return Paiement(
      date: DateTime.parse(map['date'] as String),
      mois: map['mois'] as String? ?? '',
      montantdu: (map['montantdu'] as num?)?.toInt() ?? 0,
      montantPaye: (map['montantPaye'] as num?)?.toInt() ?? 0,
      reste: (map['reste'] as num?)?.toInt() ?? 0,
      statut: (statutIndex >= 0 && statutIndex < StatutPaiements.values.length)
          ? StatutPaiements.values[statutIndex]
          : StatutPaiements.impaye,
    );
  }
}
