import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class PaymentService {
  final Razorpay _razorpay = Razorpay();
  Map<String, dynamic>? _currentPaymentData;

  PaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required String workerId,
    required String workerName,
    required String userName,
    required String service,
    required int amount,
  }) {
    _currentPaymentData = {
      'workerId': workerId,
      'workerName': workerName,
      'userName': userName,
      'service': service,
      'totalAmount': amount,
    };

    var options = {
      'key': 'rzp_test_RkV4zGjB8rJcNP',
      'amount': amount * 100, // in paise
      'name': workerName,
      'description': service,
      'prefill': {'contact': '', 'email': ''},
      'external': {'wallets': ['paytm']}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error opening Razorpay: $e");
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_currentPaymentData == null) return;

    try {
      final int totalAmount = _currentPaymentData!['totalAmount'];
      final double adminCut = totalAmount * 0.10; // 10% admin cut
      final double workerAmount = totalAmount - adminCut;

      // Create payment document in Firestore
      await FirebaseFirestore.instance.collection('payments').add({
        'workerId': _currentPaymentData!['workerId'],
        'workerName': _currentPaymentData!['workerName'],
        'userName': _currentPaymentData!['userName'],
        'service': _currentPaymentData!['service'],
        'totalAmount': totalAmount,
        'workerAmount': workerAmount,
        'adminCut': adminCut,
        'paymentId': response.paymentId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'success',
        'settled': false,
      });

      debugPrint("Payment document created ✅");
    } catch (e) {
      debugPrint("Error saving payment: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Payment failed: ${response.code} - ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External wallet selected: ${response.walletName}");
  }

  void dispose() {
    _razorpay.clear();
  }
}
