import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class IssueDetailsScreen extends StatefulWidget {
  final LatLng location;
  final String areaName;
  final String name;
  final String phone;

  const IssueDetailsScreen({
    super.key,
    required this.location,
    required this.areaName,
    required this.name,
    required this.phone,
  });

  @override
  State<IssueDetailsScreen> createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends State<IssueDetailsScreen> with SingleTickerProviderStateMixin {
  final _issueController = TextEditingController();
  final _suggestionController = TextEditingController();
  final _attachmentController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _issueController.dispose();
    _suggestionController.dispose();
    _attachmentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return PopScope(
    canPop: true, // Allows popping by default
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) {
        Navigator.pop(context);
      }
    },
    child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 22, 53, 224), Color.fromARGB(255, 9, 24, 243)], // Blue gradient like e-Majengo
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0.0, _slideAnimation.value.dy * 50), // Pop-down effect
                      child: Opacity(
                        opacity: _animationController.value,
                        child: Card(
                          elevation: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Report Issue",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: _issueController,
                                      decoration: InputDecoration(
                                        labelText: "Issue Description",
                                        labelStyle: TextStyle(color: Colors.grey[600]),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        prefixIcon: Icon(Icons.warning, color: Colors.blue[700]),
                                      ),
                                      maxLines: 2,
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                    const SizedBox(height: 15),
                                    TextField(
                                      controller: _suggestionController,
                                      decoration: InputDecoration(
                                        labelText: "Suggestion (Optional)",
                                        labelStyle: TextStyle(color: Colors.grey[600]),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        prefixIcon: Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                                      ),
                                      maxLines: 2,
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                    const SizedBox(height: 15),
                                    TextField(
                                      controller: _attachmentController,
                                      decoration: InputDecoration(
                                        labelText: "Attach File (Optional)",
                                        labelStyle: TextStyle(color: Colors.grey[600]),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        prefixIcon: Icon(Icons.attach_file, color: Colors.blue[700]),
                                      ),
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text("Back", style: TextStyle(color: Colors.blue[700])),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            debugPrint("Report Submitted:");
                                            debugPrint("  Name: ${widget.name}");
                                            debugPrint("  Phone: ${widget.phone}");
                                            debugPrint("  Location: ${widget.areaName} (Lat: ${widget.location.latitude}, Lng: ${widget.location.longitude})");
                                            debugPrint("  Issue: ${_issueController.text}");
                                            debugPrint("  Suggestion: ${_suggestionController.text}");
                                            debugPrint("  Attachment: ${_attachmentController.text}");
                                            final newMarker = Marker(
                                              point: widget.location,
                                              child: const Icon(Icons.report, color: Colors.red, size: 30),
                                            );
                                            Navigator.pop(context, newMarker);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          ),
                                          child: const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}