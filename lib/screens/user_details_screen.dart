import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../utils/constants.dart';
import 'issue_details_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  final LatLng location;
  final String areaName;

  const UserDetailsScreen({super.key, required this.location, required this.areaName});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

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
    _nameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)], // Blue gradient like e-Majengo
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
                            padding: const EdgeInsets.all(20),
                            child: SingleChildScrollView( // Wrap Column in SingleChildScrollView
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "User Details",
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
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: "Full Name (Optional)",
                                      labelStyle: TextStyle(color: Colors.grey[600]),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
                                    ),
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                  const SizedBox(height: 15),
                                  TextField(
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      labelText: "Phone Number (Optional)",
                                      labelStyle: TextStyle(color: AppConstants.grey),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true,
                                      fillColor: AppConstants.grey,
                                      prefixIcon: Icon(Icons.phone, color: AppConstants.primaryBlue),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(color: AppConstants.black),
                                  ),
                                  const SizedBox(height: 15),
                                  Card(
                                    color: AppConstants.grey,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: ListTile(
                                      leading: Icon(Icons.location_on, color: AppConstants.primaryBlue),
                                      title: Text(widget.areaName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.black)),
                                      subtitle: Text(
                                        "${widget.location.latitude.toStringAsFixed(4)}, ${widget.location.longitude.toStringAsFixed(4)}",
                                        style: TextStyle(color: AppConstants.grey),
                                      ),
                                      enabled: false,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => IssueDetailsScreen(
                                              location: widget.location,
                                              areaName: widget.areaName,
                                              name: _nameController.text,
                                              phone: _phoneController.text,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppConstants.primaryBlue,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      ),
                                      child: const Text("Next", style: TextStyle(color: AppConstants.white, fontSize: 16)),
                                    ),
                                  ),
                                ],
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
    );
  }
}
