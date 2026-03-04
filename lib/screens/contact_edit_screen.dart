import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/contact.dart';
import '../providers/contact_provider.dart';

class ContactEditScreen extends StatefulWidget {
  final Contact contact;

  const ContactEditScreen({super.key, required this.contact});

  @override
  State<ContactEditScreen> createState() => _ContactEditScreenState();
}

class _ContactEditScreenState extends State<ContactEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _companyController;
  late final TextEditingController _activityController;
  late final TextEditingController _addressController;
  late final TextEditingController _websiteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name ?? '');
    _emailController = TextEditingController(text: widget.contact.email ?? '');
    _phoneController = TextEditingController(text: widget.contact.phone ?? '');
    _companyController = TextEditingController(text: widget.contact.company ?? '');
    _activityController = TextEditingController(text: widget.contact.activity ?? '');
    _addressController = TextEditingController(text: widget.contact.address ?? '');
    _websiteController = TextEditingController(text: widget.contact.website ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _activityController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  List<String> _missingRequiredFields() {
    final missing = <String>[];
    if (_nameController.text.trim().isEmpty) missing.add('Name');
    if (_emailController.text.trim().isEmpty) missing.add('Email');
    if (_phoneController.text.trim().isEmpty) missing.add('Phone');
    if (_companyController.text.trim().isEmpty) missing.add('Company');
    return missing;
  }

  String? _optionalValue(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await Provider.of<ContactProvider>(context, listen: false).updateContact(
        contactId: widget.contact.id,
        fields: {
          'name': _optionalValue(_nameController),
          'email': _optionalValue(_emailController),
          'phone': _optionalValue(_phoneController),
          'company': _optionalValue(_companyController),
          'activity': _optionalValue(_activityController),
          'address': _optionalValue(_addressController),
          'website': _optionalValue(_websiteController),
        },
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update contact: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final missingFields = _missingRequiredFields();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Contact')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (missingFields.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Text(
                  'Missing required fields: ${missingFields.join(', ')}',
                  style: TextStyle(color: Colors.orange.shade900),
                ),
              ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *'),
              textInputAction: TextInputAction.next,
              validator: (value) => _requiredValidator(value, 'Name'),
              onChanged: (_) => setState(() {}),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email *'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) => _requiredValidator(value, 'Email'),
              onChanged: (_) => setState(() {}),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone *'),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) => _requiredValidator(value, 'Phone'),
              onChanged: (_) => setState(() {}),
            ),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Company *'),
              textInputAction: TextInputAction.next,
              validator: (value) => _requiredValidator(value, 'Company'),
              onChanged: (_) => setState(() {}),
            ),
            TextFormField(
              controller: _activityController,
              decoration: const InputDecoration(labelText: 'Job Title'),
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(labelText: 'Website'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
