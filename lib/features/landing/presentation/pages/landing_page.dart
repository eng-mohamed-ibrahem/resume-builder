import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumate/core/theme/theme_cubit.dart';
import 'package:resumate/core/utils/responsive.dart';
import 'package:resumate/features/auth/screens/auth_screen.dart';
import 'package:resumate/features/landing/presentation/widgets/features_section.dart';
import 'package:resumate/features/landing/presentation/widgets/footer.dart';
import 'package:resumate/features/landing/presentation/widgets/hero_section.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_cubit.dart';
import 'package:resumate/features/resume/presentation/pages/resume_builder_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Main landing page for unauthenticated users
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey _featuresKey = GlobalKey();
  final bool _isLoading = false;

  void _scrollToFeatures() {
    final context = _featuresKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sticky navigation bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _NavigationBarDelegate(onFeaturesTap: _scrollToFeatures),
          ),
          // Main content
          SliverToBoxAdapter(
            child: Skeletonizer(
              enabled: _isLoading,
              child: Column(
                children: [
                  HeroSection(onScrollToFeatures: _scrollToFeatures),
                  FeaturesSection(key: _featuresKey),
                  const Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation bar delegate for sliver app bar
class _NavigationBarDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback? onFeaturesTap;

  _NavigationBarDelegate({this.onFeaturesTap});

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isScrolled = shrinkOffset > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: isScrolled
                ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        boxShadow: isScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: ResponsiveConstraints(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsivePadding.horizontal(context),
          vertical: 0,
        ),
        child: Row(
          children: [
            // Logo
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
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

            const Spacer(),

            // Desktop navigation links
            if (context.isDesktopOrLarger) ...[
              _NavLink(text: 'Features', onTap: () => onFeaturesTap?.call()),
              const SizedBox(width: 24),
            ],

            // Theme toggle button
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return IconButton(
                  icon: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                  ),
                  tooltip: themeMode == ThemeMode.dark
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                );
              },
            ),
            const SizedBox(width: 12),

            // Auth buttons
            if (context.isMobile)
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => _showMobileMenu(context),
              )
            else ...[
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                },
                child: const Text('Sign In'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () {
                  context.read<ResumeCubit>().createNewResume();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ResumeBuilderPage(),
                    ),
                  );
                },
                child: const Text('Get Started'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _MobileMenuSheet(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class _NavLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _NavLink({required this.text, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.text,
            style: TextStyle(
              color: _isHovered
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileMenuSheet extends StatelessWidget {
  const _MobileMenuSheet();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // Auth buttons
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<ResumeCubit>().createNewResume();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ResumeBuilderPage()),
                );
              },
              child: const Text('Get Started'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
              },
              child: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
