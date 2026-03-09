import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/contact.dart';
import '../providers/contact_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';

class ContactEditScreen extends StatefulWidget {
  const ContactEditScreen({super.key, required this.contact});

  final Contact contact;

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
    _companyController =
        TextEditingController(text: widget.contact.company ?? '');
    _activityController =
        TextEditingController(text: widget.contact.activity ?? '');
    _addressController =
        TextEditingController(text: widget.contact.address ?? '');
    _websiteController =
        TextEditingController(text: widget.contact.website ?? '');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update contact: $e')),
      );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Edit Contact')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.midnight, Color(0xFF07131C), Color(0xFF061C21)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                const BrandLogo(compact: true, showTagline: false),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refine the scanned data',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete the required fields before saving the updated contact card.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (missingFields.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD98B1B).withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFD98B1B).withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Text(
                            'Missing required fields: ${missingFields.join(', ')}',
                            style: const TextStyle(color: Color(0xFFFFD18A)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      _Field(
                        controller: _nameController,
                        label: 'Name *',
                        validator: (value) =>
                            _requiredValidator(value, 'Name'),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _emailController,
                        label: 'Email *',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            _requiredValidator(value, 'Email'),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _phoneController,
                        label: 'Phone *',
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            _requiredValidator(value, 'Phone'),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _companyController,
                        label: 'Company *',
                        validator: (value) =>
                            _requiredValidator(value, 'Company'),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _activityController,
                        label: 'Job Title',
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _addressController,
                        label: 'Address',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _websiteController,
                        label: 'Website',
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            _isSaving ? 'Saving...' : 'Save Changes',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      style: const TextStyle(color: Colors.white),
    );
  }
}
