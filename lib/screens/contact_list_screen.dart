import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/contact.dart';
import '../providers/contact_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AC Contacts'),
        actions: [
          IconButton(
            tooltip: 'Refresh contacts',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              Provider.of<ContactProvider>(
                context,
                listen: false,
              ).fetchContacts();
            },
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.midnight, Color(0xFF07131C), Color(0xFF061C21)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -90,
              right: -50,
              child: _GlowOrb(color: AppTheme.cyan, size: 260),
            ),
            const Positioned(
              top: 180,
              left: -70,
              child: _GlowOrb(color: AppTheme.blue, size: 220),
            ),
            SafeArea(
              child: Consumer<ContactProvider>(
                builder: (context, provider, child) {
                  return RefreshIndicator(
                    color: AppTheme.cyan,
                    onRefresh: provider.fetchContacts,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                            child: _HeroPanel(
                              contactCount: provider.contacts.length,
                              state: provider.state,
                              onScanPressed: () => _showImagePicker(context),
                            ),
                          ),
                        ),
                        switch (provider.state) {
                          DataState.loading => const SliverFillRemaining(
                            hasScrollBody: false,
                            child: _FeedbackState(
                              icon: Icons.radar_rounded,
                              title: 'Syncing contacts',
                              message:
                                  'Loading your scanned business cards and recent updates.',
                              busy: true,
                            ),
                          ),
                          DataState.error => SliverFillRemaining(
                            hasScrollBody: false,
                            child: _FeedbackState(
                              icon: Icons.cloud_off_rounded,
                              title: 'Connection issue',
                              message: provider.errorMessage,
                            ),
                          ),
                          DataState.initial => const SliverFillRemaining(
                            hasScrollBody: false,
                            child: _FeedbackState(
                              icon: Icons.touch_app_rounded,
                              title: 'Ready to scan',
                              message:
                                  'Use the scanner to capture your first card or pull the latest contacts.',
                            ),
                          ),
                          DataState.loaded =>
                            provider.contacts.isEmpty
                                ? const SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: _FeedbackState(
                                      icon: Icons.badge_outlined,
                                      title: 'No contacts yet',
                                      message:
                                          'Scan a business card to build your AC contact archive.',
                                    ),
                                  )
                                : SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      8,
                                      20,
                                      120,
                                    ),
                                    sliver: SliverList.builder(
                                      itemCount: provider.contacts.length,
                                      itemBuilder: (context, index) {
                                        final contact =
                                            provider.contacts[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 14,
                                          ),
                                          child: _ContactCard(
                                            contact: contact,
                                            onDelete: () =>
                                                _deleteFromList(contact),
                                            onTap: () async {
                                              final wasUpdated =
                                                  await Navigator.push<bool>(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ContactDetailScreen(
                                                            contact: contact,
                                                          ),
                                                    ),
                                                  );

                                              if (wasUpdated == true &&
                                                  context.mounted) {
                                                Provider.of<ContactProvider>(
                                                  context,
                                                  listen: false,
                                                ).fetchContacts();
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                        },
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showImagePicker(context),
        icon: const Icon(Icons.document_scanner_rounded),
        label: const Text('Scan Card'),
      ),
    );
  }

  Future<void> _deleteFromList(Contact contact) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text(
          'Delete "${contact.name ?? 'this contact'}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    try {
      await Provider.of<ContactProvider>(
        context,
        listen: false,
      ).deleteContact(contact.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete contact: $e')));
    }
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add a new business card',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a source for card upload and extraction.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _SourceButton(
                            icon: Icons.photo_library_rounded,
                            label: 'Gallery',
                            onTap: () {
                              Navigator.pop(context);
                              _processImage(ImageSource.gallery);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _SourceButton(
                            icon: Icons.photo_camera_rounded,
                            label: 'Camera',
                            onTap: () {
                              Navigator.pop(context);
                              _processImage(ImageSource.camera);
                            },
                          ),
                        ),
                      ],
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

  Future<void> _processImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (image == null || !mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Extracting text and uploading...')),
          ],
        ),
      ),
    );

    try {
      final imageFile = File(image.path);

      final inputImage = InputImage.fromFilePath(imageFile.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      if (!mounted) return;
      Navigator.pop(context);

      final provider = Provider.of<ContactProvider>(context, listen: false);
      await provider.submitCardAndRefresh(
        imageFile,
        extractedText: recognizedText.text,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while uploading the card: $e'),
        ),
      );
    }
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.contactCount,
    required this.state,
    required this.onScanPressed,
  });

  final int contactCount;
  final DataState state;
  final VoidCallback onScanPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.07),
            AppTheme.surfaceRaised.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyan.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandLogo(compact: true),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(
                icon: Icons.people_alt_rounded,
                label: '$contactCount contacts',
              ),
              _StatChip(
                icon: Icons.analytics_rounded,
                label: switch (state) {
                  DataState.loading => 'Syncing',
                  DataState.error => 'Needs attention',
                  DataState.loaded => 'Ready',
                  DataState.initial => 'Idle',
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 16),
              FilledButton.tonalIcon(
                onPressed: onScanPressed,
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('Capture'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onTap,
    required this.onDelete,
  });

  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final initials = (contact.name?.trim().isNotEmpty ?? false)
        ? contact.name!.trim().substring(0, 1).toUpperCase()
        : 'C';

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.blue, AppTheme.cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name ?? 'Unnamed contact',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contact.company ??
                              contact.email ??
                              'No company listed',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: AppTheme.surfaceRaised,
                    iconColor: Colors.white70,
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.email_outlined,
                      text: contact.email ?? 'No email',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.phone_outlined,
                      text: contact.phone ?? 'No phone',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _MiniBadge(
                    label:
                        '${(contact.confidenceScore * 100).toStringAsFixed(0)}% confidence',
                  ),
                  const SizedBox(width: 8),
                  if (contact.needsReview)
                    const _MiniBadge(label: 'Review', color: Color(0xFFD98B1B)),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, yyyy').format(contact.createdAt),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.cyan),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, this.color = AppTheme.teal});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.cyan),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.06),
              AppTheme.surfaceRaised.withValues(alpha: 0.95),
            ],
          ),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 34, color: AppTheme.cyan),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _FeedbackState extends StatelessWidget {
  const _FeedbackState({
    required this.icon,
    required this.title,
    required this.message,
    this.busy = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                const CircularProgressIndicator()
              else
                Icon(icon, size: 40, color: AppTheme.cyan),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.26),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
