import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'UserDashboard.dart';   // <-- ADD THIS IMPORT

class BasicPaymentPage extends StatefulWidget {
  @override
  _BasicPaymentPageState createState() => _BasicPaymentPageState();
}

class _BasicPaymentPageState extends State<BasicPaymentPage> {
  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  void startPayment() {
    var options = {
      'key': 'rzp_test_RkV4zGjB8rJcNP',
      'amount': 5000, // 50 INR
      'name': 'Test Transaction',
      'description': 'Basic Payment',
      'prefill': {
        'contact': '9876543210',
        'email': 'test@example.com',
      }
    };

    razorpay.open(options);
  }

  void _onSuccess(PaymentSuccessResponse response) {
    print("SUCCESS: ${response.paymentId}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Success! Redirecting...")),
    );
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDashboard()),
      );
    });
  }

  void _onError(PaymentFailureResponse response) {
    print("ERROR: ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed!")),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    print("EXTERNAL WALLET");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet Selected")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Basic Razorpay Transaction")),
      body: Center(
        child: ElevatedButton(
          onPressed: startPayment,
          child: Text("Pay ₹50"),
        ),
      ),
    );
  }
}
