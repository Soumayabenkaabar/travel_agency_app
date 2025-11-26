import 'package:flutter/material.dart';
import 'package:travel_agency_app/screens/admin/admin_manage_offers_screen.dart';
import 'package:travel_agency_app/screens/admin/admin_reservations_screen.dart';
import 'package:travel_agency_app/screens/admin/admin_stats_screen.dart';
import 'package:travel_agency_app/screens/offers_screen.dart'; // ⬅️ pour rediriger après logout

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _logout(BuildContext context) {
    // Si tu ajoutes Firebase Auth plus tard → FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OffersScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de bord - Admin"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _AdminCard(
              title: "Gérer les offres",
              icon: Icons.card_travel,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminManageOffersScreen()),
                );
              },
            ),
            _AdminCard(
              title: "Réservations",
              icon: Icons.list_alt,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminReservationsScreen()),
                );
              },
            ),
            _AdminCard(
              title: "Statistiques",
              icon: Icons.bar_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminStatsScreen()),
                );
              },
            ),

            // 🔴 Nouvelle carte : Déconnexion
            _AdminCard(
              title: "Déconnexion",
              icon: Icons.logout,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLogout = title == "Déconnexion";

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isLogout ? Colors.red.shade100 : Colors.deepPurple.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 60,
                color: isLogout ? Colors.red : Colors.deepPurple,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isLogout ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
