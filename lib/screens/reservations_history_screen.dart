import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class ReservationsHistoryScreen extends StatelessWidget {
  const ReservationsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ==== Si utilisateur non connecté ====
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Mes Réservations"),
          backgroundColor: Color(0xFF6A1B9A),
        ),
        drawer: const AppDrawer(),
        body: const Center(
          child: Text(
            "Veuillez vous connecter pour voir vos réservations.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Réservations"),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      drawer: const AppDrawer(),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .where('uid', isEqualTo: user.uid)
            .snapshots(),

        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucune réservation trouvée.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final history = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final data = history[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),

                  title: Text(
                    data['destination'] ?? "Destination inconnue",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text("Personnes : ${data['people'] ?? '---'}"),
                      Text("Prix : ${data['price'] ?? '--'} DT"),

                      if (data['date'] != null)
                        Text(
                          "Séjour : ${data['date'].toDate().day}/${data['date'].toDate().month}/${data['date'].toDate().year}",
                        ),

                      if (data['createdAt'] != null)
                        Text(
                          "Réservé le : ${data['createdAt'].toDate().day}/${data['createdAt'].toDate().month}/${data['createdAt'].toDate().year}",
                        ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: _statusBg(data['status'] ?? "En attente"),
                        ),
                        child: Text(
                          "Statut : ${data['status'] ?? "En attente"}",
                          style: TextStyle(
                            color: _statusText(data['status'] ?? "En attente"),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ==== Couleur du badge ====
  Color _statusBg(String status) {
    switch (status) {
      case "Validée":
        return Colors.green.withOpacity(0.2);
      case "Refusée":
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.orange.withOpacity(0.2);
    }
  }

  Color _statusText(String status) {
    switch (status) {
      case "Validée":
        return Colors.green;
      case "Refusée":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
