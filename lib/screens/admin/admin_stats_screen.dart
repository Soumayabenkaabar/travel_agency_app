import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminStatsScreen extends StatelessWidget {
  const AdminStatsScreen({super.key});

  // --- Nombre total de clients ---
  Future<int> countClients() async {
    final snap = await FirebaseFirestore.instance.collection('users').get();
    return snap.size;
  }

  // --- Nombre de clients ayant fait une réservation ---
  Future<int> countClientsWithReservation() async {
    final snap = await FirebaseFirestore.instance.collection('reservations').get();

    // CORRIGÉ : dans Firestore le champ = uid
    final uniqueUsers = snap.docs.map((d) => d['uid']).toSet();

    return uniqueUsers.length;
  }

  // --- Nombre d'offres ---
  Future<int> countOffers() async {
    final snap = await FirebaseFirestore.instance.collection('offers').get();
    return snap.size;
  }

  // --- Total & moyenne des étoiles par offre ---
  Future<Map<String, dynamic>> fetchOfferStars() async {
    final Map<String, dynamic> result = {};

    // Charger TOUTES les reviews (elles sont à la racine)
    final reviewsSnap =
        await FirebaseFirestore.instance.collection('reviews').get();

    // Charger toutes les offres pour retrouver leur titre
    final offersSnap =
        await FirebaseFirestore.instance.collection('offers').get();

    for (var offer in offersSnap.docs) {
      final offerId = offer.id; // ID Firestore de l’offre

      // Filtrer les reviews liées à cette offre
      final relatedReviews = reviewsSnap.docs
          .where((r) => r['offerId'].toString() == offerId.toString())
          .toList();

      int totalStars = 0;

      for (var r in relatedReviews) {
        totalStars += (r['rating'] as num?)?.toInt() ?? 0;
      }

      double avg = relatedReviews.isEmpty
          ? 0
          : totalStars / relatedReviews.length;

      result[offer['title']] = {
        'total': totalStars,
        'avg': avg,
        'count': relatedReviews.length,
      };
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      appBar: AppBar(
        title: const Text("Statistiques"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder(
        future: Future.wait([
          countClients(),
          countClientsWithReservation(),
          countOffers(),
          fetchOfferStars(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clients = snapshot.data![0] as int;
          final clientsWithRes = snapshot.data![1] as int;
          final offers = snapshot.data![2] as int;
          final starsMap = snapshot.data![3] as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              statCard("Nombre total de clients", clients),
              statCard("Clients avec réservation", clientsWithRes),
              statCard("Nombre d’offres disponibles", offers),
              const SizedBox(height: 20),
              const Text(
                "⭐ Statistiques des Offres",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...starsMap.entries.map((entry) {
                final title = entry.key;
                final data = entry.value;

                return Card(
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text(
                      "Total étoiles : ${data['total']}\n"
                      "Moyenne : ${data['avg'].toStringAsFixed(1)} / 5\n"
                      "Nombre d'avis : ${data['count']}",
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget statCard(String title, int value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: Text(
          value.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
