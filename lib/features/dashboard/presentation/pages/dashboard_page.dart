import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumate/core/services/supabase_service.dart';
import 'package:resumate/core/utils/export_service.dart';
import 'package:resumate/core/utils/responsive.dart';
import 'package:resumate/features/dashboard/presentation/widgets/dashboard_sidebar.dart';
import 'package:resumate/features/dashboard/presentation/widgets/resume_card_enhanced.dart';
import 'package:resumate/features/landing/presentation/pages/landing_page.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_cubit.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_state.dart';
import 'package:resumate/features/resume/presentation/pages/resume_builder_page.dart';

/// Dashboard page for authenticated users to manage their resumes
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isSidebarExpanded = true;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ResumeCubit>().loadUserResumes();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      drawer: context.isMobile ? _buildDrawer() : null,
      body: Row(
        children: [
          // Sidebar (desktop/tablet only)
          if (!context.isMobile)
            DashboardSidebar(
              isExpanded: _isSidebarExpanded && context.isDesktop,
              selectedIndex: _selectedNavIndex,
              onNavItemTap: (index) =>
                  setState(() => _selectedNavIndex = index),
              onToggleExpanded: () =>
                  setState(() => _isSidebarExpanded = !_isSidebarExpanded),
              onSignOut: _handleSignOut,
            ),

          // Main content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewResume,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Resume'),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: DashboardSidebar(
        isExpanded: true,
        selectedIndex: _selectedNavIndex,
        onNavItemTap: (index) {
          setState(() => _selectedNavIndex = index);
          Navigator.pop(context);
        },
        onToggleExpanded: () {},
        onSignOut: _handleSignOut,
        isDrawer: true,
      ),
    );
  }

  Widget _buildTopBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 16 : 32,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          if (context.isMobile)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          if (!context.isMobile) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your resumes and track your job search.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (context.isMobile) const Spacer(),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final user = SupabaseService().currentUser;
    final name = user?.userMetadata?['full_name'] ?? 'there';

    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return '$greeting, $name 👋';
  }

  Widget _buildMainContent() {
    return BlocBuilder<ResumeCubit, ResumeState>(
      buildWhen: (previous, current) => current is! ResumeUpdated,
      builder: (context, state) {
        if (state is ResumeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ResumeError) {
          return _buildErrorState(state.message);
        }

        if (state is ResumeListLoaded) {
          if (state.resumes.isEmpty) {
            return _buildEmptyState();
          }
          return _buildResumeGrid(state.resumes);
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Resumes Yet',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first resume and start landing interviews!',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _createNewResume,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Your First Resume'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Something went wrong', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<ResumeCubit>().loadUserResumes(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeGrid(List<Map<String, dynamic>> resumes) {
    final crossAxisCount = ResponsiveGrid.crossAxisCount(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );

    return Padding(
      padding: EdgeInsets.all(context.isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Resumes',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              // View toggle (future)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.grid_view_rounded),
                    onPressed: () {},
                    tooltip: 'Grid view',
                  ),
                  IconButton(
                    icon: const Icon(Icons.list_rounded),
                    onPressed: () {},
                    tooltip: 'List view',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Resume grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: context.isMobile ? 1.5 : 0.85,
              ),
              itemCount: resumes.length,
              itemBuilder: (context, index) {
                final resume = resumes[index];
                return ResumeCardEnhanced(
                  title: resume['title'] ?? 'Untitled',
                  updatedAt: DateTime.parse(resume['updated_at']),
                  onTap: () {
                    context.read<ResumeCubit>().loadResume(resume['id']);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ResumeBuilderPage(),
                      ),
                    );
                  },
                  onDuplicate: () => _handleDuplicate(resume['id']),
                  onDelete: () => _handleDelete(resume['id']),
                  onExport: () => _handleExport(resume['id']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _createNewResume() {
    context.read<ResumeCubit>().createNewResume();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ResumeBuilderPage()));
  }

  Future<void> _handleSignOut() async {
    await SupabaseService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (route) => false,
      );
    }
  }

  void _handleDuplicate(String resumeId) {
    context.read<ResumeCubit>().duplicateResume(resumeId);
  }

  void _handleDelete(String resumeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume'),
        content: const Text(
          'Are you sure you want to delete this resume? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<ResumeCubit>().deleteResume(resumeId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(String resumeId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final resume = await SupabaseService().getFullResume(resumeId);
      if (mounted) {
        Navigator.pop(context); // Close loading
        await ExportService.exportToPdf(resume, false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export resume: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
