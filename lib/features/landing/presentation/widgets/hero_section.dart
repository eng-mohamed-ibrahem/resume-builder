import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../resume/presentation/cubit/resume_cubit.dart';
import '../../../resume/presentation/pages/resume_builder_page.dart';

/// Hero section for the landing page with animated background
class HeroSection extends StatefulWidget {
  final VoidCallback? onScrollToFeatures;

  const HeroSection({super.key, this.onScrollToFeatures});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _gradientController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(minHeight: context.isMobile ? 600 : 700),
      child: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _gradientController,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(
                        -1 + _gradientController.value * 0.5,
                        -1,
                      ),
                      end: Alignment(1 + _gradientController.value * 0.5, 1),
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.1),
                        colorScheme.surface,
                        colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating shapes
          ..._buildFloatingShapes(colorScheme),

          // Main content
          ResponsiveConstraints(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: context.isMobile ? 60 : 100,
              ),
              child: context.isMobile
                  ? _buildMobileLayout(textTheme, colorScheme)
                  : _buildDesktopLayout(textTheme, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingShapes(ColorScheme colorScheme) {
    return [
      // Top right blob
      AnimatedBuilder(
        animation: _floatController,
        builder: (context, _) {
          return Positioned(
            right: -50 + (_floatController.value * 20),
            top: 100 + (_floatController.value * 30),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.2),
                    colorScheme.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Bottom left blob
      AnimatedBuilder(
        animation: _floatController,
        builder: (context, _) {
          return Positioned(
            left: -100 + (_floatController.value * 15),
            bottom: 50 + ((1 - _floatController.value) * 25),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.tertiary.withValues(alpha: 0.15),
                    colorScheme.tertiary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildDesktopLayout(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 5, child: _buildHeroContent(textTheme, colorScheme)),
        const SizedBox(width: 60),
        Expanded(flex: 4, child: _buildHeroVisual(colorScheme)),
      ],
    );
  }

  Widget _buildMobileLayout(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHeroContent(textTheme, colorScheme, isMobile: true),
        const SizedBox(height: 48),
        SizedBox(height: 300, child: _buildHeroVisual(colorScheme)),
      ],
    );
  }

  Widget _buildHeroContent(
    TextTheme textTheme,
    ColorScheme colorScheme, {
    bool isMobile = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'ATS-Optimized Resume Builder',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Main headline
        Text(
          'Build Resumes That\nGet You Hired',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: (isMobile ? textTheme.displaySmall : textTheme.displayMedium)
              ?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -1,
              ),
        ),

        const SizedBox(height: 20),

        // Subheadline
        Text(
          'Create professional, ATS-friendly resumes in minutes.\nDrag-and-drop editor with real-time preview and instant PDF export.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 36),

        // CTA buttons
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 16,
          runSpacing: 12,
          children: [
            GradientButton(
              text: 'Start Building — Free',
              icon: Icons.rocket_launch_rounded,
              onPressed: () {
                // Initialize new resume and navigate to builder
                context.read<ResumeCubit>().createNewResume();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ResumeBuilderPage()),
                );
              },
            ),
            GradientButton(
              text: 'See How It Works',
              icon: Icons.play_circle_outline_rounded,
              isOutlined: true,
              onPressed: () {
                widget.onScrollToFeatures?.call();
              },
            ),
          ],
        ),

        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildHeroVisual(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatController.value * 15),
          child: child,
        );
      },
      child: AspectRatio(
        aspectRatio: 0.8,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 60,
                offset: const Offset(0, 30),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Mock browser bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        ...List.generate(
                          3,
                          (i) => Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: [
                                Colors.red.shade400,
                                Colors.amber.shade400,
                                Colors.green.shade400,
                              ][i],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'resumate.app',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Mock resume preview
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: _buildMockResume(colorScheme),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMockResume(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Center(
          child: Column(
            children: [
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 80,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: colorScheme.outlineVariant),
        const SizedBox(height: 12),
        // Section
        _buildMockSection(colorScheme, 'EXPERIENCE'),
        const SizedBox(height: 12),
        _buildMockSection(colorScheme, 'EDUCATION'),
        const Spacer(),
        // Skills
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(
            4,
            (_) => Container(
              width: 50,
              height: 18,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMockSection(ColorScheme colorScheme, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 8,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          2,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
