import 'package:ProserveX/WorkerProfilepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class SearchWorkerPage extends StatefulWidget {
  const SearchWorkerPage({super.key});

  @override
  State<SearchWorkerPage> createState() => _SearchWorkerPageState();
}

class _SearchWorkerPageState extends State<SearchWorkerPage> {
  String? selectedDomain;
  String searchQuery = '';

  final List<String> domains = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'Mechanic',
    'Cleaner',
    'Gardener',
    'AC Technician'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Domain Filter
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Filter by Service Domain (optional)",
            ),
            value: selectedDomain,
            items: domains
                .map((domain) =>
                    DropdownMenuItem(value: domain, child: Text(domain)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedDomain = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Search Bar
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Search by name or location",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase().trim();
              });
            },
          ),
          const SizedBox(height: 12),
          // Worker List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('workers').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No workers found."));
                }

                final workers = snapshot.data!.docs.where((worker) {
                  final data = worker.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final location = (data['location'] ?? '').toString().toLowerCase();
                  final service = (data['service'] ?? '').toString().toLowerCase();

                  final matchesDomain = selectedDomain == null
                      ? true
                      : service == selectedDomain!.toLowerCase();

                  final matchesSearch = searchQuery.isEmpty
                      ? true
                      : name.contains(searchQuery) || location.contains(searchQuery);

                  return matchesDomain && matchesSearch;
                }).toList();

                if (workers.isEmpty) {
                  return const Center(child: Text("No workers match your search."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    final worker = workers[index];
                    final data = worker.data() as Map<String, dynamic>;
                    final rating = (data['rating'] ?? 0.0).toDouble();

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Navigate to WorkerProfile
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WorkerProfilePage(workerId: worker.id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  (data['name'] ?? 'W')[0].toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      data['service'] ?? '-',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    Text(
                                      data['location'] ?? '-',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        RatingBarIndicator(
                                          rating: rating,
                                          itemBuilder: (context, _) => const Icon(
                                              Icons.star, color: Colors.amber),
                                          itemCount: 5,
                                          itemSize: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(rating.toStringAsFixed(1),
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      data['approved'] == true
                                          ? 'Approved ✅'
                                          : 'Pending ⏳',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: data['approved'] == true
                                              ? Colors.green
                                              : Colors.orange),
                                    ),
                                  ],
                                ),
                              ),
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
    );
  }
}
