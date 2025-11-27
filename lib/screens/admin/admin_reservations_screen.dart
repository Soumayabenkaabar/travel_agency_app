import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminReservationsScreen extends StatelessWidget {
  const AdminReservationsScreen({super.key});

  Future<void> _updateStatus(String resId, String status) async {
    await FirebaseFirestore.instance
        .collection('reservations')
        .doc(resId)
        .update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des réservations"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservations = snapshot.data!.docs;

          if (reservations.isEmpty) {
            return const Center(
              child: Text("Aucune réservation trouvée."),
            );
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final res = reservations[index];
              final data = res.data() as Map<String, dynamic>;

              final status = data['status'] ?? 'En attente';
              final date = data['date']?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: ListTile(
title: Text(
  "${data['userEmail']} (${data['people']} pers)",
  style: TextStyle(
    fontSize: 13,           // taille de la police
    fontWeight: FontWeight.bold, // gras
    color: Colors.deepPurple,   // couleur
    fontStyle: FontStyle.italic, // italique (optionnel)
  ),
),
                  subtitle: Text(
                    "Destination : ${data['destination'] ?? '---'}\n"
                    "Date : ${date != null ? "${date.day}/${date.month}/${date.year}" : '---'}\n"
                    "Statut : $status",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () =>
                            _updateStatus(res.id, 'Validée'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () =>
                            _updateStatus(res.id, 'Refusée'),
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
}
