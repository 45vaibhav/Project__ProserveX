import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:ProserveX/UserDashboard.dart';
class BasicPaymentPage extends StatefulWidget {
  final String workerId;
  final String workerName;
  final String service;
  final String userName;

  const BasicPaymentPage({
    super.key,
    required this.workerId,
    required this.workerName,
    required this.service,
    required this.userName,
  });

  @override
  State<BasicPaymentPage> createState() => _BasicPaymentPageState();
}

class _BasicPaymentPageState extends State<BasicPaymentPage> {
  int selectedHours = 1;
  final int ratePerHour = 100;
  late Razorpay _razorpay;

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

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final totalAmount = selectedHours * ratePerHour;

    final workerDoc = await FirebaseFirestore.instance
        .collection('workers')
        .doc(widget.workerId)
        .get();

    if (!workerDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Worker not found")),
      );
      return;
    }

    final workerUpi = workerDoc.data()?['upiId'] ?? '';

    await FirebaseFirestore.instance.collection('payments').add({
      'workerId': widget.workerId,
      'workerName': widget.workerName,
      'workerUPI': workerUpi,
      'userName': widget.userName,
      'service': "${widget.service} ($selectedHours hrs)",
      'totalAmount': totalAmount,
      'status': 'success',
      'settled': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment ₹$totalAmount successful ✅")),
    );

   Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const UserDashboard()),
  (route) => false,
);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed ❌")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void _payNow() {
    final totalAmount = selectedHours * ratePerHour;

    var options = {
      'key': 'rzp_test_RkV4zGjB8rJcNP',
      'amount': totalAmount * 100,
      'name': 'ProserveX',
      'description': "${widget.service} ($selectedHours hrs)",
      'theme': {'color': '#2980B9'}
    };

    _razorpay.open(options);
  }

  Widget _hourButton(int hour) {
    final isSelected = selectedHours == hour;

    return GestureDetector(
      onTap: () => setState(() => selectedHours = hour),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
        child: Text(
          "$hour hr",
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = selectedHours * ratePerHour;

    return Scaffold(
      appBar: AppBar(title: const Text("Select Time & Pay")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Service Duration",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // ✅ CLICKABLE HOURS
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(8, (i) => _hourButton(i + 1)),
            ),

            const SizedBox(height: 30),
            Text(
              "Total Amount: ₹$total",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _payNow,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "Pay Now",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
