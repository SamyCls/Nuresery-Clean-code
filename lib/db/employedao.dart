import 'package:sqflite/sqflite.dart';
import '../models/employe.dart';
import 'database_helper.dart';

class EmployeDao {
  static const String _tableEmployes = 'employes';
  static const String _tablePaiementsEmploye = 'paiements_employe';

  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  // ---------------- INSERT ----------------

  Future<void> insertEmploye(Employe employe) async {
    final db = await dbHelper.database;

    await db.insert(
      _tableEmployes,
      _employeToMap(employe),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (var p in employe.paiements) {
      await db.insert(_tablePaiementsEmploye, _paiementToMap(p, employe.id));
    }
  }

  // ---------------- UPDATE EMPLOYE ----------------

  Future<void> updateEmploye(Employe employe) async {
    final db = await dbHelper.database;

    await db.update(
      _tableEmployes,
      _employeToMap(employe),
      where: 'id = ?',
      whereArgs: [employe.id],
    );

    await db.delete(
      _tablePaiementsEmploye,
      where: 'employeId = ?',
      whereArgs: [employe.id],
    );

    for (var p in employe.paiements) {
      await db.insert(_tablePaiementsEmploye, _paiementToMap(p, employe.id));
    }
  }

  // ---------------- PAYMENTS CRUD ----------------

  Future<void> updatePaiement(
    String employeId,
    PaiementEmploye paiement,
  ) async {
    final db = await dbHelper.database;

    await db.update(
      _tablePaiementsEmploye,
      {'montantPaye': paiement.montantPaye, 'statut': paiement.statut.name},
      where: 'employeId = ? AND mois = ? AND datePaiement = ?',
      whereArgs: [
        employeId,
        paiement.mois,
        paiement.datePaiement.toIso8601String(),
      ],
    );
  }

  Future<void> addPaiement(String employeId, PaiementEmploye paiement) async {
    final db = await dbHelper.database;
    await db.insert(
      _tablePaiementsEmploye,
      _paiementToMap(paiement, employeId),
    );
  }

  Future<void> deletePaiement(
    String employeId,
    String mois,
    DateTime datePaiement,
  ) async {
    final db = await dbHelper.database;

    await db.delete(
      _tablePaiementsEmploye,
      where: 'employeId = ? AND mois = ? AND datePaiement = ?',
      whereArgs: [employeId, mois, datePaiement.toIso8601String()],
    );
  }

  Future<List<PaiementEmploye>> getPaiementsByEmployeId(
    String employeId,
  ) async {
    final db = await dbHelper.database;

    final paiementsMaps = await db.query(
      _tablePaiementsEmploye,
      where: 'employeId = ?',
      whereArgs: [employeId],
      orderBy: 'datePaiement DESC',
    );

    return paiementsMaps.map(_mapToPaiementEmploye).toList();
  }

  // ---------------- DELETE EMPLOYE ----------------

  Future<void> deleteEmploye(String id) async {
    final db = await dbHelper.database;

    await db.delete(
      _tablePaiementsEmploye,
      where: 'employeId = ?',
      whereArgs: [id],
    );

    await db.delete(_tableEmployes, where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- GET BY ID ----------------

  Future<Employe?> getEmployeById(String id) async {
    final db = await dbHelper.database;

    final maps = await db.query(
      _tableEmployes,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final paiements = await getPaiementsByEmployeId(id);
      return _mapToEmploye(maps.first, paiements);
    }
    return null;
  }

  // ---------------- GET ALL ----------------

  Future<List<Employe>> getAllEmployes() async {
    final db = await dbHelper.database;
    final employeMaps = await db.query(_tableEmployes);

    final List<Employe> employes = [];

    for (var eMap in employeMaps) {
      final id = eMap['id'] as String;
      final paiements = await getPaiementsByEmployeId(id);
      employes.add(_mapToEmploye(eMap, paiements));
    }

    return employes;
  }

  // ---------------- Mapping Helpers ----------------

  Map<String, dynamic> _employeToMap(Employe employe) {
    return {
      'id': employe.id,
      'nom': employe.nom,
      'prenom': employe.prenom,
      'dateNaissance': employe.dateNaissance.toIso8601String(),
      'dateEmbauche': employe.dateEmbauche.toIso8601String(),
      'poste': employe.poste,
      'salaire': employe.salaire,
      'telephone': employe.telephone,
      'adresse': employe.adresse,
      'estActif': employe.estActif ? 1 : 0,
      'photoUrl': employe.photoUrl,
    };
  }

  Map<String, dynamic> _paiementToMap(PaiementEmploye p, String employeId) {
    return {
      'employeId': employeId,
      'datePaiement': p.datePaiement.toIso8601String(),
      'mois': p.mois,
      'salaireBase': p.salaireBase,
      'prime': p.prime,
      'montantPaye': p.montantPaye,
      'statut': p.statut.name,
    };
  }

  Employe _mapToEmploye(
    Map<String, dynamic> map,
    List<PaiementEmploye> paiements,
  ) {
    return Employe(
      id: map['id'] as String? ?? '',
      nom: map['nom'] as String? ?? '',
      prenom: map['prenom'] as String? ?? '',
      dateNaissance: DateTime.parse(map['dateNaissance'] as String),
      dateEmbauche: DateTime.parse(map['dateEmbauche'] as String),
      poste: map['poste'] as String? ?? '',
      salaire: (map['salaire'] as num?)?.toDouble() ?? 0.0,
      telephone: map['telephone'] as String? ?? '',
      adresse: map['adresse'] as String? ?? '',
      estActif: (map['estActif'] as int?) == 1,
      photoUrl: map['photoUrl'] as String? ?? '',
      paiements: paiements,
    );
  }

  PaiementEmploye _mapToPaiementEmploye(Map<String, dynamic> e) {
    return PaiementEmploye(
      datePaiement: DateTime.parse(e['datePaiement'] as String),
      mois: e['mois'] as String? ?? '',
      salaireBase: (e['salaireBase'] as num?)?.toDouble() ?? 0.0,
      prime: (e['prime'] as num?)?.toDouble() ?? 0.0,
      montantPaye: (e['montantPaye'] as num?)?.toDouble() ?? 0.0,
      statut: (e['statut'] == 'paye')
          ? StatutPaiement.paye
          : StatutPaiement.impaye,
    );
  }
}
