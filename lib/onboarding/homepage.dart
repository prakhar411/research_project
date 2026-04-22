import 'dart:io';
import 'package:flutter/material.dart';
import 'package:research_project/frontpage/dialogue.dart';
import 'package:research_project/screens/raksha_chat_screen.dart';
import 'package:research_project/tabs/profile_tab.dart';
import '../screens/disaster_weather_Screen.dart';
import '../screens/verify_screen.dart';
import '../tabs/dos_donts_tab.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomeContent(),
      _buildDosDontsContent(),
      VerifyScreen(),
      _buildProfileContent(),
    ];
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Image Picker Error: $e");
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_controller.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add details or image")),
      );
      return;
    }

    // Temporary success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report submitted successfully")),
    );

    // Clear data
    setState(() {
      _controller.clear();
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      // ================= APP BAR =================
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset('assets/logo.png', width: 42, height: 42),
            ),
            const SizedBox(width: 12),
            const Text(
              'AAPDARTHI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF1A237E),
              ),
            ),
          ],
        ),
        actions: [
          _appBarIcon(
            icon: Icons.cloud,
            color: const Color(0xFF1976D2),
            bg: const Color(0xFFE8F4FF),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DisasterWeatherScreen(),
                ),
              );
            },
          ),
          _appBarIcon(
            icon: Icons.auto_awesome,
            color: const Color(0xFFD32F2F),
            bg: const Color(0xFFFFF0F0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RakshaChatScreen()),
              );
            },
          ),
        ],
      ),

      // ================= BODY =================
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_selectedIndex],
      ),

      // ================= FAB =================
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A00E0),
        elevation: 4,
        highlightElevation: 8,
        onPressed: () {
          showDialog(context: context, builder: (_) => const DialogueBox());
        },
        child: const Icon(Icons.warning, color: Colors.white),
      ),

      // ================= BOTTOM NAV (Fixed Overflow) =================
      bottomNavigationBar: BottomAppBar(
        height: 90, // Increased to give more room
        shape: const CircularNotchedRectangle(),
        notchMargin: 12,
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildNavItem(Icons.home_filled, "Home", 0)),
              Expanded(
                child: _buildNavItem(Icons.checklist_rounded, "Do's", 1),
              ),
              const SizedBox(width: 50), // space for FAB
              Expanded(child: _buildNavItem(Icons.fact_check, "Verify", 2)),
              Expanded(
                child: _buildNavItem(Icons.person_rounded, "Profile", 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= NAV ITEM (Resized to avoid overflow) =================
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ), // reduced vertical padding
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A00E0).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF4A00E0)
                  : const Color(0xFF9E9E9E),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF4A00E0)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HOME PAGE =================
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HERO CARD
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A00E0).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Alert.\nStay Safe.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Real-time disaster alerts, instant help, and AI guidance.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ================= REPORT INCIDENT =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Report Incident',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A237E),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4A00E0),
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildReportIncidentCard(),

          const SizedBox(height: 20),

          // ================= CHECK FAKE NEWS =================

          // ================= STATS =================
          Row(
            children: [
              Expanded(
                child: _statCard(
                  '24/7',
                  'Emergency Support',
                  Icons.support_agent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _statCard('100+', 'Rescue Teams', Icons.groups)),
            ],
          ),
        ],
      ),
    );
  }

  // ================= REPORT INCIDENT CARD =================
  Widget _buildReportIncidentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            maxLines: 6,
            minLines: 4,
            decoration: InputDecoration(
              hintText: "Describe the incident...",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF4A00E0),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedImage != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showImageSourcePicker,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text("Add Photo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F4FF),
                    foregroundColor: const Color(0xFF1976D2),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.mic, size: 18),
                  label: const Text("Voice"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF0F0),
                    foregroundColor: const Color(0xFFD32F2F),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A00E0),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text("Submit Report"),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FAKE NEWS NAVIGATION =================
  // Widget _buildFakeNewsNavigation() {
  //   return InkWell(
  //     borderRadius: BorderRadius.circular(20),
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (_) => VerifyScreen()),
  //       );
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [Colors.white, const Color(0xFFF8FAFF)],
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ),
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(color: Colors.grey.shade100),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.02),
  //             blurRadius: 12,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFF4A00E0).withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(14),
  //             ),
  //             child: const Icon(
  //               Icons.fact_check,
  //               color: Color(0xFF4A00E0),
  //               size: 28,
  //             ),
  //           ),
  //           const SizedBox(width: 16),
  //           const Expanded(
  //             child: Text(
  //               "Check Fake News",
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: Color(0xFF1A237E),
  //               ),
  //             ),
  //           ),
  //           const Icon(
  //             Icons.arrow_forward_ios,
  //             size: 16,
  //             color: Color(0xFF9E9E9E),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // // ================= STAT CARD =================
  Widget _statCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A00E0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF4A00E0), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A237E),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= OTHER PAGES =================
  Widget _buildDosDontsContent() => DosDontsTab();
  // Widget _buildDonationContent() => const Center(child: Text("Comming Soon!"));
  Widget _buildProfileContent() => ProfilePage();

  Widget _appBarIcon({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onTap,
        splashRadius: 24,
      ),
    );
  }
}
