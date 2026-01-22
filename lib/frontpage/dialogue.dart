import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class DialogueBox extends StatefulWidget {
  const DialogueBox({super.key, Position? position});

  @override
  State<DialogueBox> createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> with SingleTickerProviderStateMixin {
  Position? _position;
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Color scheme
  final Color _primaryColor = const Color(0xFF4A6BFF);
  final Color _emergencyRed = const Color(0xFFFF4757);
  final Color _backgroundGradientStart = const Color(0xFFF8FAFF);
  final Color _backgroundGradientEnd = const Color(0xFFEFF4FF);
  final Color _cardColor = Colors.white;
  final Color _textPrimary = const Color(0xFF1A1F36);
  final Color _textSecondary = const Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    _fetchLocation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permission denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        _position = position;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Failed to fetch location');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String locationUrl = _position != null
        ? 'https://www.google.com/maps?q=${_position!.latitude},${_position!.longitude}'
        : 'Location not available';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_backgroundGradientStart, _backgroundGradientEnd],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_emergencyRed, const Color(0xFFFF6B6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EMERGENCY ASSISTANCE',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select Emergency Type',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Location info
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: _primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _isLoading
                                  ? SizedBox(
                                height: 20,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Fetching location...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : SelectableText(
                                _position != null
                                    ? '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}'
                                    : 'Location not available',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _primaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: _primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap any emergency type to send your location via SMS',
                              style: TextStyle(
                                fontSize: 13,
                                color: _primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Emergency grid
              Expanded(
                child: _isLoading
                    ? const SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _buildAllGridItems().length,
                    itemBuilder: (context, index) {
                      return _buildAllGridItems()[index];
                    },
                  ),
                ),
              ),

              // Footer with close button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Emergency services will be contacted',
                        style: TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cardColor,
                        foregroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: _primaryColor.withOpacity(0.2)),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAllGridItems() {
    final emergencies = [
      {'title': 'SOS', 'icon': Icons.warning_amber_rounded, 'color': _emergencyRed},
      {'title': 'Earthquake', 'icon': Icons.public, 'color': const Color(0xFFFF9F43)},
      {'title': 'Tsunami', 'icon': Icons.waves, 'color': const Color(0xFF2E86DE)},
      {'title': 'Floods', 'icon': Icons.water_damage_rounded, 'color': const Color(0xFF0ABDE3)},
      {'title': 'Fire', 'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFFF6B6B)},
      {'title': 'Transportation', 'icon': Icons.directions_car_rounded, 'color': const Color(0xFF1DD1A1)},
      {'title': 'Explosion', 'icon': Icons.flash_on_rounded, 'color': const Color(0xFFF9CA24)},
      {'title': 'Landslide', 'icon': Icons.terrain, 'color': const Color(0xFFA55EEA)},
      {'title': 'Hurricane', 'icon': Icons.storm, 'color': const Color(0xFF5F27CD)},
      {'title': 'Volcanic', 'icon': Icons.landscape, 'color': const Color(0xFFFF9FF3)},
      {'title': 'Chemical', 'icon': Icons.science_rounded, 'color': const Color(0xFF00D2D3)},
      {'title': 'Nuclear', 'icon': Icons.smoke_free, 'color': const Color(0xFFFD79A8)},
      {'title': 'Tornado', 'icon': Icons.cyclone_rounded, 'color': const Color(0xFF341F97)},
      {'title': 'Power Outage', 'icon': Icons.power_off_rounded, 'color': const Color(0xFF8395A7)},
      {'title': 'Pandemic', 'icon': Icons.medical_services_rounded, 'color': const Color(0xFF9B59B6)},
      {'title': 'Drought', 'icon': Icons.wb_sunny_rounded, 'color': const Color(0xFFFECA57)},
      {'title': 'Extreme Heat', 'icon': Icons.thermostat_rounded, 'color': const Color(0xFFFF7979)},
      {'title': 'Blizzard', 'icon': Icons.ac_unit_rounded, 'color': const Color(0xFF54A0FF)},
      {'title': 'Cyber Attack', 'icon': Icons.security_rounded, 'color': const Color(0xFF576574)},
    ];

    return emergencies.map((emergency) {
      return _buildGridItem(
        emergency['title'] as String,
        emergency['icon'] as IconData,
        emergency['color'] as Color,
      );
    }).toList();
  }

  Widget _buildGridItem(String title, IconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_position != null) {
            _sendSmsWithLocation(title);
          } else {
            _showSnackBar('Location not available');
          }
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Background accent
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            Color.lerp(color, Colors.white, 0.2)!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'TAP FOR HELP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Emergency indicator for SOS
              if (title == 'SOS')
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _emergencyRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _emergencyRed.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendSmsWithLocation(String disasterType) async {
    final String phoneNumber =
    disasterType == 'SOS' ? '9129979433' : '6307876246';

    final String message = _position != null
        ? (disasterType == 'SOS'
        ? 'SOS! I am in danger. My location: https://www.google.com/maps?q=${_position!.latitude},${_position!.longitude}'
        : 'I need assistance. Location: https://www.google.com/maps?q=${_position!.latitude},${_position!.longitude}. Incident: $disasterType')
        : 'Location not available. Incident: $disasterType';

    try {
      if (Platform.isAndroid) {
        final Uri smsUri = Uri.parse(
          'smsto:$phoneNumber?body=${Uri.encodeComponent(message)}',
        );

        await launchUrl(
          smsUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      // iOS fallback
      final Uri iosSms = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      await launchUrl(iosSms, mode: LaunchMode.externalApplication);
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: message));
      _showSnackBar('Message copied. Please paste it into SMS or WhatsApp.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: _emergencyRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}