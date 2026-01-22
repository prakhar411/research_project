import 'package:flutter/material.dart';
import 'gemini_service.dart';

/// -------------------------------
/// EMERGENCY DETECTION LOGIC
/// -------------------------------
bool isEmergencyMessage(String text) {
  final emergencyKeywords = [
    "trapped",
    "fire",
    "burning",
    "flood",
    "water rising",
    "earthquake",
    "collapsed",
    "bleeding",
    "unconscious",
    "not breathing",
    "help",
    "emergency",
  ];

  final lowerText = text.toLowerCase();
  return emergencyKeywords.any((word) => lowerText.contains(word));
}

/// -------------------------------
/// RAKSHA CHAT SCREEN
/// -------------------------------
class RakshaChatScreen extends StatefulWidget {
  const RakshaChatScreen({super.key});

  @override
  State<RakshaChatScreen> createState() => _RakshaChatScreenState();
}

class _RakshaChatScreenState extends State<RakshaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();

  final List<Map<String, String>> messages = [];
  bool isLoading = false;

  /// -------------------------------
  /// SEND MESSAGE FLOW
  /// -------------------------------
  void sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();
    _controller.clear();

    setState(() {
      messages.add({"role": "user", "text": userText});
      isLoading = true;
    });

    final emergencyDetected = isEmergencyMessage(userText);

    final response = await _geminiService.sendMessage(userText);

    setState(() {
      messages.add({"role": "raksha", "text": response});
      isLoading = false;
    });

    if (emergencyDetected) {
      showEmergencyActions();
    }
  }

  /// -------------------------------
  /// EMERGENCY ACTION SHEET
  /// -------------------------------
  void showEmergencyActions() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.red[50],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                "Emergency Detected",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "If this is life-threatening, contact emergency services immediately.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.call),
                label: const Text("Call Emergency Services"),
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: integrate call logic (112 / 911)
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.sos),
                label: const Text("Send SOS Alert"),
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: integrate SOS logic
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// -------------------------------
  /// MESSAGE BUBBLES
  /// -------------------------------
  Widget userBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget rakshaBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🛡️ RAKSHA",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 6),
            Text(text, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  /// -------------------------------
  /// UI
  /// -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.shield, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "RAKSHA",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(32),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "Disaster Response Assistant",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final msg = messages[index];
                return msg["role"] == "user"
                    ? userBubble(msg["text"]!)
                    : rakshaBubble(msg["text"]!);
              },
            ),
          ),

          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: const [
                  SizedBox(width: 16),
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 12),
                  Text("RAKSHA is analyzing the situation..."),
                ],
              ),
            ),

          /// INPUT BAR
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Describe your emergency or situation",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue[900],
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
