import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumate/core/services/supabase_service.dart';
import 'package:resumate/features/auth/screens/auth_screen.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_cubit.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_state.dart';
import 'package:resumate/features/resume/presentation/pages/resume_builder_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load existing resumes on start
    context.read<ResumeCubit>().loadUserResumes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: BlocBuilder<ResumeCubit, ResumeState>(
        buildWhen: (previous, current) => current is! ResumeUpdated,
        builder: (context, state) {
          if (state is ResumeInitial) {
            return _buildWelcomeContent(context);
          }
          if (state is ResumeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ResumeError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          if (state is ResumeListLoaded) {
            return _buildDashboard(context, state.resumes);
          }

          // Fallback
          return _buildWelcomeContent(context);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(
        'ResuMate',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: false,
      actions: [_buildProfileMenu(context), const SizedBox(width: 16)],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = SupabaseService().currentUser;

    return PopupMenuButton(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_rounded, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              user?.email ?? 'Guest',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        if (user != null)
          PopupMenuItem(
            child: Row(
              children: [
                Icon(Icons.logout_rounded, size: 20, color: colorScheme.error),
                const SizedBox(width: 12),
                Text('Sign Out', style: TextStyle(color: colorScheme.error)),
              ],
            ),
            onTap: () async {
              await Future.delayed(Duration.zero);
              await SupabaseService().signOut();
              if (context.mounted) {
                context.read<ResumeCubit>().loadUserResumes();
              }
            },
          )
        else
          PopupMenuItem(
            child: Row(
              children: [
                Icon(Icons.login_rounded, size: 20, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text('Sign In', style: TextStyle(color: colorScheme.primary)),
              ],
            ),
            onTap: () async {
              await Future.delayed(Duration.zero);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    List<Map<String, dynamic>> resumes,
  ) {
    if (resumes.isEmpty) {
      return _buildEmptyDashboard(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : (constraints.maxWidth > 600 ? 3 : 2);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Resumes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<ResumeCubit>().createNewResume();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ResumeBuilderPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create New'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: resumes.length,
                  itemBuilder: (context, index) {
                    final resume = resumes[index];
                    return _buildResumeCard(context, resume);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumeCard(BuildContext context, Map<String, dynamic> resume) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final updatedAt = DateTime.parse(resume['updated_at']);

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.read<ResumeCubit>().loadResume(resume['id']);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ResumeBuilderPage()),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  // Placeholder for preview image
                ),
                child: Center(
                  child: Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resume['title'] ?? 'Untitled',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Edited ${timeago.format(updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeContent(BuildContext context) {
    // Re-using the onboarding style but simplified for dashboard context
    return _buildEmptyDashboard(context);
  }

  Widget _buildEmptyDashboard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = SupabaseService().currentUser;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dashboard_customize_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user != null ? 'Welcome Back!' : 'Start Building Your Career',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Create professional resumes in minutes. Use our ATS-friendly templates to get hired faster.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: () {
                context.read<ResumeCubit>().createNewResume();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ResumeBuilderPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Create New Resume'),
            ),

            if (user == null) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
                icon: const Icon(Icons.login_rounded),
                label: const Text('Sign In to Save Account'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
