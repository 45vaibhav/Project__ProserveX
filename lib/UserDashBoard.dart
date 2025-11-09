import 'package:agri/SearchWorker.dart';
import 'package:agri/UserPayment.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'RegisterWorkerPage.dart';
import 'ProfilePage.dart';
import 'WorkerListPage.dart';
// ✅ New page

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  final List<String> domains = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'Mechanic',
    'Gardener',
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(context),
      const SearchWorkerPage(),
      const PaymentHistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
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
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.white,
  selectedItemColor: const Color(0xFF2980B9), // royal blue
  unselectedItemColor: Colors.grey,
  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
  elevation: 10,
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'Search'),
    BottomNavigationBarItem(icon: Icon(Icons.payment_outlined), label: 'Payments'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
  ],
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterWorkerPage(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF27AE60),
              child: const Icon(Icons.add),
              tooltip: "Register as Worker",
            )
          : null,
    );
  }

  Widget _buildHomePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome to ProServeX 👋",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Select a service domain to view available workers",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: domains.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 2,
              ),
              itemBuilder: (context, index) {
                final domain = domains[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkerListPage(domain: domain),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    color: Colors.blue[50],
                    child: Center(
                      child: Text(
                        domain,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
