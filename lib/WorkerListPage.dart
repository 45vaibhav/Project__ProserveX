import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'WorkerProfilePage.dart';
import 'RequestWorkerPage.dart';

class WorkerListPage extends StatefulWidget {
  final String domain;

  const WorkerListPage({super.key, required this.domain});

  @override
  State<WorkerListPage> createState() => _WorkerListPageState();
}

class _WorkerListPageState extends State<WorkerListPage> {
  bool showWorkers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.domain} Workers"),
        backgroundColor: const Color(0xFF2980B9),
      ),
      body: Column(
        children: [
          Expanded(
            child: showWorkers
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('workers')
                        .where('service', isEqualTo: widget.domain)
                        .where('approved', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No approved workers found in this domain.",
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      final workers = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: workers.length,
                        itemBuilder: (context, index) {
                          final worker = workers[index];
                          final data =
                              worker.data() as Map<String, dynamic>? ?? {};

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  (data['name'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              title: Text(
                                data['name'] ?? 'Unnamed Worker',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Service: ${data['service'] ?? '-'}"),
                                  Text("Location: ${data['location'] ?? '-'}"),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Contact through Admin only 🔒",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.redAccent),
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.info_outline,
                                color: Colors.blueAccent,
                              ),
                              // Can view profile but no contact option
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WorkerProfilePage(workerId: worker.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.handyman_rounded,
                          size: 100,
                          color: Colors.blueAccent.shade200,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Find approved ${widget.domain}s near you!",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Tap below to view workers (contact via Admin only).",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),

          // 🟩 Bottom buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(showWorkers
                        ? Icons.refresh_rounded
                        : Icons.people_alt_rounded),
                    label: Text(
                      showWorkers ? "Hide Workers" : "Show Workers",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2980B9),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        showWorkers = !showWorkers;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.support_agent_rounded),
                    label: const Text(
                      "Request Worker (Contact Admin)",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RequestWorkerPage(domain: widget.domain),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
