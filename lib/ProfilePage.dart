import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    saveFcmToken();
    
  }

  // 🔹 Save FCM token to Firestore
  Future<void> saveFcmToken() async {
    if (user == null) return;

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    String? token = await messaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'fcmToken': token,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your profile.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFF2980B9),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("⚠️ No profile data found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // 🔹 Worker check
          final bool isWorker =
              data['service'] != null && data['service'].toString().isNotEmpty;

          // 🔹 Admin approval check
          final bool isApprovedByAdmin =
              (data['approvedByAdmin'] == true || data['approved'] == true);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 👤 Profile Image
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF2980B9).withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Color(0xFF2980B9),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  data['name'] ?? "No Name",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  data['email'] ?? user!.email ?? "No Email",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 20),

                // User info card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "👤 User Information",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                            Icons.phone, "Phone", data['phone'] ?? "Not added"),
                        _buildInfoRow(Icons.location_on, "Location",
                            data['location'] ?? "Unknown"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Worker info
                if (isWorker)
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "🛠 Worker Information",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                              Icons.work, "Service", data['service'] ?? "N/A"),
                          _buildInfoRow(Icons.badge, "Experience",
                              data['experience']?.toString() ?? "N/A"),
                          _buildInfoRow(Icons.verified, "Admin Approval",
                              isApprovedByAdmin
                                  ? "✅ Approved"
                                  : "⏳ Pending Approval"),
                        ],
                      ),
                    ),
                  )
                else
                  const Text(
                    "You are not registered as a worker yet.",
                    style: TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 24),

                // Logout button
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Info row widget
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2980B9)),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
