import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'WorkerModel.dart';
import 'RegisterWorkerPage.dart';
import 'ProfilePage.dart';
import 'Searchworker.dart';
import 'WorkerDetialPage.dart';
import 'ServiceProf.dart';

class UserDashboard extends StatefulWidget {
  final Worker? currentWorker; // optional

  const UserDashboard({Key? key, this.currentWorker}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  final List<ServiceItem> servicesList = [
    ServiceItem('Home Cleaning','', 'assets/Home.png'),
    ServiceItem('Plumbing', '', 'assets/plumbing.png'),
    ServiceItem('Electrical Repair', '', 'assets/electrical.png'),
    ServiceItem('Carpentry', '', 'assets/electrical.png'),
    ServiceItem('Painting', '', 'assets/electrical.png'),
    ServiceItem('Gardening', '', 'assets/electrical.png'),
  ];

  final Color lightBlue = const Color(0xFF6DD5FA);
  final Color deepBlue = const Color(0xFF2980B9);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5FC7ED),
        elevation: 0,
        centerTitle: true,
        title: Text('Dashboard',
            style: TextStyle(color: deepBlue, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.settings, color: deepBlue), onPressed: () {})
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('All Services'),
            SizedBox(height: screenHeight * 0.015),
            buildHorizontalList(servicesList, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03),
            sectionTitle('Recently added Workers'),
            SizedBox(height: screenHeight * 0.015),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("workers").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No workers registered yet",
                      style: TextStyle(color: Colors.grey));
                }

                final workers = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  return Worker(
                    id: doc.id,
                    name: data['name']?.toString() ?? '',
                    service: data['service']?.toString() ?? '',
                    experience: data['experience']?.toString() ?? '0',
                    phone: data['phone']?.toString() ?? '',
                    email: data['email']?.toString() ?? '',
                    address: data['address']?.toString() ?? 'No address provided',
                    rating: (data['rating'] is num)
                        ? (data['rating'] as num).toDouble()
                        : double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
                    ratingCount: (data['ratingCount'] is int)
                        ? data['ratingCount'] as int
                        : int.tryParse(data['ratingCount']?.toString() ?? '0') ?? 0,
                    feedback: (data['feedback'] is List)
                        ? List<String>.from(data['feedback'].map((e) => e.toString()))
                        : [],
                  );
                }).toList();

                return buildHorizontalWorkerList(workers, screenWidth, screenHeight);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Registerworkerpage()),
          );
        },
        backgroundColor: deepBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);

          if (index == 1) {
            // Push Searchworker ON TOP of dashboard (do NOT replace)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Searchworker()),
            );
          }

          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profilepage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) => Text(title,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: deepBlue));

  Widget buildHorizontalList(
          List<ServiceItem> items, double screenWidth, double screenHeight) =>
      SizedBox(
        height: screenHeight * 0.22,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.03),
          itemBuilder: (_, index) {
            final item = items[index];
            return ServiceCard(
                item: item,
                width: screenWidth * 0.45,
                lightBlue: lightBlue,
                deepBlue: deepBlue);
          },
        ),
      );

  Widget buildHorizontalWorkerList(
          List<Worker> workers, double screenWidth, double screenHeight) =>
      SizedBox(
        height: screenHeight * 0.22,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: workers.length,
          separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.03),
          itemBuilder: (_, index) {
            final worker = workers[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => WorkerDetailPage(worker: worker)),
                );
              },
              child: WorkerCard(
                  worker: worker, width: screenWidth * 0.45, deepBlue: deepBlue),
            );
          },
        ),
      );
}

// -------------------- MODELS --------------------
class ServiceItem {
  final String title;
  final String subtitle;
  final String imagePath;
  ServiceItem(this.title, this.subtitle, this.imagePath);
}

// -------------------- CARDS --------------------
class ServiceCard extends StatelessWidget {
  final ServiceItem item;
  final double width;
  final Color lightBlue;
  final Color deepBlue;

  const ServiceCard(
      {required this.item,
      required this.width,
      required this.lightBlue,
      required this.deepBlue});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ServiceProf(service: item.title)));
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: deepBlue.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(2, 4))
          ],
        ),
        child: Column(
          children: [
            Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(item.imagePath, fit: BoxFit.cover))),
            const SizedBox(height: 8),
            Text(item.title,
                style: TextStyle(fontWeight: FontWeight.bold, color: deepBlue)),
            const SizedBox(height: 4),
            Text(item.subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class WorkerCard extends StatelessWidget {
  final Worker worker;
  final double width;
  final Color deepBlue;

  const WorkerCard(
      {required this.worker, required this.width, required this.deepBlue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: deepBlue.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(2, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(worker.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: deepBlue, fontSize: 16)),
          Text(worker.service,
              style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text('${worker.rating} (${worker.ratingCount})',
                  style: TextStyle(fontSize: 12, color: Colors.black87))
            ],
          ),
        ],
      ),
    );
  }
}
