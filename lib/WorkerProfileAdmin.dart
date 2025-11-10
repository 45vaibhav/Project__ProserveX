import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // For calling functionality

class WorkerProfileAdmin extends StatefulWidget {
  final String workerId;
  const WorkerProfileAdmin({super.key, required this.workerId});

  @override
  State<WorkerProfileAdmin> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfileAdmin> {
  bool _loading = true;
  Map<String, dynamic>? _workerData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWorkerData();
  }

  /// Fetch worker data from Firestore
  Future<void> _fetchWorkerData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('workers')
          .doc(widget.workerId)
          .get();

      if (!snapshot.exists) {
        setState(() {
          _error = "Worker not found";
        });
        return;
      }

      setState(() {
        _workerData = snapshot.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to fetch worker data: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// 🔹 Call worker using phone dialer
  Future<void> _callWorker(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showSnack("Phone number not available");
      return;
    }

    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      _showSnack("Could not launch phone dialer");
    }
  }

  /// 🔹 Delete worker from Firestore
  Future<void> _deleteWorker() async {
    try {
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(widget.workerId)
          .delete();
      _showSnack("Worker deleted successfully ✅");
      Navigator.pop(context);
    } catch (e) {
      _showSnack("Error deleting worker: $e");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Worker Profile"),
        backgroundColor: const Color(0xFF2980B9),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _workerData == null
                  ? const Center(child: Text("No data available"))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Gradient Header
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.white,
                                      child: Text(
                                        (_workerData!['name'] ?? 'W')[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 40,
                                          color: Color(0xFF2980B9),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _workerData!['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _workerData!['service'] ?? '-',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _workerData!['location'] ?? '-',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Info Card
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow("Experience",
                                          "${_workerData!['experience']} years"),
                                      _buildInfoRow(
                                          "Approved",
                                          _workerData!['approved'] == true
                                              ? "✅ Yes"
                                              : "⏳ Pending"),
                                      _buildInfoRow(
                                          "Average Rating",
                                          _workerData!['rating'] != null
                                              ? "${_workerData!['rating'].toStringAsFixed(1)} ⭐"
                                              : "No ratings yet"),
                                      _buildInfoRow("Phone", _workerData!['phone']),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Call Button
                              if (_workerData!['phone'] != null &&
                                  _workerData!['phone'].toString().isNotEmpty)
                                ElevatedButton.icon(
                                  onPressed: () => _callWorker(_workerData!['phone']),
                                  icon: const Icon(Icons.call, color: Colors.white),
                                  label: const Text(
                                    "Call Worker",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                ),

                              const SizedBox(height: 12),

                              // Delete Button
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Confirm Deletion"),
                                      content: const Text(
                                          "Are you sure you want to delete this worker?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteWorker();
                                          },
                                          child: const Text("Delete",
                                              style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete, color: Colors.white),
                                label: const Text(
                                  "Delete Worker",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }

  /// Small info display widget
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
