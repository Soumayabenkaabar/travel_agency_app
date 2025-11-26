import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _imageFile;
  String? _imageUrl;  // <--------------- IMPORTANT
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData["name"] ?? "";
    _phoneController.text = widget.userData["phone"] ?? "";
    _imageUrl = widget.userData["profileImageUrl"];   // <--- Charger une seule fois
  }

  // ----- PICK IMAGE -----
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // ----- SAVE PROFILE -----
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? newImageUrl = _imageUrl;

    // ---- Upload image si choisie ----
    if (_imageFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child("${user.uid}.jpg");

      await storageRef.putFile(_imageFile!);
      newImageUrl = await storageRef.getDownloadURL();
    }

    // ---- Update Firestore ----
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "name": _nameController.text.trim(),
      "phone": _phoneController.text.trim(),
      "profileImageUrl": newImageUrl,
    });

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil mis à jour !")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le profil"),
        backgroundColor: Color(0xFF6A1B9A),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // PHOTO
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_imageUrl != null
                              ? NetworkImage(_imageUrl!)
                              : null) as ImageProvider?,
                      child: _imageFile == null && _imageUrl == null
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.white)
                          : null,
                      backgroundColor: Color(0xFF6A1B9A),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // NOM
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nom complet",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PHONE
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Numéro de téléphone",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6A1B9A),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 14),
                    ),
                    onPressed: _saveProfile,
                    child: const Text("Enregistrer",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }
}
