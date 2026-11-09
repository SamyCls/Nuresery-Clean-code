import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';

class StatsRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Total revenue including full and partial payments (0: payé, 2: partiel)
  Future<double> getTotalRevenue() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery('''
        SELECT SUM(montantPaye) as total 
        FROM paiements 
        WHERE statut IN (0, 2)
      ''');

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('Error in getTotalRevenue: $e');
      return 0.0;
    }
  }

  // Current month revenue
  Future<double> getCurrentMonthRevenue() async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now();
      final currentMonthYear =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';

      final result = await db.rawQuery(
        '''
        SELECT SUM(montantPaye) as total 
        FROM paiements 
        WHERE substr(date, 1, 7) = ? 
        AND statut IN (0, 2)
      ''',
        [currentMonthYear],
      );

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('Error in getCurrentMonthRevenue: $e');
      return 0.0;
    }
  }

  // Total expenses
  Future<double> getTotalExpenses() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery('''
        SELECT SUM(montant) as total FROM depenses
      ''');
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('Error in getTotalExpenses: $e');
      return 0.0;
    }
  }

  // Current month expenses
  Future<double> getCurrentMonthExpenses() async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now();
      final currentMonthYear =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';

      final result = await db.rawQuery(
        '''
        SELECT SUM(montant) as total 
        FROM depenses 
        WHERE substr(date, 1, 7) = ?
      ''',
        [currentMonthYear],
      );

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('Error in getCurrentMonthExpenses: $e');
      return 0.0;
    }
  }

  // Expenses grouped by category
  Future<Map<String, double>> getExpensesByCategory() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery('''
        SELECT categorie, SUM(montant) as total 
        FROM depenses 
        GROUP BY categorie
      ''');

      final Map<String, double> expensesByCategory = {};
      for (var row in result) {
        expensesByCategory[row['categorie'] as String] = (row['total'] as num)
            .toDouble();
      }
      return expensesByCategory;
    } catch (e) {
      debugPrint('Error in getExpensesByCategory: $e');
      return {};
    }
  }

  // Payment status distribution percentage
  Future<Map<String, double>> getPaymentStatusDistribution() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN statut = 0 THEN 1 ELSE 0 END) as paye,
          SUM(CASE WHEN statut = 2 THEN 1 ELSE 0 END) as partiel,
          SUM(CASE WHEN statut = 1 THEN 1 ELSE 0 END) as impaye
        FROM paiements
      ''');

      final row = result.first;
      final int total = (row['total'] as num?)?.toInt() ?? 0;
      final int paye = (row['paye'] as num?)?.toInt() ?? 0;
      final int partiel = (row['partiel'] as num?)?.toInt() ?? 0;
      final int impaye = (row['impaye'] as num?)?.toInt() ?? 0;

      if (total == 0) return {"Payés": 0, "Partiels": 0, "Impayés": 0};

      return {
        "Payés": (paye / total * 100),
        "Partiels": (partiel / total * 100),
        "Impayés": (impaye / total * 100),
      };
    } catch (e) {
      debugPrint('Error in getPaymentStatusDistribution: $e');
      return {"Payés": 0, "Partiels": 0, "Impayés": 0};
    }
  }

  // Monthly revenue spots for graph
  Future<List<FlSpot>> getRevenueByMonth(int year) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT 
          substr(date, 6, 2) as month,
          SUM(montantPaye) as total
        FROM paiements 
        WHERE substr(date, 1, 4) = ?
        AND statut IN (0, 2)
        GROUP BY substr(date, 6, 2)
        ORDER BY month
      ''',
        [year.toString()],
      );

      return _buildMonthlySpots(result);
    } catch (e) {
      debugPrint('Error in getRevenueByMonth: $e');
      return List.generate(12, (index) => FlSpot(index.toDouble(), 0));
    }
  }

  Future<double> getMonthRevenue(int year, int month) async {
    try {
      final db = await _databaseHelper.database;
      final monthYear = '$year-${month.toString().padLeft(2, '0')}';

      final result = await db.rawQuery(
        '''
        SELECT SUM(montantPaye) as total 
        FROM paiements 
        WHERE substr(date, 1, 7) = ? 
        AND statut IN (0, 2)
      ''',
        [monthYear],
      );

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('Error in getMonthRevenue: $e');
      return 0.0;
    }
  }

  Future<double> getMonthExpenses(int year, int month) async {
    try {
      final db = await _databaseHelper.database;
      final monthYear = '$year-${month.toString().padLeft(2, '0')}';

      final result = await db.rawQuery(
        '''
        SELECT SUM(montant) as total 
        FROM depenses 
        WHERE substr(date, 1, 7) = ?
      ''',
        [monthYear],
      );

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('Error in getMonthExpenses: $e');
      return 0.0;
    }
  }

  Future<Map<String, double>> getExpensesByCategoryForMonth(
    int year,
    int month,
  ) async {
    try {
      final db = await _databaseHelper.database;
      final monthYear = '$year-${month.toString().padLeft(2, '0')}';

      final result = await db.rawQuery(
        '''
        SELECT categorie, SUM(montant) as total 
        FROM depenses 
        WHERE substr(date, 1, 7) = ?
        GROUP BY categorie
      ''',
        [monthYear],
      );

      final Map<String, double> expensesByCategory = {};
      for (var row in result) {
        expensesByCategory[row['categorie'] as String] = (row['total'] as num)
            .toDouble();
      }
      return expensesByCategory;
    } catch (e) {
      debugPrint('Error in getExpensesByCategoryForMonth: $e');
      return {};
    }
  }

  Future<List<FlSpot>> getExpensesByMonth(int year) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT
          substr(date, 6, 2) as month,
          SUM(montant) as total
        FROM depenses
        WHERE substr(date, 1, 4) = ?
        GROUP BY substr(date, 6, 2)
        ORDER BY month
      ''',
        [year.toString()],
      );

      return _buildMonthlySpots(result);
    } catch (e) {
      debugPrint('Error in getExpensesByMonth: $e');
      return List.generate(12, (i) => FlSpot(i.toDouble(), 0));
    }
  }

  Future<List<int>> getAvailableYears() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery('''
        SELECT DISTINCT substr(date, 1, 4) as year 
        FROM paiements 
        ORDER by year DESC
      ''');

      final years = result.map((row) {
        final yearStr = row['year'] as String?;
        return int.tryParse(yearStr ?? '') ?? DateTime.now().year;
      }).toList();

      final currentYear = DateTime.now().year;
      if (!years.contains(currentYear)) {
        years.insert(0, currentYear);
      }

      return years;
    } catch (e) {
      debugPrint('Error in getAvailableYears: $e');
      return [DateTime.now().year];
    }
  }

  List<FlSpot> _buildMonthlySpots(List<Map<String, Object?>> queryResult) {
    final List<FlSpot> spots = List.generate(
      12,
      (index) => FlSpot(index.toDouble(), 0),
    );

    for (var row in queryResult) {
      final monthStr = row['month'] as String?;
      final month = int.tryParse(monthStr ?? '') ?? 1;
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      if (month >= 1 && month <= 12) {
        spots[month - 1] = FlSpot((month - 1).toDouble(), total);
      }
    }

    return spots;
  }
}
