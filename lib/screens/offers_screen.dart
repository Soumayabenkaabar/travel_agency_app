import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_agency_app/screens/auth/login_screen.dart';
import 'package:travel_agency_app/screens/offer_details_screen.dart';
import 'package:travel_agency_app/widgets/app_drawer.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  String searchQuery = "";
  double? minPrice;
  double? maxPrice;
  bool? isAscending;

  // Images pour la publicité / promotion
  final List<String> pubsImages = [
    "assets/images/a1.jpg",
    "assets/images/a2.jpg",
    "assets/images/a3.jpg",
    
  ];

  void openFilterSheet() {
    final TextEditingController minCtrl =
        TextEditingController(text: minPrice?.toString() ?? "");
    final TextEditingController maxCtrl =
        TextEditingController(text: maxPrice?.toString() ?? "");

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => StatefulBuilder(
        builder: (context, setStateSheet) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Filtres",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tri par prix :", style: TextStyle(fontSize: 16)),
                    DropdownButton<bool?>(
                      value: isAscending,
                      items: const [
                        DropdownMenuItem(value: null, child: Text("Aucun")),
                        DropdownMenuItem(value: true, child: Text("Croissant ↑")),
                        DropdownMenuItem(value: false, child: Text("Décroissant ↓")),
                      ],
                      onChanged: (value) {
                        setStateSheet(() => isAscending = value);
                      },
                    )
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Prix min",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Prix max",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      minPrice = minCtrl.text.isNotEmpty
                          ? double.tryParse(minCtrl.text)
                          : null;
                      maxPrice = maxCtrl.text.isNotEmpty
                          ? double.tryParse(maxCtrl.text)
                          : null;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Appliquer les filtres"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Offres de voyage'),
  backgroundColor: Colors.deepPurple,
  actions: [
    Builder(
      builder: (context) {
        final user = FirebaseAuth.instance.currentUser;
        // Si aucun utilisateur connecté → afficher l'icône
        if (user == null) {
          return IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Espace admin',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          );
        } else {
          // Sinon rien / inactif
          return const SizedBox.shrink(); // espace vide
        }
      },
    ),
  ],
),


      drawer: const AppDrawer(),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔍 BARRE DE RECHERCHE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              height: 50,
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Rechercher une offre...",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() => searchQuery = value.toLowerCase());
                      },
                    ),
                  ),
                  InkWell(
                    onTap: openFilterSheet,
                    child: const Icon(Icons.tune, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 🟣 CARROUSEL PUBLICITÉ
          CarouselSlider(
            items: pubsImages.map((img) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage(img),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 160,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              viewportFraction: 0.85,
            ),
          ),

          const SizedBox(height: 15),

          // 📋 LISTE DES OFFRES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('offers')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Map<String, dynamic>> offers =
                    snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id;
                  return data;
                }).toList();

                offers = offers.where((offer) {
                  final text = searchQuery.trim();
                  return offer["title"]
                          .toString()
                          .toLowerCase()
                          .contains(text) ||
                      offer["destination"]
                          .toString()
                          .toLowerCase()
                          .contains(text);
                }).toList();

                if (minPrice != null) {
                  offers =
                      offers.where((o) => o["price"] >= minPrice!).toList();
                }
                if (maxPrice != null) {
                  offers =
                      offers.where((o) => o["price"] <= maxPrice!).toList();
                }

                if (isAscending != null) {
                  offers.sort((a, b) => isAscending!
                      ? a["price"].compareTo(b["price"])
                      : b["price"].compareTo(a["price"]));
                }

                return ListView.builder(
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            ),
                            child: offer["imageUrl"] != null
                                ? Image.network(
                                    offer["imageUrl"],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child:
                                          Icon(Icons.image_not_supported, size: 60),
                                    ),
                                  ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer["title"],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.deepPurple, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      offer["destination"],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "${offer["price"]} DT",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              OfferDetailsScreen(offer: offer),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Voir détails",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
}
