import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_agency_app/screens/auth/login_screen.dart';
import 'package:travel_agency_app/screens/booking_screen.dart';
import 'package:travel_agency_app/widgets/app_drawer.dart';

class OfferDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> offer;

  const OfferDetailsScreen({required this.offer, Key? key}) : super(key: key);

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;

  Future<void> _addReview() async {
    if (_nameController.text.isEmpty || _commentController.text.isEmpty) return;
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Veuillez vous connecter pour laisser un avis.")),
  );

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
  return;
}

    try {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(widget.offer['id']) // ✅ ici on récupère l’ID de l’offre
          .collection('reviews')
          .add({
        'userName': _nameController.text,
        'comment': _commentController.text,
        'rating': _rating,
        'createdAt': Timestamp.now(),
      });

      _nameController.clear();
      _commentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avis ajouté avec succès !')),
      );

      setState(() {}); // recharger les avis
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;

    return Scaffold(
      appBar: AppBar(
        title: Text(offer['title'] ?? 'Détails de l’offre'),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFF8A2BE2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Détails de l'offre ---
            // Image principale
            if (offer['imageUrl'] != null && offer['imageUrl'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  offer['imageUrl'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 80),
              ),

            const SizedBox(height: 20),

            Text(
              offer['title'] ?? 'Titre non disponible',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${offer['destination']} - ${offer['price']} \DT',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(offer['description'] ?? ''),
            const SizedBox(height: 20),
Center(
  child: SizedBox(
    width: double.infinity, // ✔ plein largeur comme "Envoyer mon avis"
    child: ElevatedButton.icon(
      onPressed: () {
         final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Not logged → redirect to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez vous connecter pour réserver.")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      // Logged → go to booking
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingScreen(offer: offer),
          ),
        );
      },
      icon: const Icon(
        Icons.shopping_cart_checkout,
        color: Colors.black, 
      ),
      label: const Text(
        'Réserver maintenant',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6A1B9A), 
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
        ),
        elevation: 4,
      ),
    ),
  ),
),







            // --- Liste des avis ---
            const Text("Avis des utilisateurs",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('offers')
                  .doc(offer['id'])
                  .collection('reviews')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("Aucun avis pour le moment.");
                }

                final reviews = snapshot.data!.docs;

                return Column(
                  children: reviews.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.deepPurple),
                        title: Text(data['userName'] ?? 'Anonyme'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['comment'] ?? ''),
                            Row(
                              children: List.generate(
                                (data['rating'] ?? 0),
                                (index) => const Icon(Icons.star, color: Colors.amber, size: 16),

                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
// --- Formulaire stylé d'ajout d'avis ---
const SizedBox(height: 30),
Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Ajouter un avis",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6A1B9A),
        ),
      ),

      const SizedBox(height: 20),

      // --- Champ Nom ---
      TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: "Votre nom",
          prefixIcon: const Icon(Icons.person, color: Color(0xFF6A1B9A)),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 15),

      // --- Champ Commentaire ---
      TextField(
        controller: _commentController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: "Votre commentaire",
          prefixIcon: const Icon(Icons.message, color: Color(0xFF6A1B9A)),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 20),

      // --- Sélection des étoiles ---
      const Text(
        "Votre note",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),

      Row(
        children: List.generate(5, (index) {
          return GestureDetector(
            onTap: () {
              setState(() => _rating = index + 1);
            },
            child: Icon(
              Icons.star,
              size: 32,
              color: (index < _rating) ? Colors.amber : Colors.grey.shade400,
            ),
          );
        }),
      ),

      const SizedBox(height: 25),

      // --- Bouton Envoyer ---
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _addReview,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: const Color(0xFF6A1B9A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: const Text(
            "Envoyer mon avis",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
          ),
        ),
      ),
    ],
  ),
),

          ],
        ),
      ),
      drawer: const AppDrawer(),

    );
  }
}
