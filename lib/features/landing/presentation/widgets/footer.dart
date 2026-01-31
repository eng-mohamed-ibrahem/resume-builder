import 'package:flutter/material.dart';
import 'package:resumate/core/utils/responsive.dart';

/// Footer component for the landing page
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: ResponsiveConstraints(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsivePadding.horizontal(context),
          vertical: 40,
        ),
        child: context.isMobile
            ? _buildMobileLayout(textTheme, colorScheme)
            : _buildDesktopLayout(textTheme, colorScheme),
      ),
    );
  }

  Widget _buildDesktopLayout(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Brand column
            Expanded(flex: 2, child: _buildBrandColumn(textTheme, colorScheme)),
          ],
        ),
        const SizedBox(height: 40),
        _buildBottomBar(textTheme, colorScheme),
      ],
    );
  }

  Widget _buildMobileLayout(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildBrandColumn(textTheme, colorScheme, isCentered: true),
        const SizedBox(height: 32),
        _buildBottomBar(textTheme, colorScheme, isCentered: true),
      ],
    );
  }

  Widget _buildBrandColumn(
    TextTheme textTheme,
    ColorScheme colorScheme, {
    bool isCentered = false,
  }) {
    return Column(
      crossAxisAlignment: isCentered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        // Logo
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'ResuMate',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            'Build professional resumes that get you hired. ATS-optimized, beautifully designed.',
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    TextTheme textTheme,
    ColorScheme colorScheme, {
    bool isCentered = false,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: isCentered
          ? Column(
              children: [
                Text(
                  '© 2026 ResuMate. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Made with ',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Icon(Icons.favorite, size: 14, color: colorScheme.error),
                    Text(
                      ' using Flutter',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2026 ResuMate. All rights reserved.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Made with ',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Icon(Icons.favorite, size: 14, color: colorScheme.error),
                    Text(
                      ' using Flutter',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
