import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'WorkerModel.dart';

class WorkerDetailPage extends StatefulWidget {
  final Worker worker;
  const WorkerDetailPage({Key? key, required this.worker}) : super(key: key);

  @override
  _WorkerDetailPageState createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends State<WorkerDetailPage>
    with TickerProviderStateMixin {
  final TextEditingController _feedbackController = TextEditingController();
  double _userRating = 0.0;

  late AnimationController _profileController;
  late Animation<double> _profileScaleAnimation;
  late Animation<double> _profileFadeAnimation;

  late AnimationController _cardsController;
  late Animation<Offset> _cardsSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Profile Animation
    _profileController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _profileScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _profileController, curve: Curves.easeOutBack));
    _profileFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _profileController, curve: Curves.easeIn));
    _profileController.forward();

    // Cards Animation
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardsSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(parent: _cardsController, curve: Curves.easeOut));
    _cardsController.forward();
  }

  @override
  void dispose() {
    _profileController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  // 🧠 Safe Feedback Submit
  Future<void> _submitFeedback() async {
    if (_userRating == 0.0 || _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please provide rating & feedback")));
      return;
    }

    final docRef =
        FirebaseFirestore.instance.collection('workers').doc(widget.worker.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>? ?? {};

      double currentRating =
          (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0;
      int ratingCount = (data['ratingCount'] is int)
          ? data['ratingCount'] as int
          : int.tryParse(data['ratingCount']?.toString() ?? '0') ?? 0;
      List feedbackList = (data['feedback'] is List)
          ? List.from(data['feedback'])
          : [];

      double newRating =
          (currentRating * ratingCount + _userRating) / (ratingCount + 1);
      int newCount = ratingCount + 1;
      feedbackList.add(_feedbackController.text);

      transaction.update(docRef, {
        'rating': newRating,
        'ratingCount': newCount,
        'feedback': feedbackList,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback submitted successfully")));
    _feedbackController.clear();
    setState(() => _userRating = 0.0);
  }

  Future<void> _callWorker() async {
    final Uri uri = Uri(scheme: "tel", path: widget.worker.phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _emailWorker() async {
    final Uri uri = Uri(
      scheme: "mailto",
      path: widget.worker.email,
      query: "subject=Service Inquiry&body=Hello ${widget.worker.name},",
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.worker.name),
        backgroundColor: const Color(0xFF2980B9),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workers')
            .doc(widget.worker.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rawData = snapshot.data!.data();
          if (rawData == null || rawData is! Map<String, dynamic>) {
            return const Center(child: Text("Invalid worker data"));
          }

          final data = rawData;

          // 🛡 Safe conversions
          final service = data['service']?.toString() ?? '';
          final experience = data['experience']?.toString() ?? '';
          final address =
              data['address']?.toString() ?? 'No address provided';

          final rating = (data['rating'] is num)
              ? (data['rating'] as num).toDouble()
              : double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0;

          final ratingCount = (data['ratingCount'] is int)
              ? data['ratingCount'] as int
              : int.tryParse(data['ratingCount']?.toString() ?? '0') ?? 0;

          final feedback = (data['feedback'] is List)
              ? List<String>.from(
                  (data['feedback'] as List).map((e) => e.toString()))
              : <String>[];

          return Column(
            children: [
              const SizedBox(height: 12),

              // Profile Avatar
              FadeTransition(
                opacity: _profileFadeAnimation,
                child: ScaleTransition(
                  scale: _profileScaleAnimation,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blue[50],
                    
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text(widget.worker.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(service,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              const SizedBox(height: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      address,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 37, 37, 37)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Call & Email
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _callWorker,
                    icon: const Icon(Icons.call, size: 16),
                    label:
                        const Text("Call", style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _emailWorker,
                    icon: const Icon(Icons.email, size: 16),
                    label:
                        const Text("Email", style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Info Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        color: Colors.blue[50],
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              const Icon(Icons.work_history,
                                  color: Colors.blueGrey, size: 20),
                              const SizedBox(height: 4),
                              const Text("Experience",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                              Text(experience,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[700])),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        color: Colors.orange[50],
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.orangeAccent, size: 20),
                              const SizedBox(height: 4),
                              const Text("Rating",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                              Text("${rating.toStringAsFixed(1)} / 5",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[700])),
                              Text("($ratingCount)",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Feedback List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: feedback.isNotEmpty
                      ? ListView.builder(
                          itemCount: feedback.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 1,
                              margin:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                leading: const Icon(Icons.feedback,
                                    color: Colors.blueGrey, size: 18),
                                title: Text(feedback[index],
                                    style: const TextStyle(fontSize: 13)),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text("No feedback yet",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12))),
                ),
              ),

              // Feedback Input
              Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RatingBar.builder(
                          initialRating: _userRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) =>
                              setState(() => _userRating = rating),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _feedbackController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "Write your feedback...",
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6)),
                          maxLines: 2,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Payment coming soon...")));
                                },
                                icon:
                                    const Icon(Icons.payment, size: 16),
                                label: const Text("Pay Now",
                                    style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _submitFeedback,
                                icon: const Icon(Icons.send, size: 16),
                                label: const Text("Submit",
                                    style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF2980B9),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
