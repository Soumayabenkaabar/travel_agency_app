import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_agency_app/screens/about_us_screen.dart';
import 'package:travel_agency_app/screens/auth/login_screen.dart';
import 'package:travel_agency_app/screens/offers_screen.dart';
import 'package:travel_agency_app/screens/profile_screen.dart';
import 'package:travel_agency_app/screens/reservations_history_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 103, 58, 183)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 HEADER AVEC INFO UTILISATEUR
            Padding(
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage("assets/images/logo.png"),
                  ),
                  const SizedBox(width: 15),

                  // 👩‍💼 Nom / Email ou Invité
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                      "HADIY AL MANASSEK TOURS",style:  TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                    
                    ],
                  ),
                ],
              ),
            ),

            // 🔹 Menu
            _buildDrawerItem(
              icon: Icons.home,
              text: "Accueil",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OffersScreen()),
              ),
            ),

            _buildDrawerItem(
              icon: Icons.person_outline,
              text: "Mon Profil",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),

            _buildDrawerItem(
              icon: Icons.card_travel,
              text: "Mes Réservations",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReservationsHistoryScreen()),
              ),
            ),

            _buildDrawerItem(
              icon: Icons.info_outline,
              text: "À propos de nous",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsScreen()),
              ),
            ),

      

            const Spacer(),

            // 🚪 Déconnexion / Connexion
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context);

                  if (user != null) {
                    // 🔥 Déconnexion réelle Firebase
                    await FirebaseAuth.instance.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Déconnecté !")),
                    );
                  } else {
                    // 👉 Rediriger vers Login
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      user != null ? Icons.logout : Icons.login,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      user != null ? "Déconnexion" : "Se connecter",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔹 Item de menu réutilisable
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.white, size: 26),
        title: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        onTap: onTap,
      ),
    );
  }
}
