import 'package:flutter/material.dart';
import 'package:travel_agency_app/widgets/app_drawer.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF7F4FB),

      appBar: AppBar(
        elevation: 0,
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
        title: const Text(
          "À propos de nous",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // CARD PRINCIPALE
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LOGO
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: 145,
                          height: 145,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // TITRE
                  const Center(
                    child: Text(
                      "Bienvenue chez Hadiy Al Manassek Tours",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PARAGRAPHE
                  const Text(
                    "Votre partenaire de confiance pour l’organisation du Hajj et de la Omra.\n\n"
                    "Située à El Hamma, dans le gouvernorat de Gabès (Tunisie), notre agence accompagne depuis plusieurs années les pèlerins dans la préparation et la réalisation de leur voyage spirituel vers les lieux saints de l’islam.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // IMAGE 1
                  _imageBox("assets/images/a2.jpg"),

                  const SizedBox(height: 25),

                  // SOUS-TITRE
                  _sectionTitle("Nos engagements"),

                  const SizedBox(height: 10),

                  _bullet("🕌 Formules Hajj & Omra complètes et organisées."),
                  const SizedBox(height: 8),
                  _bullet("✈️ Voyage sécurisé avec encadrement expérimenté."),
                  const SizedBox(height: 8),
                  _bullet("🏨 Hébergements conforts proches des lieux saints."),
                  const SizedBox(height: 8),
                  _bullet("🤝 Accompagnement personnalisé du début au retour."),

                  const SizedBox(height: 25),

                  // IMAGE 2
                  _imageBox("assets/images/a1.jpg"),

                  const SizedBox(height: 25),

                  _sectionTitle("Notre objectif"),
                  const SizedBox(height: 10),

                  const Text(
                    "Nous visons à offrir à chaque pèlerin une expérience spirituelle inoubliable, dans les meilleures conditions de sérénité, de foi et d'organisation.\n\n"
                    "Le voyage vers La Mecque et Médine est bien plus qu’un déplacement : c’est un chemin vers la paix intérieure et la rencontre avec la communauté musulmane.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // CONTACT INFO
                  _sectionTitle("Contact"),
                  const SizedBox(height: 15),

                  _contactItem(Icons.location_on, "Avenue Ali Belhouane, El Hamma, Gabès – Tunisie"),
                  const SizedBox(height: 12),
                  _contactItem(Icons.phone, "75 330 300 / 56 802 661"),
                  const SizedBox(height: 12),
                  _contactItem(Icons.email, "mmb14011980@gmail.com"),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------- WIDGETS REUTILISABLES --------

  Widget _imageBox(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        path,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6A1B9A),
      ),
    );
  }

  Widget _bullet(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }

  Widget _contactItem(IconData icon, String info) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Color(0xFF6A1B9A), size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            info,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        )
      ],
    );
  }
}
