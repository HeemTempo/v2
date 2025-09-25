import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:openspace_mobile_app/utils/constants.dart';
import '../widget/faqs.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool _showContactForm = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightGrey,
      appBar: AppBar(
        title: const Text("Help with OSA", style: TextStyle(color: AppConstants.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        backgroundColor: AppConstants.primaryBlue,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need Help?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Find answers and support for common issues.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showContactForm = !_showContactForm;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(_showContactForm ? 'Hide Form' : 'Contact Support'),
            ),

            // Contact Form
            if (_showContactForm) ...[
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Your Message", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Type your issue or question here...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.success,
                            title: 'Message Sent!',
                            text: 'Your message has been successfully sent to support.',
                            confirmBtnColor: Colors.blue,
                          );

                          setState(() {
                            _showContactForm = false;
                            _messageController.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
            const Text(
              'FAQs',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            FAQItem("How do I reset my password?", "Go to settings and tap 'Reset Password'."),
            FAQItem("Where can I find my reports?", "Reports are available in 'My Reports' section."),
            FAQItem("Can I change my email?", "Yes, go to account settings and update your email."),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "© 2025  KINONDONI MUNICIPAL ",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
