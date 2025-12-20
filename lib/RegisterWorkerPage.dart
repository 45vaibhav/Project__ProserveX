import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterWorkerPage extends StatefulWidget {
  const RegisterWorkerPage({super.key});

  @override
  State<RegisterWorkerPage> createState() => _RegisterWorkerPageState();
}

class _RegisterWorkerPageState extends State<RegisterWorkerPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _upiId = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _experience = TextEditingController();

  String? _service;
  bool _loading = false;

  final List<String> _services = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'Mechanic',
    'Cleaner',
    'Gardener',
    'AC Technician',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Please login first");
      }

      final workerData = {
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'upiId': _upiId.text.trim(), // ✅ REQUIRED FOR PAYOUT
        'location': _location.text.trim(),
        'experience': _experience.text.trim(),
        'service': _service,
        'uid': user.uid,
        'rating': 0,
        'ratingCount': 0,
        'isApproved': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('workers')
          .add(workerData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration submitted. Await admin approval."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _upiId.dispose();
    _location.dispose();
    _experience.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF2980B9);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Register as Worker"),
        backgroundColor: deepBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.person_add_alt_1,
                      size: 60, color: deepBlue),
                  const SizedBox(height: 16),
                  const Text(
                    "Worker Registration",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  _buildField(_name, "Full Name", Icons.person),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _service,
                    items: _services
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _service = v),
                    decoration: _inputDecoration(
                        "Service", Icons.handyman),
                    validator: (v) =>
                        v == null ? "Select service" : null,
                  ),

                  const SizedBox(height: 16),
                  _buildField(_phone, "Phone Number", Icons.phone,
                      type: TextInputType.phone),

                  const SizedBox(height: 16),
                  _buildField(
                    _upiId,
                    "UPI ID (for payments)",
                    Icons.account_balance_wallet,
                    hint: "example@upi",
                  ),

                  const SizedBox(height: 16),
                  _buildField(_location, "Location", Icons.location_on),

                  const SizedBox(height: 16),
                  _buildField(
                    _experience,
                    "Experience (years)",
                    Icons.work,
                    type: TextInputType.number,
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepBlue,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text(
                            "Submit Registration",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: _inputDecoration(label, icon, hint: hint),
      validator: (v) =>
          v == null || v.isEmpty ? "Enter $label" : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF2980B9)),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
