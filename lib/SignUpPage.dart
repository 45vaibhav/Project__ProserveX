import 'package:agri/UserDashBoard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  void signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      // Create user in Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      final uid = userCredential.user!.uid;

      // Save user info in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      validator: (val) => val!.isEmpty ? "Enter name" : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (val) => val!.isEmpty ? "Enter email" : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: "Phone"),
                      validator: (val) => val!.isEmpty ? "Enter phone" : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                      validator: (val) =>
                          val!.length < 6 ? "Password too short" : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: signup, child: const Text("Signup"))
                  ],
                ),
              ),
            ),
    );
  }
}
