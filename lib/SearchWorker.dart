import 'package:agri/WorkerDetialPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SearchWorkerPage extends StatefulWidget {
  final String? filterDomain;

  const SearchWorkerPage({super.key, this.filterDomain});

  @override
  State<SearchWorkerPage> createState() => _SearchWorkerPageState();
}

class _SearchWorkerPageState extends State<SearchWorkerPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔍 Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search worker by name or location...",
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔄 Worker List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('workers')
                      .where('approved', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.blue));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No workers found.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    // Filter workers
                    final workers = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name']?.toString().toLowerCase() ?? '';
                      final location =
                          data['location']?.toString().toLowerCase() ?? '';
                      final domain =
                          data['domain']?.toString().toLowerCase() ?? '';

                      final query = searchQuery.toLowerCase();

                      final matchesSearch = query.isEmpty ||
                          name.contains(query) ||
                          location.contains(query);

                      final matchesDomain = widget.filterDomain == null ||
                          domain ==
                              widget.filterDomain!.toLowerCase();

                      return matchesSearch && matchesDomain;
                    }).toList();

                    if (workers.isEmpty) {
                      return const Center(
                        child: Text(
                          "No workers found for this search.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    // 📋 Display workers in a card grid
                    return ListView.builder(
                      itemCount: workers.length,
                      itemBuilder: (context, index) {
                        final worker =
                            workers[index].data() as Map<String, dynamic>;
                        final workerId = workers[index].id;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkerDetailPage(workerId: workerId),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // 👤 Avatar or default icon
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.blue[100],
                                    child: const Icon(Icons.person,
                                        size: 35, color: Colors.blue),
                                  ),
                                  const SizedBox(width: 16),

                                  // 🧾 Worker info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          worker['name'] ?? 'Unknown Worker',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          worker['domain'] ?? 'No domain',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                color: Colors.red, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              worker['location'] ??
                                                  'No location',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Icon(Icons.arrow_forward_ios,
                                      color: Colors.grey, size: 18),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
