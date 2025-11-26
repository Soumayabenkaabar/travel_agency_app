import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminStatsScreen extends StatelessWidget {
  const AdminStatsScreen({super.key});

  Future<Map<String, int>> _fetchStats() async {
    final offers = await FirebaseFirestore.instance.collection('offers').get();
    int totalOffers = offers.size;
    int totalReservations = 0;

    for (var offer in offers.docs) {
      final res = await offer.reference.collection('reservations').get();
      totalReservations += res.size;
    }

    return {
      'offers': totalOffers,
      'reservations': totalReservations,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistiques"), backgroundColor: Colors.deepPurple),
      body: FutureBuilder<Map<String, int>>(
        future: _fetchStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final stats = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("🧳 Offres disponibles : ${stats['offers']}", style: const TextStyle(fontSize: 20)),
                Text("📅 Réservations totales : ${stats['reservations']}", style: const TextStyle(fontSize: 20)),
              ],
            ),
          );
        },
      ),
    );
  }
}
