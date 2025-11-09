import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view payments.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
        backgroundColor: const Color(0xFF2980B9),
      ),
      body: Container()
        
      );
    
  }
}
