import 'package:flutter/material.dart';
import 'package:resumate/core/utils/responsive.dart';

/// Features section showcasing the main product features
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: ResponsiveConstraints(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsivePadding.horizontal(context),
          vertical: context.isMobile ? 60 : 100,
        ),
        child: Column(
          children: [
            // Section header
            _buildSectionHeader(textTheme, colorScheme),
            SizedBox(height: context.isMobile ? 40 : 60),
            // Features grid
            _buildFeaturesGrid(context, colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'FEATURES',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Everything You Need to Land Your Dream Job',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'Our intelligent resume builder combines beautiful design with ATS optimization to give you the best chance of getting noticed.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final features = [
      _FeatureItem(
        icon: Icons.cloud_upload_outlined,
        title: 'Save to Cloud',
        description:
            'Store your resumes securely in the cloud. Never lose your work and access it from any device, anywhere, anytime.',
        gradient: [colorScheme.primary, colorScheme.secondary],
      ),
      _FeatureItem(
        icon: Icons.folder_copy_outlined,
        title: 'Multiple Resumes',
        description:
            'Create and manage unlimited resumes for different job applications. Tailor each one to specific roles effortlessly.',
        gradient: [colorScheme.secondary, colorScheme.tertiary],
      ),
      _FeatureItem(
        icon: Icons.download_outlined,
        title: 'Download Anytime',
        description:
            'Export your resume as a professional PDF whenever you need it. One click and you\'re ready to apply.',
        gradient: [colorScheme.tertiary, colorScheme.primary],
      ),
      _FeatureItem(
        icon: Icons.smart_toy_outlined,
        title: 'ATS-Optimized',
        description:
            'Beat applicant tracking systems with machine-readable formats that ensure your resume gets seen by recruiters.',
        gradient: [colorScheme.primary, colorScheme.tertiary],
      ),
      _FeatureItem(
        icon: Icons.visibility_outlined,
        title: 'Real-Time Preview',
        description:
            'See your changes instantly as you type. What you see is exactly what you get in the final PDF.',
        gradient: [colorScheme.secondary, colorScheme.primary],
      ),
      _FeatureItem(
        icon: Icons.content_copy_outlined,
        title: 'Duplicate & Customize',
        description:
            'Clone existing resumes and customize them for different positions. Save time while staying targeted.',
        gradient: [colorScheme.tertiary, colorScheme.secondary],
      ),
    ];

    // For mobile, we use a Column which naturally expands height to fit content
    if (context.isMobile) {
      return Column(
        children: features
            .map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _FeatureCard(feature: feature),
              ),
            )
            .toList(),
      );
    }

    final crossAxisCount = ResponsiveGrid.crossAxisCount(
      context,
      mobile: 1,
      tablet: 2,
      largeTablet: 3,
      desktop: 3,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        // Adjusted aspect ratios to prevent overflow on Tablet/Desktop
        // Smaller ratio = Taller card
        childAspectRatio: ResponsiveGrid.childAspectRatio(
          context,
          tablet: 1.5,
          largeTablet: 1.2,
          desktop: 1.0,
        ),
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _FeatureCard(feature: features[index]);
      },
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureItem feature;

  const _FeatureCard({required this.feature});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? widget.feature.gradient.first.withValues(alpha: 0.3)
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.feature.gradient.first.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _isHovered ? 30 : 20,
              offset: Offset(0, _isHovered ? 10 : 5),
            ),
          ],
        ),
        transform: _isHovered
            ? Matrix4.translationValues(0.0, -4.0, 0.0)
            : Matrix4.identity(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isHovered
                      ? widget.feature.gradient
                      : [
                          widget.feature.gradient.first.withValues(alpha: 0.1),
                          widget.feature.gradient.last.withValues(alpha: 0.1),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.feature.icon,
                size: 24,
                color: _isHovered
                    ? Colors.white
                    : widget.feature.gradient.first,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              widget.feature.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            Flexible(
              child: Text(
                widget.feature.description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
