import 'package:flutter/material.dart';

class DisasterGuideline {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> dos;
  final List<String> donts;

  DisasterGuideline({
    required this.title,
    required this.icon,
    required this.color,
    required this.dos,
    required this.donts,
  });
}

class DosDontsTab extends StatelessWidget {
  DosDontsTab({super.key});

  final List<DisasterGuideline> guidelines = [
    DisasterGuideline(
      title: "Earthquake",
      icon: Icons.landscape,
      color: Colors.orange,
      dos: [
        "Drop, Cover, and Hold On under sturdy furniture",
        "Stay indoors until shaking stops",
        "Stay away from windows and glass doors",
        "If outside, move to open area away from buildings",
        "After shaking stops, check for injuries and gas leaks",
      ],
      donts: [
        "Do not use elevators during or after earthquake",
        "Do not run outside while building is shaking",
        "Do not stand under doorways (modern ones are not stronger)",
        "Avoid using matches or lighters in case of gas leak",
        "Do not re-enter damaged buildings",
      ],
    ),
    DisasterGuideline(
      title: "Flood",
      icon: Icons.water_damage,
      color: Colors.blue,
      dos: [
        "Move to higher ground immediately",
        "Follow evacuation orders without delay",
        "Turn off electricity at main switch",
        "Secure important documents in waterproof bags",
        "Listen to emergency radio for updates",
      ],
      donts: [
        "Do not walk or drive through flood waters",
        "Avoid contact with flood water (may be contaminated)",
        "Do not touch electrical equipment in wet areas",
        "Do not drink tap water until declared safe",
        "Avoid bridges over fast-moving water",
      ],
    ),
    DisasterGuideline(
      title: "Fire",
      icon: Icons.local_fire_department,
      color: Colors.red,
      dos: [
        "Crawl low under smoke to nearest exit",
        "Feel doors before opening (if hot, use another exit)",
        "Stop, Drop, and Roll if clothes catch fire",
        "Use fire extinguisher on small fires only",
        "Close doors behind you to slow fire spread",
      ],
      donts: [
        "Do not use elevators during fire",
        "Do not open doors that feel hot",
        "Avoid hiding in closets or under beds",
        "Do not go back for personal belongings",
        "Do not break windows unless necessary",
      ],
    ),
    DisasterGuideline(
      title: "Cyclone/Hurricane",
      icon: Icons.cyclone,
      color: Colors.purple,
      dos: [
        "Stay indoors in a windowless room",
        "Keep emergency kit ready",
        "Fill bathtub with water for sanitation",
        "Stay away from windows and glass doors",
        "Monitor weather alerts continuously",
      ],
      donts: [
        "Do not go outside during eye of storm",
        "Avoid using candles (risk of fire)",
        "Do not touch fallen power lines",
        "Avoid flooded areas and bridges",
        "Do not ignore evacuation orders",
      ],
    ),
    DisasterGuideline(
      title: "General Emergency",
      icon: Icons.emergency,
      color: Colors.green,
      dos: [
        "Follow official alerts and warnings",
        "Keep emergency supplies ready for 72 hours",
        "Help children, elderly, and disabled",
        "Evacuate immediately when instructed",
        "Stay informed through official channels",
      ],
      donts: [
        "Do not panic or spread rumors",
        "Do not ignore evacuation orders",
        "Avoid calling emergency lines for non-emergencies",
        "Do not use elevators during power outage",
        "Do not return home until authorities say it's safe",
      ],
    ),
    DisasterGuideline(
      title: "Landslide",
      icon: Icons.terrain,
      color: Colors.brown,
      dos: [
        "Move away from the path of landslide",
        "Listen for unusual sounds like trees cracking",
        "Go to the highest floor if inside building",
        "Watch for signs like doors/windows sticking",
        "Stay alert during heavy rainfall in prone areas",
      ],
      donts: [
        "Do not sleep during heavy rain in landslide areas",
        "Avoid building at base of steep slopes",
        "Do not ignore small slides (they may grow)",
        "Avoid driving in mountain areas during heavy rain",
        "Do not cross fresh landslide debris",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade700,
                  Colors.purple.shade600,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Emergency Guidelines",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Life-saving Do's & Don'ts for different disaster situations",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                // Stats Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.safety_check,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${guidelines.length} Disaster Types",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: guidelines.length,
                itemBuilder: (context, index) {
                  return _buildDisasterCard(guidelines[index], context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisasterCard(DisasterGuideline guideline, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: guideline.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            guideline.icon,
            color: guideline.color,
            size: 28,
          ),
        ),
        title: Text(
          guideline.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: guideline.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${guideline.dos.length + guideline.donts.length}",
                style: TextStyle(
                  color: guideline.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.tips_and_updates,
                color: guideline.color,
                size: 14,
              ),
            ],
          ),
        ),
        children: [
          // Do's Section
          _buildSection(
            title: "DO'S",
            items: guideline.dos,
            icon: Icons.check_circle,
            color: Colors.green,
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: Colors.grey.shade300,
              height: 20,
            ),
          ),

          // Don'ts Section
          _buildSection(
            title: "DON'TS",
            items: guideline.donts,
            icon: Icons.cancel,
            color: Colors.red,
          ),

          // Emergency Contacts Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () {
                // Add emergency contact functionality
              },
              icon: Icon(
                Icons.phone,
                color: guideline.color,
              ),
              label: Text(
                "View Emergency Contacts",
                style: TextStyle(
                  color: guideline.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: guideline.color),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...items.map((item) => _buildGuidelineItem(item, color)).toList(),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}