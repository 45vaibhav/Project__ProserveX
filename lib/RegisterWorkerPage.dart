import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Profilepage.dart';

class Registerworkerpage extends StatefulWidget {
  const Registerworkerpage({Key? key}) : super(key: key);

  @override
  _WorkerRegisterPageState createState() => _WorkerRegisterPageState();
}

class _WorkerRegisterPageState extends State<Registerworkerpage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool loading = false;

  // Match the services exactly with UserDashboard
  final List<String> serviceOptions = [
    "Home Cleaning",
    "Plumbing",
    "Electrical Repair",
    "Carpentry",
    "Painting",
    "Gardening",
    "Mechanic",
    "Other"
  ];

  String selectedService = "Home Cleaning";

  void registerWorker() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('workers').doc(user.uid).set({
        'uid': user.uid,
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'service': selectedService,
        'experience': experienceController.text.trim(),
        'rating': 0.0,
        'ratingCount': 0,
        'feedback': [],
        'profileImageUrl': null, // Optional, can add image later
      });

      // Navigate to Profile Page
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Profilepage()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Worker Registration")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Full Name"),
                      validator: (val) => val!.isEmpty ? "Enter name" : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: "Phone"),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val!.isEmpty ? "Enter phone" : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val!.isEmpty ? "Enter email" : null,
                    ),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: "Address"),
                      validator: (val) => val!.isEmpty ? "Enter address" : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedService,
                      items: serviceOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedService = val);
                      },
                      decoration: const InputDecoration(labelText: "Service"),
                    ),
                    TextFormField(
                      controller: experienceController,
                      decoration: const InputDecoration(labelText: "Experience"),
                      validator: (val) =>
                          val!.isEmpty ? "Enter experience" : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: registerWorker,
                        child: const Text("Register Worker"))
                  ],
                ),
              ),
            ),
    );
  }
}
