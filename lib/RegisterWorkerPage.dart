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
    'AC Technician'
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Please sign in first.');

      final data = {
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'location': _location.text.trim(),
        'experience': _experience.text.trim(),
        'service': _service,
        'uid': user.uid,
        'isApproved': false, // pending admin approval
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('workers').add(data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Worker registration sent. Pending admin approval.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
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
        title: const Text('Register as Worker'),
        backgroundColor: deepBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          shadowColor: Colors.black26,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Icon(
                      Icons.person_add_alt_1,
                      size: 60,
                      color: Color(0xFF2980B9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Register Your Profile',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  _buildTextField(
                    controller: _name,
                    label: 'Full Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),

                  // Service Dropdown
                  DropdownButtonFormField<String>(
                    value: _service,
                    items: _services
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _service = v),
                    decoration: InputDecoration(
                      labelText: 'Select Service',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.handyman),
                    ),
                    validator: (v) => v == null ? 'Select service' : null,
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  _buildTextField(
                    controller: _phone,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  _buildTextField(
                    controller: _location,
                    label: 'Location',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 16),

                  // Experience
                  _buildTextField(
                    controller: _experience,
                    label: 'Experience (years)',
                    icon: Icons.work,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),

                  // Submit button
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: deepBlue,
                      elevation: 4,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Submit Registration',
                            style: TextStyle( color: Colors.black,
                                fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF2980B9)) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (v) => v == null || v.isEmpty ? 'Enter $label' : null,
    );
  }
}
