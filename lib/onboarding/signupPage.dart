import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ ADDED

import 'homepage.dart';
import 'loginPage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final Color _primaryColor = const Color(0xFF4A6BFF);
  final Color _secondaryColor = const Color(0xFFFF6B6B);
  final Color _accentColor = const Color(0xFF00D4AA);
  final Color _backgroundGradientStart = const Color(0xFF667EEA);
  final Color _backgroundGradientEnd = const Color(0xFF764BA2);
  final Color _cardColor = Colors.white;
  final Color _textPrimary = const Color(0xFF1A1F36);
  final Color _textSecondary = const Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ---------------- FILE HELPERS ----------------
  Future<File> _getUserFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }

  Future<void> _saveUserLocally() async {
    final file = await _getUserFile();
    List users = [];

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) users = jsonDecode(content);
    }

    final emailExists =
    users.any((u) => u['email'] == _emailCtrl.text.trim());

    if (emailExists) throw 'Email already registered';

    users.add({
      "name": _nameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "password": _passwordCtrl.text.trim(),
    });

    await file.writeAsString(jsonEncode(users));
  }

  // ---------------- SIGNUP ----------------
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _saveUserLocally();

      // ✅ SESSION SAVE (MAIN FIX)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_name', _nameCtrl.text.trim());
      await prefs.setString('user_email', _emailCtrl.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signup successful! Welcome to AapDarthi!'),
          backgroundColor: _accentColor,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: _secondaryColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_backgroundGradientStart, _backgroundGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Join AapDarthi',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            decoration:
                            const InputDecoration(labelText: 'Full Name'),
                            validator: (v) =>
                            v == null || v.isEmpty ? 'Enter name' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailCtrl,
                            decoration:
                            const InputDecoration(labelText: 'Email'),
                            validator: (v) =>
                            v == null || v.isEmpty ? 'Enter email' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: true,
                            decoration:
                            const InputDecoration(labelText: 'Password'),
                            validator: (v) =>
                            v != null && v.length < 6
                                ? 'Min 6 chars'
                                : null,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signup,
                            child: Text(
                                _isLoading ? 'Creating...' : 'CREATE ACCOUNT'),
                          ),
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
    );
  }
}
