import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_agency_app/screens/auth/login_screen.dart';

import 'edit_profile_screen.dart';
import 'password_change_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: user == null
          ? _notConnected(context)
          : _buildProfile(context, user),
    );
  }

  Widget _notConnected(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("Vous n'êtes pas connecté."),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("Se connecter",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(BuildContext context, User user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        if (data == null) return const Center(child: Text("Aucune donnée trouvée."));

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8A2BE2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF6A1B9A),
                      backgroundImage: data['profileImageUrl'] != null
                          ? NetworkImage(data['profileImageUrl'])
                          : null,
                      child: data['profileImageUrl'] == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      data['name'] ?? "Nom non défini",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(user.email ?? "", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone, color: Colors.grey, size: 18),
                        const SizedBox(width: 5),
                        Text(data['phone'] ?? "N/A", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _profileButton(
                      icon: Icons.edit,
                      text: "Modifier le profil",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProfileScreen(userData: data)),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _profileButton(
                      icon: Icons.lock,
                      text: "Changer mot de passe",
                      color: Colors.deepPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PasswordChangeScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _profileButton(
                      icon: Icons.delete,
                      text: "Supprimer mon compte",
                      color: Colors.red,
                      onTap: () => _deleteAccount(context),
                    ),
                    const SizedBox(height: 10),
                    _profileButton(
                      icon: Icons.logout,
                      text: "Déconnexion",
                      color: Colors.black87,
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool confirm = false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer le compte"),
        content: const Text("Êtes-vous sûr ? Cette action est irréversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(onPressed: () { confirm = true; Navigator.pop(context); }, child: const Text("Supprimer")),
        ],
      ),
    );

    if (!confirm) return;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).delete();
    await user.delete();

    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  Widget _profileButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
