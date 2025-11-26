import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AdminManageOffersScreen extends StatefulWidget {
  const AdminManageOffersScreen({super.key});

  @override
  State<AdminManageOffersScreen> createState() =>
      _AdminManageOffersScreenState();
}

class _AdminManageOffersScreenState extends State<AdminManageOffersScreen> {
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune image sélectionnée.")),
        );
        return;
      }

      final path = result.files.single.path;
      if (path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la lecture du fichier.")),
        );
        return;
      }

      setState(() => _isUploading = true);

      final file = File(path);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance.ref().child('offers_images/$fileName.jpg');
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      setState(() {
        _selectedImage = file;
        _imageUrl = downloadUrl;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Image uploadée avec succès !")),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  Future<void> _addOffer() async {
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('offers').add({
      'title': _titleController.text,
      'destination': _destinationController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'imageUrl': _imageUrl,
      'createdAt': Timestamp.now(),
    });

    _titleController.clear();
    _destinationController.clear();
    _priceController.clear();
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  Future<void> _deleteOffer(String id) async {
    await FirebaseFirestore.instance.collection('offers').doc(id).delete();
  }

  Future<void> _editOffer(String id, Map<String, dynamic> data) async {
    _titleController.text = data['title'] ?? '';
    _destinationController.text = data['destination'] ?? '';
    _priceController.text = data['price'].toString();
    _imageUrl = data['imageUrl'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier l'offre"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Titre"),
              ),
              TextField(
                controller: _destinationController,
                decoration: const InputDecoration(labelText: "Destination"),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Prix"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickAndUploadImage,
                icon: const Icon(Icons.image),
                label: const Text("Changer l'image"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('offers').doc(id).update({
                'title': _titleController.text,
                'destination': _destinationController.text,
                'price': double.tryParse(_priceController.text) ?? 0,
                'imageUrl': _imageUrl,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Offre mise à jour ✅")),
              );
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gérer les offres"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Titre")),
                TextField(
                    controller: _destinationController,
                    decoration: const InputDecoration(labelText: "Destination")),
                TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: "Prix")),
                const SizedBox(height: 10),
                _selectedImage != null
                    ? Image.file(_selectedImage!, width: 100, height: 100, fit: BoxFit.cover)
                    : const Text("Aucune image sélectionnée"),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickAndUploadImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Importer une image"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _addOffer,
                  icon: const Icon(Icons.add),
                  label: const Text("Ajouter une offre"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('offers')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final offers = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    final data = offer.data() as Map<String, dynamic>;

                    return ListTile(
                      leading: data['imageUrl'] != null
                          ? Image.network(data['imageUrl'],
                              width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 40),
                      title: Text(data['title'] ?? ''),
                      subtitle: Text("${data['destination']} - ${data['price']} \DT"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editOffer(offer.id, data),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteOffer(offer.id),
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
