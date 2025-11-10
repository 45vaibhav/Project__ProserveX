import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerProfilePage extends StatefulWidget {
  final String workerId;

  const WorkerProfilePage({super.key, required this.workerId});

  @override
  State<WorkerProfilePage> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitting = false;

  /// 🔹 Submit rating and feedback safely
  Future<void> _submitFeedback() async {
    if (_rating == 0 || _feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide rating and feedback")),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final docRef =
          FirebaseFirestore.instance.collection('workers').doc(widget.workerId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        // If worker does not exist, stop
        if (!snapshot.exists) {
          throw Exception("Worker does not exist.");
        }

        final data = snapshot.data() ?? {};

        // Handle missing rating or ratingCount safely
        double oldRating = (data['rating'] ?? 0).toDouble();
        int ratingCount = (data['ratingCount'] ?? 0).toInt();

        double newAvg =
            ((oldRating * ratingCount) + _rating) / (ratingCount + 1);

        transaction.update(docRef, {
          'rating': newAvg,
          'ratingCount': ratingCount + 1,
          'feedback': _feedbackController.text.trim(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback submitted successfully ✅")),
      );

      _feedbackController.clear();
      setState(() => _rating = 0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting feedback: $e")),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Worker Profile"),
        backgroundColor: const Color(0xFF2980B9),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('workers')
            .doc(widget.workerId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Worker not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          (data['name'] ?? 'W')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Basic info
                    _buildInfoRow("Name", data['name']),
                    _buildInfoRow("Service", data['service']),
                    _buildInfoRow("Location", data['location']),
                    _buildInfoRow("Experience", "${data['experience']} years"),
                    _buildInfoRow("Approved",
                        data['approved'] == true ? "✅ Yes" : "⏳ Pending"),
                    _buildInfoRow(
                      "Average Rating",
                      data['rating'] != null
                          ? "${data['rating'].toStringAsFixed(1)} ⭐"
                          : "No ratings yet",
                    ),

                    const SizedBox(height: 20),
                    const Divider(),

                    // Rating and feedback form
                    const Text(
                      "Give Rating & Feedback",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // ⭐ Rating bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 10),

                    // 💬 Feedback text box
                    TextField(
                      controller: _feedbackController,
                      decoration: InputDecoration(
                        labelText: "Enter your feedback",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    // 🚀 Submit button
                    ElevatedButton.icon(
                      onPressed: _submitting ? null : _submitFeedback,
                      icon: const Icon(Icons.send),
                      label: _submitting
                          ? const Text("Submitting...")
                          : const Text("Submit Feedback",style: TextStyle(color: Colors.black,),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 111, 153, 226),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 📜 Display latest feedback
                    if (data['feedback'] != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Latest Feedback: ${data['feedback']}",
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Small info display widget
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}
