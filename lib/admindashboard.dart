import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'WorkerProfilePage.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _approveWorker(String workerId) async {
    await FirebaseFirestore.instance
        .collection('workers')
        .doc(workerId)
        .update({'approved': true});
  }

  Future<void> _deleteWorker(String workerId) async {
    await FirebaseFirestore.instance
        .collection('workers')
        .doc(workerId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildHomePage(),
      _buildSearchPage(),
      _buildPaymentHistoryPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xFF2980B9),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF2980B9),
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search Workers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Payment History',
          ),
        ],
      ),
    );
  }

  // Home Page - All Workers
  Widget _buildHomePage() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('workers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No registered workers found."));
        }

        final workers = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: workers.length,
          itemBuilder: (context, index) {
            final worker = workers[index];
            final data = worker.data() as Map<String, dynamic>;
            final rating = (data['rating'] ?? 0.0).toDouble();

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            WorkerProfilePage(workerId: worker.id)),
                  );
                },
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    (data['name'] ?? 'W')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                title: Text(
                  data['name'] ?? 'Unknown',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['service'] ?? '-',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      data['location'] ?? '-',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: rating,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10)),
                      ],
                    ),
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
                trailing: Column(
                  mainAxisSize: MainAxisSize.min, // compact column
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Approve Worker',
                      onPressed: data['approved'] == true
                          ? null
                          : () => _approveWorker(worker.id),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Worker',
                      onPressed: () => _deleteWorker(worker.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Search Page - Filter + Search
  Widget _buildSearchPage() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('workers').snapshots(),
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
                  final location =
                      (data['location'] ?? '').toString().toLowerCase();
                  final service =
                      (data['service'] ?? '').toString().toLowerCase();

                  final matchesDomain = selectedDomain == null
                      ? true
                      : service == selectedDomain!.toLowerCase();

                  final matchesSearch = searchQuery.isEmpty
                      ? true
                      : name.contains(searchQuery) ||
                          location.contains(searchQuery);

                  return matchesDomain && matchesSearch;
                }).toList();

                if (workers.isEmpty) {
                  return const Center(
                      child: Text("No workers match your search."));
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
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    WorkerProfilePage(workerId: worker.id)),
                          );
                        },
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            (data['name'] ?? 'W')[0].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 24, color: Colors.white),
                          ),
                        ),
                        title: Text(
                          data['name'] ?? 'Unknown',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['service'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              data['location'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: rating,
                                  itemBuilder: (context, _) => const Icon(
                                      Icons.star, color: Colors.amber),
                                  itemCount: 5,
                                  itemSize: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(rating.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 10)),
                              ],
                            ),
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
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              tooltip: 'Approve Worker',
                              onPressed: data['approved'] == true
                                  ? null
                                  : () => _approveWorker(worker.id),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete Worker',
                              onPressed: () => _deleteWorker(worker.id),
                            ),
                          ],
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

  // Payment History Page
  Widget _buildPaymentHistoryPage() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('payments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No payment history found.", style: TextStyle(fontSize: 16)),
          );
        }

        final payments = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final data = payments[index].data() as Map<String, dynamic>;
            final amount = data['amount'] ?? 0;
            final service = data['service'] ?? '-';
            final userName = data['userName'] ?? 'Unknown';
            final timestamp = data['timestamp'] != null
                ? (data['timestamp'] as Timestamp).toDate()
                : DateTime.now();

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Service: $service"),
                    Text("Amount: ₹$amount"),
                    Text("Date: ${timestamp.toLocal()}"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
