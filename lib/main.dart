// lib/main.dart  (updated for Supabase)
//
// Replace your existing lib/main.dart with this file.
// The only change from the original is the Supabase.initialize() call.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'services/database_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Supabase init ─────────────────────────────────────────────────────────
  await Supabase.initialize(
    url:     DatabaseService.supabaseUrl,
    anonKey: DatabaseService.supabaseAnonKey,
  );

  runApp(const SoleERPApp());
}

class SoleERPApp extends StatelessWidget {
  const SoleERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'SoleERP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
