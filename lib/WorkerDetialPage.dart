import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerDetailPage extends StatelessWidget {
  final String workerId;

  const WorkerDetailPage({super.key, required this.workerId});

  Future<DocumentSnapshot> _fetchWorkerDetails() async {
    return await FirebaseFirestore.instance
        .collection('workers')
        .doc(workerId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Worker Details"),
        backgroundColor: const Color(0xFF2980B9),
        elevation: 3,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchWorkerDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2980B9)),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Worker details not found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final worker = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 👤 Profile Picture or Placeholder
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.person, size: 70, color: Colors.blue),
                ),
                const SizedBox(height: 20),

                // 🧾 Worker Basic Info
                Text(
                  worker['name'] ?? 'Unknown Worker',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  worker['domain'] ?? 'No domain specified',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
                  ),
                ),

                const SizedBox(height: 20),

                // 📋 Information Cards
                _buildInfoCard(
                  icon: Icons.work_outline,
                  title: "Experience",
                  value: worker['experience'] ?? 'Not provided',
                ),
                _buildInfoCard(
                  icon: Icons.location_on,
                  title: "Location",
                  value: worker['location'] ?? 'Not specified',
                ),
                _buildInfoCard(
                  icon: Icons.info_outline,
                  title: "About",
                  value: worker['description'] ??
                      'No description available for this worker.',
                ),

                const SizedBox(height: 30),

                // 🌟 Rating / Status Section
                if (worker['approved'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          "Verified & Approved Worker",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          "Pending Admin Approval",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🧱 Reusable info card widget
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
