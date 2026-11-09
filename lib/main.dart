import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'db/database_helper.dart';
import 'services/trial_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop SQLite initialization — must happen first
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Open/create database
  await DatabaseHelper.instance.database;

  // Initialize French date formatting
  await initializeDateFormatting('fr_FR', null);

  // Verify 4-day trial status across Windows Registry, AppData hidden system file & DB
  final trialResult = await TrialService.checkTrialStatus();

  runApp(CrecheManagerApp(trialResult: trialResult));
}

class CrecheManagerApp extends StatelessWidget {
  final TrialResult trialResult;

  const CrecheManagerApp({super.key, required this.trialResult});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crèche Manager',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: trialResult.shouldClose
          ? TrialExpiredScreen(trialResult: trialResult)
          : const LoginScreen(),
      routes: {
        "/login": (context) => const LoginScreen(),
        "/dashboard": (context) => DashboardPage(),
      },
    );
  }
}

class TrialExpiredScreen extends StatelessWidget {
  final TrialResult trialResult;

  const TrialExpiredScreen({super.key, required this.trialResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D44),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_off_rounded,
                size: 72,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                "Période d'essai expirée",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                trialResult.warningMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    exit(0);
                  },
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text(
                    "Fermer l'application",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}