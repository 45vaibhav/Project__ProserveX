import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceWorkersPage extends StatelessWidget {
  final String serviceName;
  const ServiceWorkersPage({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF2980B9);
    return Scaffold(
      appBar: AppBar(title: Text('$serviceName Workers')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workers')
            .where('service', isEqualTo: serviceName)
            .where('approved', isEqualTo: true) // only approved
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return const Center(child: Text('Error loading workers'));

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return Center(child: Text('No $serviceName workers available yet', style: const TextStyle(color: Colors.grey)));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (c, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(data['name'] ?? 'Unknown'),
                  subtitle: Text('${data['location'] ?? 'N/A'} • ${data['experience'] ?? '0'} yrs'),
                  trailing: IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () async {
                      final phone = data['phone'] ?? '';
                      final uri = Uri.parse('tel:$phone');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open dialer')));
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
