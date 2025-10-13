import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({Key? key}) : super(key: key);

  @override
  _ProfilepageState createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? workerData;
  bool loading = true;

  final List<String> serviceOptions = [
    "Plumber",
    "Electrician",
    "Carpenter",
    "Painter",
    "Mechanic",
    "Cleaner",
    "Gardener",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    fetchUserAndWorkerData();
  }

  Future<void> fetchUserAndWorkerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

    final workerDoc =
        await FirebaseFirestore.instance.collection("workers").doc(user.uid).get();

    setState(() {
      userData = userDoc.exists ? userDoc.data() : null;
      workerData = workerDoc.exists ? workerDoc.data() : null;
      loading = false;
    });
  }

  Future<void> _editWorkerProfile() async {
    if (workerData == null) return;

    final experienceController =
        TextEditingController(text: workerData!['experience'] ?? '');
    String selectedService = workerData!['service'] ?? serviceOptions.first;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Worker Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: serviceOptions.contains(selectedService)
                    ? selectedService
                    : serviceOptions.first,
                decoration: InputDecoration(
                  labelText: "Service",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: serviceOptions
                    .map((service) =>
                        DropdownMenuItem(value: service, child: Text(service)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedService = value;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: experienceController,
                decoration: InputDecoration(
                  labelText: "Experience",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                final updatedWorker = {
                  "service": selectedService,
                  "experience": experienceController.text.trim(),
                };

                await FirebaseFirestore.instance
                    .collection("workers")
                    .doc(user.uid)
                    .update(updatedWorker);

                setState(() {
                  workerData = {...workerData!, ...updatedWorker};
                });

                Navigator.pop(context);
              },
              child: const Text("Save")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: const Color(0xFF5FC7ED),
        ),
        body: const Center(child: Text("No profile data found.", style: TextStyle(fontSize: 18))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF5FC7ED),
        elevation: 0,
        actions: [
          if (workerData != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editWorkerProfile,
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)),
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF2980B9),
                      child: const Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            Text(
              userData!['name'] ?? '',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              userData!['email'] ?? '',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: buildCard(Icons.phone, userData!['phone'] ?? '', "Phone"),
            ),
            const SizedBox(height: 20),
            if (workerData != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Worker Info",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      buildWorkerRow("Service", workerData?['service'] ?? 'Not registered'),
                      buildWorkerRow("Experience", workerData?['experience'] ?? 'Not provided'),
                      buildWorkerRow("Rating", workerData?['rating']?.toString() ?? '0.0'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildCard(IconData icon, String value, String label) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2980B9)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget buildWorkerRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16))),
        ],
      ),
    );
  }
}
