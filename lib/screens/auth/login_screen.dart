import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_agency_app/screens/admin/admin_dashboard_screen.dart';
import 'package:travel_agency_app/screens/offers_screen.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

Future<void> login() async {
  if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez remplir tous les champs.")),
    );
    return;
  }

  final email = emailController.text.trim();
  final pass = passwordController.text.trim();

  // ✅ 1) Bypass : si admin → aller direct au dashboard
  if (email == "admin@gmail.com" && pass == "admin1234") {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
    );
    return;
  }

  try {
    setState(() => loading = true);

    // ✅ 2) Clients → Firebase login
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: pass,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OffersScreen()),
    );

  } on FirebaseAuthException catch (e) {
    String message = "Erreur : Identifiants incorrects.";

    if (e.code == 'user-not-found') {
      message = "Aucun compte trouvé avec cet email.";
    } else if (e.code == 'wrong-password') {
      message = "Mot de passe incorrect.";
    } else if (e.code == 'invalid-email') {
      message = "Adresse email invalide.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } finally {
    setState(() => loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF8A2BE2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Connexion",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),

                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: "Mot de passe",
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),

                    const SizedBox(height: 20),

                    loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: login,
                            child: const Text(
                              "Se connecter",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text("Créer un compte"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
