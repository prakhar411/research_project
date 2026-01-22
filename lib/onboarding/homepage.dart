import 'package:flutter/material.dart';
import 'package:research_project/frontpage/dialogue.dart';
import 'package:research_project/tabs/profile_tab.dart';
import '../chatBot/chat_screen.dart';
import '../chatBot/gemini_chat_screen.dart';
import '../screens/disaster_weather_Screen.dart';
import '../screens/verify_screen.dart';
import '../tabs/dos_donts_tab.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomeContent(),
      _buildDosDontsContent(),
      _buildDonationContent(),
      _buildProfileContent(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),

      // ================= APP BAR =================
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A00E0), Color(0xFF00BCD4)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.security, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'AAPDARTHI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A237E),
              ),
            ),
          ],
        ),
        actions: [
          _appBarIcon(
            icon: Icons.thunderstorm,
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
            icon: Icons.emergency,
            color: const Color(0xFFD32F2F),
            bg: const Color(0xFFFFF0F0),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const DialogueBox(),
              );
            },
          ),
        ],
      ),

      // ================= BODY =================
      body: _pages[_selectedIndex],

      // ================= FAB =================
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A00E0),
        focusColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_)=>VerifyScreen())
            // MaterialPageRoute(builder: (_) => RakshaChatScreen()),
          );
        },
        child: const Icon(Icons.auto_awesome,color: Colors.white,),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomAppBar(
        height: 80,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_filled, "Home", 0),
              _buildNavItem(Icons.checklist_rounded, "Do's", 1),
              const SizedBox(width: 60),
              _buildNavItem(Icons.volunteer_activism, "Donate", 2),
              _buildNavItem(Icons.person_rounded, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  // ================= NAV ITEM =================
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF4A00E0)
                  : const Color(0xFF9E9E9E),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF4A00E0)
                      : const Color(0xFF9E9E9E),
                ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // HERO CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Alert. Stay Safe.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Real-time disaster alerts, instant help, and AI guidance.',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ================= EMERGENCY ACTIONS =================
          const Text(
            'Emergency Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.15,
            children: [
              _actionCard(
                icon: Icons.thunderstorm,
                title: 'Weather Alerts',
                subtitle: 'Live risk updates',
                color: const Color(0xFF1976D2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DisasterWeatherScreen(),
                    ),
                  );
                },
              ),
              _actionCard(
                icon: Icons.emergency,
                title: 'Instant Help',
                subtitle: 'SOS & contacts',
                color: const Color(0xFFD32F2F),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const DialogueBox(),
                  );
                },
              ),
              _actionCard(
                icon: Icons.auto_awesome,
                title: 'AI Assistant',
                subtitle: 'Get guidance',
                color: const Color(0xFF4A00E0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GeminiChatScreen(),
                    ),
                  );
                },
              ),
              _actionCard(
                icon: Icons.menu_book,
                title: 'Safety Guide',
                subtitle: 'Do’s & Don’ts',
                color: const Color(0xFF00897B),
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ================= ACTIVE ALERTS =================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Alerts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 12),
                _alertRow('Heavy Rainfall Warning', 'Active', Colors.orange),
                _alertRow('Cyclone Watch', 'Monitoring', Colors.red),
                _alertRow('Heatwave Advisory', 'Advisory', Colors.blue),
              ],
            ),
          ),

          const SizedBox(height: 28),

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
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  '100+',
                  'Rescue Teams',
                  Icons.groups,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ACTION CARD =================
  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SMALL WIDGETS =================
  Widget _alertRow(String title, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A00E0)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style:
                TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= OTHER PAGES =================
  Widget _buildDosDontsContent() =>  DosDontsTab();


  Widget _buildDonationContent() =>
      const Center(child: Text("Donation Hub"));

  Widget _buildProfileContent() => ProfilePage();

  Widget _appBarIcon({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onTap,
      ),
    );
  }
}
