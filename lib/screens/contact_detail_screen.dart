// lib/screens/contact_detail_screen.dart

import 'package:flutter/material.dart';
import 'contact_edit_screen.dart';
import '../models/contact.dart';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name ?? 'Contact Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Contact',
            onPressed: () async {
              final bool? wasUpdated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactEditScreen(contact: contact),
                ),
              );

              if (wasUpdated == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact.imageUrl != null && contact.imageUrl!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    contact.imageUrl!,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 200,
                        child: Icon(Icons.error, size: 50, color: Colors.red),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.person, 'Name', contact.name),
            _buildDetailRow(Icons.email, 'Email', contact.email),
            _buildDetailRow(Icons.phone, 'Phone', contact.phone),
            _buildDetailRow(Icons.business, 'Company', contact.company),
            _buildDetailRow(Icons.work, 'Job Title', contact.activity),
            _buildDetailRow(Icons.location_on, 'Address', contact.address),
            _buildDetailRow(Icons.language, 'Website', contact.website),
            const Divider(height: 32),
            _buildDetailRow(
              Icons.check_circle_outline,
              'Confidence Score',
              '${(contact.confidenceScore * 100).toStringAsFixed(1)}%',
            ),
            _buildDetailRow(
              Icons.rate_review,
              'Needs Review',
              contact.needsReview ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
