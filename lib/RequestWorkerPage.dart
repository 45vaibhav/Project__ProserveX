import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestWorkerPage extends StatefulWidget {
  final String domain;
  const RequestWorkerPage({super.key, required this.domain});

  @override
  State<RequestWorkerPage> createState() => _RequestWorkerPageState();
}

class _RequestWorkerPageState extends State<RequestWorkerPage> {
  late Razorpay _razorpay;
  final String adminPhone = "+919876543210"; // Admin number
  final double amount = 500; // Payment amount

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ------------------- Razorpay Payment -------------------
  void _openCheckout(double amount) {
    var options = {
      'key': 'rzp_test_YourKeyHere', // Replace with your Razorpay test/live key
      'amount': (amount * 100).toInt(), // convert rupees to paise
      'name': 'ProServeX Admin',
      'description': 'Payment for ${widget.domain} service',
      'prefill': {
        'contact': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
        'email': FirebaseAuth.instance.currentUser?.email ?? ''
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error opening Razorpay: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await FirebaseFirestore.instance.collection('payments').add({
        'domain': widget.domain,
        'amount': amount,
        'userId': FirebaseAuth.instance.currentUser?.uid ?? "unknown",
        'paymentId': response.paymentId,
        'timestamp': Timestamp.now(),
        'status': "success",
      });
      Fluttertoast.showToast(
          msg: "Payment successful ✅\nPayment ID: ${response.paymentId}");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error saving payment: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg:
            "Payment failed ❌\nCode: ${response.code}\nMessage: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
  }

  // ------------------- Call Admin -------------------
  void _callAdmin() async {
    final Uri callUri = Uri(scheme: 'tel', path: adminPhone);
    if (!await launchUrl(callUri, mode: LaunchMode.platformDefault)) {
      Fluttertoast.showToast(msg: "Could not launch phone dialer");
    }
  }

  // ------------------- UI -------------------
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
              "Request for: ${widget.domain}",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "If you need a worker for this service, you can either call the admin or pay to confirm the request.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text(
                  "Call Admin",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _callAdmin,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: Text(
                  "Pay ₹$amount",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _openCheckout(amount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
