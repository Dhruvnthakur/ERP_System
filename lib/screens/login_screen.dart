// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'main_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController(text: 'admin');
  final _passwordCtrl = TextEditingController(text: 'admin123');
  bool _obscure = true;
  late AnimationController _anim;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _anim  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose(); _usernameCtrl.dispose(); _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffold()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Login failed'),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.mahogany,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
            colors: [AppTheme.espresso, AppTheme.mahogany, Color(0xFF4A2A1A)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo ────────────────────────────────────────────
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppTheme.white.withAlpha(40)),
                          boxShadow: [BoxShadow(
                            color: AppTheme.espresso.withAlpha(80),
                            blurRadius: 24, spreadRadius: 4,
                          )],
                        ),
                        child: const Icon(Icons.shopping_bag_rounded,
                            size: 52, color: AppTheme.white),
                      ),
                      const SizedBox(height: 24),
                      const Text('SoleERP',
                          style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2)),
                      const SizedBox(height: 6),
                      const Text('Shoes Factory Management System',
                          style: TextStyle(
                              color: AppTheme.beige, fontSize: 14)),
                      const SizedBox(height: 48),

                      // ── Login Card ──────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(
                            color: AppTheme.espresso.withAlpha(60),
                            blurRadius: 32, spreadRadius: 2,
                          )],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sign In',
                                  style: TextStyle(
                                      color: AppTheme.espresso,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              const Text('Access your dashboard',
                                  style: TextStyle(
                                      color: AppTheme.textMuted, fontSize: 13)),
                              const SizedBox(height: 24),

                              // info banner
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.pillBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: const Row(children: [
                                  Icon(Icons.info_outline_rounded,
                                      color: AppTheme.leather, size: 16),
                                  SizedBox(width: 8),
                                  Expanded(child: Text(
                                      'HR Manager or Supervisor login',
                                      style: TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 12))),
                                ]),
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                controller: _usernameCtrl,
                                style: const TextStyle(color: AppTheme.espresso),
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Username required' : null,
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscure,
                                style: const TextStyle(color: AppTheme.espresso),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure ? Icons.visibility_off
                                               : Icons.visibility,
                                      color: AppTheme.textFaint,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Password required' : null,
                                onFieldSubmitted: (_) => _login(),
                              ),
                              const SizedBox(height: 28),

                              SizedBox(
                                width: double.infinity, height: 52,
                                child: ElevatedButton(
                                  onPressed: auth.isLoading ? null : _login,
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          width: 20, height: 20,
                                          child: CircularProgressIndicator(
                                              color: AppTheme.white,
                                              strokeWidth: 2))
                                      : const Text('Sign In',
                                          style: TextStyle(fontSize: 16)),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Center(child: Text(
                                  'Default: admin / admin123',
                                  style: TextStyle(
                                      color: AppTheme.textFaint,
                                      fontSize: 11))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
