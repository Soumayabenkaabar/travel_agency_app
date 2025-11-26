import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminReservationsScreen extends StatelessWidget {
  const AdminReservationsScreen({super.key});

  Future<void> _updateStatus(String offerId, String resId, String status) async {
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(offerId)
        .collection('reservations')
        .doc(resId)
        .update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réservations"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('offers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final offers = snapshot.data!.docs;

          return ListView(
            children: offers.map((offer) {
              return StreamBuilder<QuerySnapshot>(
                stream: offer.reference.collection('reservations').snapshots(),
                builder: (context, resSnap) {
                  if (!resSnap.hasData) return const SizedBox();
                  final reservations = resSnap.data!.docs;

                  return ExpansionTile(
                    title: Text(offer['title'] ?? 'Offre sans titre'),
                    children: reservations.map((res) {
                      final data = res.data() as Map<String, dynamic>;
                      final status = data['status'] ?? 'En attente';

                      return ListTile(
                        title: Text("${data['name']} (${data['people']} pers)"),
                        subtitle: Text(
                            "Date : ${data['date'].toDate().day}/${data['date'].toDate().month}/${data['date'].toDate().year}\nStatut : $status"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _updateStatus(offer.id, res.id, 'Validée'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _updateStatus(offer.id, res.id, 'Refusée'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
