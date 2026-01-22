import 'package:flutter/material.dart';
import '../services/fake_news_service.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedDisaster = "Fire";
  DateTime? _selectedDate;

  bool _loading = false;
  Map<String, dynamic>? result;

  final List<String> disasters = [
    "Fire",
    "Flood",
    "Earthquake",
    "Explosion",
    "Cyclone",
    "Landslide",
    "Accident",
    "Other",
  ];

  // Disaster icons mapping
  final Map<String, IconData> disasterIcons = {
    "Fire": Icons.local_fire_department,
    "Flood": Icons.water_damage,
    "Earthquake": Icons.landscape,
    "Explosion": Icons.fireplace,
    "Cyclone": Icons.cyclone,
    "Landslide": Icons.terrain,
    "Accident": Icons.car_crash,
    "Other": Icons.warning,
  };

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void verify() async {
    if (_locationController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all fields"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      result = null;
    });

    try {
      final payload = {
        "disaster_type": _selectedDisaster.toLowerCase(),
        "location": _locationController.text,
        "event_date": _selectedDate!.toIso8601String().split("T").first,
        "description": _descriptionController.text,
      };

      final res = await VerificationService.verifyStructured(payload);

      setState(() {
        result = res;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to verify. Please try again."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Color getColor(String color) {
    switch (color) {
      case "green":
        return Colors.green.shade700;
      case "light_green":
        return Colors.lightGreen.shade700;
      case "orange":
        return Colors.orange.shade700;
      case "grey":
        return Colors.grey.shade700;
      default:
        return Colors.blueGrey.shade700;
    }
  }

  Color getBackgroundColor(String color) {
    switch (color) {
      case "green":
        return Colors.green.shade50;
      case "light_green":
        return Colors.lightGreen.shade50;
      case "orange":
        return Colors.orange.shade50;
      case "grey":
        return Colors.grey.shade50;
      default:
        return Colors.blueGrey.shade50;
    }
  }

  IconData getStatusIcon(String label) {
    switch (label.toLowerCase()) {
      case "verified":
        return Icons.verified;
      case "likely true":
        return Icons.thumb_up;
      case "unverified":
        return Icons.question_mark;
      case "likely false":
        return Icons.thumb_down;
      case "false":
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Disaster Verification",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Verify Disaster Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter details about the disaster event to verify its authenticity",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Form Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disaster Type
                    Text(
                      "Disaster Type",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDisaster,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: disasters
                                .map((d) => DropdownMenuItem(
                              value: d,
                              child: Row(
                                children: [
                                  Icon(
                                    disasterIcons[d],
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(d),
                                ],
                              ),
                            ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedDisaster = v!),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Location
                    Text(
                      "Location",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: "City / Area",
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Date Picker
                    Text(
                      "Event Date",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? "Select Event Date"
                                    : "Selected: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? Colors.grey.shade500
                                      : Colors.black,
                                ),
                              ),
                            ),
                            if (_selectedDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "Describe the event details",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : verify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _loading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "Verify Disaster",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Result Section
            if (result != null)
              AnimatedOpacity(
                opacity: result != null ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: getBackgroundColor(result!["status_color"]),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              getStatusIcon(result!["final_label"]),
                              color: getColor(result!["status_color"]),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                result!["final_label"].toUpperCase(),
                                style: TextStyle(
                                  color: getColor(result!["status_color"]),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: getColor(result!["status_color"])
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: getColor(result!["status_color"]),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "${(result!["confidence_score"] * 100).toInt()}%",
                                style: TextStyle(
                                  color: getColor(result!["status_color"]),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            result!["explanation"],
                            style: const TextStyle(
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (result!.containsKey("sources") &&
                            result!["sources"] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              "Sources: ${result!["sources"]}",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

            // Information Footer
            if (result == null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "This verification system analyzes your input against reliable sources to determine the authenticity of disaster reports.",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}