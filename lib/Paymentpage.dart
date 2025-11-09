import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Center(child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.payments, size: 72),
          const SizedBox(height: 12),
          const Text('No payment history', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 18),
          ElevatedButton(onPressed: () {}, child: const Text('Make a Payment'))
        ]),
      )),
    );
  }
}
