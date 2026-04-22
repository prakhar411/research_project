import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'homepage.dart';
import 'signupPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Modern color scheme
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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ---------------- VALIDATORS ----------------
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter email';
    final re = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!re.hasMatch(v.trim())) return 'Enter valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter password';
    if (v.length < 6) return 'Password too short';
    return null;
  }

  // ---------------- LOCAL FILE HELPERS ----------------
  Future<File> _getUserFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }

  // ---------------- LOGIN LOGIC ----------------
  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('logged_in_email', _emailCtrl.text.trim());

    setState(() => _isLoading = true);

    try {
      final file = await _getUserFile();

      if (!await file.exists()) {
        throw 'No users found. Please sign up first.';
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        throw 'No users found. Please sign up first.';
      }

      final List users = jsonDecode(content);

      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      final user = users.cast<Map<String, dynamic>>().firstWhere(
        (u) => u['email'] == email,
        orElse: () => {},
      );

      if (user.isEmpty) {
        throw 'Email not registered';
      }

      if (user['password'] != password) {
        throw 'Incorrect password';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Login successful! Welcome back!'),
            ],
          ),
          backgroundColor: _accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: _secondaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _goToSignup() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignupPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: Duration(milliseconds: 400),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_backgroundGradientStart, _backgroundGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Back button and header
                      Row(
                        children: [
                          // Container(
                          //   width: 48,
                          //   height: 48,
                          //   decoration: BoxDecoration(
                          //     color: Colors.white.withOpacity(0.1),
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          //   // child: IconButton(
                          //   //   onPressed: () => Navigator.pop(context),
                          //   //   icon: Icon(
                          //   //     Icons.arrow_back_rounded,
                          //   //     color: Colors.white,
                          //   //     size: 24,
                          //   //   ),
                          //   // ),
                          // ),
                          Spacer(),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.security_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      // Logo and title
                      Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            // child: Icon(
                            //   Icons.login_rounded,
                            //   color: Colors.white,
                            //   size: 60,
                            // ),
                            child: Image.asset(
                              'assets/logo.png', // Replace with your image asset path
                              height: 80,
                              width: 80,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback icon if image not found
                                return const Icon(
                                  Icons.health_and_safety,
                                  size: 60,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Sign in to continue your safety journey',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),

                      // Form card with animation
                      Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 40,
                                  spreadRadius: 0,
                                  offset: Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Login to AapDarthi',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Enter your credentials to access your account',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _textSecondary,
                                      ),
                                    ),

                                    SizedBox(height: 32),

                                    // Email field
                                    Text(
                                      'Email Address',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _emailCtrl,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your email',
                                          hintStyle: TextStyle(
                                            color: _textSecondary.withOpacity(
                                              0.6,
                                            ),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 18,
                                          ),
                                          prefixIcon: Container(
                                            margin: EdgeInsets.only(
                                              left: 16,
                                              right: 12,
                                            ),
                                            child: Icon(
                                              Icons.email_outlined,
                                              color: _primaryColor,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        validator: _validateEmail,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                    ),

                                    SizedBox(height: 24),

                                    // Password field
                                    Text(
                                      'Password',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _passwordCtrl,
                                        obscureText: _obscure,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your password',
                                          hintStyle: TextStyle(
                                            color: _textSecondary.withOpacity(
                                              0.6,
                                            ),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 18,
                                          ),
                                          prefixIcon: Container(
                                            margin: EdgeInsets.only(
                                              left: 16,
                                              right: 12,
                                            ),
                                            child: Icon(
                                              Icons.lock_outline_rounded,
                                              color: _primaryColor,
                                              size: 24,
                                            ),
                                          ),
                                          suffixIcon: Container(
                                            margin: EdgeInsets.only(right: 16),
                                            child: IconButton(
                                              icon: Icon(
                                                _obscure
                                                    ? Icons
                                                          .visibility_off_rounded
                                                    : Icons.visibility_rounded,
                                                color: _textSecondary
                                                    .withOpacity(0.6),
                                                size: 24,
                                              ),
                                              onPressed: () => setState(
                                                () => _obscure = !_obscure,
                                              ),
                                            ),
                                          ),
                                        ),
                                        validator: _validatePassword,
                                        onFieldSubmitted: (_) =>
                                            _isLoading ? null : _login(),
                                      ),
                                    ),

                                    SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          // Add forgot password functionality here
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Forgot password feature coming soon',
                                              ),
                                              backgroundColor: _primaryColor,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 40),

                                    // Login button
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            _primaryColor,
                                            Color(0xFF7A8EFF),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _primaryColor.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 20,
                                            spreadRadius: 0,
                                            offset: Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          onTap: _isLoading ? null : _login,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          splashColor: Colors.white.withOpacity(
                                            0.2,
                                          ),
                                          highlightColor: Colors.white
                                              .withOpacity(0.1),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 20,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (_isLoading)
                                                  SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                else
                                                  Icon(
                                                    Icons.login_rounded,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                SizedBox(width: 12),
                                                Text(
                                                  _isLoading
                                                      ? 'LOGGING IN...'
                                                      : 'LOG IN',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 32),

                                    // Divider with "or"
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey.withOpacity(0.3),
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Text(
                                            'OR',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey.withOpacity(0.3),
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 32),

                                    // Sign up redirect
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: _textSecondary,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _goToSignup,
                                          child: Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: _primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 16),

                                    // Quick login info
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: _accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _accentColor.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.verified_rounded,
                                            size: 20,
                                            color: _accentColor,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Your data is stored securely on your device',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: _textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // Footer
                      Text(
                        'AapDarthi - Your Safety Companion',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
