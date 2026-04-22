import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../onboarding/homepage.dart';
import '../onboarding/signupPage.dart';
import '../services/auth_service.dart';
import 'dialogue.dart';

class Frontpage extends StatefulWidget {
  const Frontpage({super.key});

  @override
  State<Frontpage> createState() => _FrontpageState();
}

class _FrontpageState extends State<Frontpage>
    with SingleTickerProviderStateMixin {
  Position? _currentPosition;
  bool _isFetching = false;
  bool _checkingAuth = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  // Modern color scheme
  final Color _primaryColor = const Color(0xFF4A6BFF); // Vibrant blue
  final Color _secondaryColor = const Color(
    0xFFFF6B6B,
  ); // Coral red for emergency
  final Color _accentColor = const Color(0xFF00D4AA); // Teal accent
  final Color _backgroundColor = const Color(
    0xFFF8FAFF,
  ); // Light blue background
  final Color _surfaceColor = Colors.white;
  final Color _textPrimary = const Color(0xFF1A1F36);
  final Color _textSecondary = const Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation =
        TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: 1.05),
            weight: 50,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.05, end: 1.0),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _pulseAnimation =
        TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.5, end: 1.0),
            weight: 50,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: 0.5),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// ===============================
  /// LOCATION FETCH — USER TRIGGERED ONLY
  /// ===============================
  Future<void> _fetchAndStoreLocation({required bool showDialog}) async {
    try {
      // Check for location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location services are disabled'),
            backgroundColor: _secondaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permissions are denied'),
              backgroundColor: _secondaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
      }

      // Fetch the current location
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      _showLocationDialog(); // Show the dialog with the location information
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching location: $e'),
          backgroundColor: _secondaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      print('Error fetching location: $e');
    }
  }

  void _showLocationDialog() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DialogueBox(position: _currentPosition),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  void _showSnack(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _primaryColor,
      ),
    );
  }

  /// ===============================
  /// AUTH FLOW
  /// ===============================
  Future<void> _onAuthButtonPressed() async {
    setState(() => _checkingAuth = true);

    try {
      final hasLocal = await AuthService.hasToken();

      if (hasLocal) {
        final isValid = await AuthService.verifyTokenWithServer();
        if (isValid && mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomePage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
              transitionDuration: Duration(milliseconds: 400),
            ),
          );
          return;
        }
        await AuthService.removeToken();
      }

      if (mounted) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SignupPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
            transitionDuration: Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      _showSnack('Authentication error. Please try again.');
    } finally {
      if (mounted) setState(() => _checkingAuth = false);
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, Color(0xFF7A8EFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.security_rounded, color: Colors.white, size: 28),
          ),
          Column(
            children: [
              Text(
                'AapDarthi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Your Safety Companion',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.help_outline_rounded,
                color: _primaryColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulse ring
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 200 * _pulseAnimation.value,
              height: 200 * _pulseAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryColor.withOpacity(0.1 * _pulseAnimation.value),
              ),
            );
          },
        ),
        // Main icon container
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_primaryColor, Color(0xFF7A8EFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Inner circle
                    Container(
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          radius: 0.8,
                        ),
                      ),
                    ),
                    // Location icon
                    Center(
                      child: Icon(
                        Icons.location_pin,
                        size: 70,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    // Animated dots
                    ...List.generate(3, (index) {
                      return Positioned(
                        top: 20 + (index * 40),
                        left: 20,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(icon, style: TextStyle(fontSize: 24))),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: _textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    _buildLocationIcon(),

                    SizedBox(height: 40),

                    // Main headline
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Your Safety,\n",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(
                            text: "Our Priority",
                            style: TextStyle(color: _primaryColor),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      "Get instant help with your location.\nFast, reliable, and always available.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _textSecondary,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 40),

                    // Feature cards
                    // Column(
                    //   children: [
                    //     _buildFeatureCard("🚨", "Emergency Response", "Get help instantly with location sharing"),
                    //     SizedBox(height: 16),
                    //     _buildFeatureCard("📍", "Live Tracking", "Share real-time location with trusted contacts"),
                    //     SizedBox(height: 16),
                    //     _buildFeatureCard("👥", "Community Alert", "Alert nearby users in emergencies"),
                    //   ],
                    // ),
                    SizedBox(height: 40),

                    // Action buttons
                    Column(
                      children: [
                        // Instant Help Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [_secondaryColor, Color(0xFFFF8E8E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _secondaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: _isFetching
                                  ? null
                                  : () => _fetchAndStoreLocation(
                                      showDialog: true,
                                    ),
                              borderRadius: BorderRadius.circular(20),
                              splashColor: Colors.white.withOpacity(0.2),
                              highlightColor: Colors.white.withOpacity(0.1),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 24,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _isFetching
                                        ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Icon(
                                            Icons.emergency_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                    SizedBox(width: 12),
                                    Text(
                                      _isFetching
                                          ? "Fetching Location..."
                                          : "GET INSTANT HELP",
                                      style: TextStyle(
                                        fontSize: 18,
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

                        SizedBox(height: 20),

                        // Login/Signup Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _surfaceColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                spreadRadius: 0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: _checkingAuth
                                  ? null
                                  : _onAuthButtonPressed,
                              borderRadius: BorderRadius.circular(20),
                              splashColor: _primaryColor.withOpacity(0.1),
                              highlightColor: _primaryColor.withOpacity(0.05),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 24,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_checkingAuth)
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _primaryColor,
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.person_add_alt_1_rounded,
                                        color: _primaryColor,
                                        size: 28,
                                      ),
                                    SizedBox(width: 12),
                                    Text(
                                      _checkingAuth ? "Checking..." : "LOGIN",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: _primaryColor,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 30),

                        // Location Status
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _currentPosition != null
                                          ? _accentColor.withOpacity(0.1)
                                          : _textSecondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.location_searching_rounded,
                                      color: _currentPosition != null
                                          ? _accentColor
                                          : _textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _currentPosition != null
                                              ? "Location Available"
                                              : "Location Not Fetched",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          _currentPosition != null
                                              ? "${_currentPosition!.latitude.toStringAsFixed(5)}, "
                                                    "${_currentPosition!.longitude.toStringAsFixed(5)}"
                                              : "Tap 'GET INSTANT HELP' to fetch location",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _currentPosition != null
                                                ? _accentColor
                                                : _textSecondary,
                                            fontWeight: _currentPosition != null
                                                ? FontWeight.w500
                                                : null,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (_currentPosition != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text(
                                    "✅ Location ready for emergency use",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _accentColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Footer note
                        Text(
                          "In case of emergency, tap the red button above",
                          style: TextStyle(fontSize: 13, color: _textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
