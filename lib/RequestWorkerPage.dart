import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestWorkerPage extends StatelessWidget {
  final String domain;
  const RequestWorkerPage({super.key, required this.domain});

  final String adminPhone = "+919876543210"; // change to your number

  void _callAdmin() async {
    final Uri callUri = Uri(scheme: 'tel', path: "+919876543210");
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request a Worker"),
        backgroundColor: const Color(0xFF2980B9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Request for: $domain",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "If you need a worker for this service, please contact the admin below.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text(
                  "Call Admin",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _callAdmin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
