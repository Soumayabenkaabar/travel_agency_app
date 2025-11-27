import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_agency_app/widgets/app_drawer.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> offer;

  const BookingScreen({required this.offer, Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _peopleController = TextEditingController();
  DateTime? _selectedDate;

  // ===========================
  //     RESERVER L'OFFRE
  // ===========================
Future<void> _bookOffer() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez vous connecter pour réserver.")),
    );
    return;
  }

  if (!_formKey.currentState!.validate() || _selectedDate == null) return;

  try {
    final reservationData = {
      "uid": user.uid,
      "userEmail": user.email,
      "people": int.parse(_peopleController.text),
      "date": Timestamp.fromDate(_selectedDate!),  // <<< CORRECT
      "offerId": widget.offer["id"],
      "destination": widget.offer["destination"],
      "price": widget.offer["price"],
      "imageUrl": widget.offer["image"],
      "status": "en attente",
      "createdAt": Timestamp.now(), // <<< NECESSAIRE
    };

  

    // 2️⃣ Enregistrer dans la collection globale
    await FirebaseFirestore.instance
        .collection("reservations")
        .add(reservationData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Réservation enregistrée !')),
    );

    Navigator.pop(context);

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur : $e')),
    );
  }
}

  // ===========================
  //     SELECTEUR DE DATE
  // ===========================
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8A2BE2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: const Text(
          "Réservation",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      drawer: const AppDrawer(),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // === Info de l'offre ===
              Text(
                "${offer['title']} - ${offer['price']} DT",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // === Nombre de personnes ===
              TextFormField(
                controller: _peopleController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Nombre de personnes",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || int.tryParse(value) == null
                        ? "Entrez un nombre valide"
                        : null,
              ),
              const SizedBox(height: 15),

              // === Date ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null
                        ? "Aucune date choisie"
                        : "Date : ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                  ),
                  ElevatedButton(
                    onPressed: _selectDate,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                    child: const Text("Choisir la date"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // === Bouton CONFIRMER ===
              Center(
                child: ElevatedButton.icon(
                  onPressed: _bookOffer,
                  icon: const Icon(Icons.check),
                  label: const Text("Confirmer la réservation"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
