import 'package:ProserveX/Paymentpage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestWorkerPage extends StatefulWidget {
  final String domain;
  const RequestWorkerPage({super.key, required this.domain});

  @override
  State<RequestWorkerPage> createState() => _RequestWorkerPageState();
}

class _RequestWorkerPageState extends State<RequestWorkerPage> {
  final String adminPhone = "+917498146954";
  final double amount = 500.0; // Make it double for compatibility

  void _callAdmin() async {
    final Uri callUri = Uri(scheme: 'tel', path: adminPhone);
    if (!await launchUrl(callUri, mode: LaunchMode.platformDefault)) {
      _showMessage("Could not launch phone dialer");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email ?? 'Unknown User';

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
              "Request for: ${widget.domain}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "If you need a worker for this service, you can call the admin or save a payment request to confirm.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text(
                  "Call Admin",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _callAdmin,
              ),
            ),

            const SizedBox(height: 20),

            // Make Payment Button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: Text(
                  "Make Payment ₹$amount",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BasicPaymentPage(
                            workerId: "admin_request", 
                            workerName: "Admin Assigned Worker",
                            userName: userName,
                            service: widget.domain,
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
