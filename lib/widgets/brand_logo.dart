import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  static const String assetPath = 'assets/images/ag_logo.png';

  const BrandLogo({
    super.key,
    this.compact = false,
    this.showTagline = true,
  });

  final bool compact;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final logoWidth = compact ? 170.0 : 280.0;
    final logoHeight = compact ? 110.0 : 180.0;

    return Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: logoHeight,
          width: logoWidth,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const _FallbackLogo();
            },
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            'Smart card capture',
            style: textTheme.titleLarge?.copyWith(
              fontSize: compact ? 16 : 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Scan, review, and manage contacts with the AC identity.',
            style: textTheme.bodyMedium,
            textAlign: compact ? TextAlign.left : TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.surfaceRaised.withValues(alpha: 0.92),
                AppTheme.surface.withValues(alpha: 0.92),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          alignment: Alignment.center,
          child: const Text(
            'AG',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
            ),
          ),
        ),
      ),
    );
  }
}
