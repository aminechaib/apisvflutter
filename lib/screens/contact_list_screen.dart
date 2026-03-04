// lib/screens/contact_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart'; // This import should now work
import '../models/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'contact_detail_screen.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactProvider>(context, listen: false).fetchContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ContactProvider>(
                context,
                listen: false,
              ).fetchContacts();
            },
          ),
        ],
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, child) {
          // FIX: Removed the redundant 'default' case.
          switch (provider.state) {
            case DataState.loading:
              return const Center(child: CircularProgressIndicator());
            case DataState.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'An error occurred:\n${provider.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            case DataState.loaded:
              if (provider.contacts.isEmpty) {
                return const Center(child: Text('No contacts found.'));
              }
              return _buildContactList(provider.contacts);
            case DataState.initial:
              return const Center(
                child: Text('Press refresh to load contacts.'),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImagePicker(context),
        tooltip: 'Scan New Card',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildContactList(List<Contact> contacts) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.shade100,
              child: Text(
                contact.name?.isNotEmpty == true
                    ? contact.name![0].toUpperCase()
                    : 'C',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            title: Text(
              contact.name ?? 'No Name',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(contact.email ?? 'No Email'),
            trailing: Text(DateFormat('MMM d, yyyy').format(contact.createdAt)),
            onTap: () async {
              final bool? wasUpdated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailScreen(contact: contact),
                ),
              );

              if (wasUpdated == true && context.mounted) {
                Provider.of<ContactProvider>(
                  context,
                  listen: false,
                ).fetchContacts();
              }
            },
          ),
        );
      },
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Card(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _processImage(ImageSource.gallery);
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 50.0),
                        SizedBox(height: 12.0),
                        Text("Gallery", textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _processImage(ImageSource.camera);
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 50.0),
                        SizedBox(height: 12.0),
                        Text("Camera", textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _processImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;
    if (!mounted) return; // FIX: Guard against async gap

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Extracting text..."),
          ],
        ),
      ),
    );

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();

      if (!mounted) return; // FIX: Guard against async gap

      Navigator.pop(context); // Close the dialog

      String ocrText = recognizedText.text;
      if (ocrText.isEmpty) {
        if (!mounted) return; // FIX: Guard against async gap
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not find any text in the image.'),
          ),
        );
        return;
      }

      final provider = Provider.of<ContactProvider>(context, listen: false);
      await provider.submitTextAndRefresh(ocrText);
    } catch (e) {
      if (!mounted) return; // FIX: Guard against async gap
      Navigator.pop(context); // Close the dialog on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during OCR: $e')),
      );
    }
  }
}
