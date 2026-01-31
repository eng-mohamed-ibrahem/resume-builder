import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumate/core/services/supabase_service.dart';
import 'package:resumate/core/utils/export_service.dart';
import 'package:resumate/core/utils/responsive.dart';
import 'package:resumate/features/auth/screens/auth_screen.dart';
import 'package:resumate/features/resume/data/models/resume_models.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_cubit.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_state.dart';
import 'package:resumate/features/resume/presentation/widgets/resume_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/resume_preview.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ResumeBuilderPage extends StatelessWidget {
  const ResumeBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResumeCubit, ResumeState>(
      listener: (context, state) {
        if (state is ResumeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is ResumeUpdated) {
          return Scaffold(body: _buildMainContent(context, state));
        }
        if (state is ResumeLoading) {
          return Scaffold(
            body: Skeletonizer(
              enabled: true,
              child: _buildMainContent(
                context,
                ResumeUpdated(_dummyResume, isAtsView: false),
              ),
            ),
          );
        }
        // If state is not updated (e.g. went back to list), we should probably pop or show something else.
        // For now, let's assume we are here only when loaded.
        return const Scaffold(
          body: Center(child: Text("Initializing Editor...")),
        );
      },
    );
  }

  static final ResumeModel _dummyResume = ResumeModel(
    id: 'dummy',
    title: 'Resume Title Placeholder',
    sections: [
      SectionModel(
        id: 's1',
        title: 'Personal Info',
        type: SectionType.header,
        headerData: HeaderModel(),
      ),
      SectionModel(
        id: 's2',
        title: 'Professional Summary',
        type: SectionType.summary,
      ),
      SectionModel(
        id: 's3',
        title: 'Work Experience',
        type: SectionType.workExperience,
      ),
      SectionModel(id: 's4', title: 'Education', type: SectionType.education),
    ],
  );

  Widget _buildMainContent(BuildContext context, ResumeUpdated state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Modern App Bar
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Back Button & Logo
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      context.read<ResumeCubit>().loadUserResumes();
                      Navigator.of(
                        context,
                      ).maybePop(); // Go back to dashboard if pushed, or just load list
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.resume.title.isEmpty
                          ? 'Untitled Resume'
                          : state.resume.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),

                  if (context.isMobile) ...[
                    // Mobile Actions
                    if (state.isSaving)
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () => _handleDuplicate(context, state),
                        tooltip: 'Duplicate',
                      ),
                    IconButton(
                      icon: const Icon(Icons.cloud_upload_rounded),
                      onPressed: () => _handleSaveToCloud(context, state),
                      tooltip: 'Save',
                    ),
                    IconButton(
                      icon: const Icon(Icons.file_download_rounded),
                      onPressed: () =>
                          ExportService.exportToPdf(state.resume, false),
                      tooltip: 'Export PDF',
                    ),
                  ] else ...[
                    // Desktop Actions
                    _buildActionButton(
                      context,
                      icon: Icons.copy_rounded,
                      label: 'Duplicate',
                      onPressed: () => _handleDuplicate(context, state),
                      isPrimary: false,
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      context,
                      icon: Icons.cloud_upload_rounded,
                      label: 'Save',
                      onPressed: () => _handleSaveToCloud(context, state),
                      isPrimary: false,
                      isLoading: state.isSaving,
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      context,
                      icon: Icons.file_download_rounded,
                      label: 'Export PDF',
                      onPressed: () =>
                          ExportService.exportToPdf(state.resume, false),
                      isPrimary: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Content Area
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return _buildMobileLayout(context, state);
              }
              return _buildDesktopLayout(context, state);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isPrimary
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPrimary
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Icon(
                  icon,
                  size: 20,
                  color: isPrimary
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ResumeUpdated state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: colorScheme.onPrimaryContainer,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Edit', icon: Icon(Icons.edit_rounded)),
                Tab(text: 'Preview', icon: Icon(Icons.visibility_rounded)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                const ResumeEditor(),
                BlocBuilder<ResumeCubit, ResumeState>(
                  builder: (context, state) {
                    if (state is ResumeUpdated) {
                      return Container(
                        color: colorScheme.surfaceContainerLow,
                        child: ResumePreview(
                          resume: state.resume,
                          isAtsView: false,
                        ),
                      );
                    }
                    return Container(
                      color: colorScheme.surfaceContainerLow,
                      child: const Center(child: Text('No resume loaded')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ResumeUpdated state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const ResumeEditor(),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(top: 12, right: 12, bottom: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BlocBuilder<ResumeCubit, ResumeState>(
                builder: (context, state) {
                  if (state is ResumeUpdated) {
                    return ResumePreview(
                      resume: state.resume,
                      isAtsView: false,
                    );
                  }
                  return const Center(child: Text('No resume loaded'));
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSaveToCloud(
    BuildContext context,
    ResumeUpdated state,
  ) async {
    final user = SupabaseService().currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text(
            'You need to be signed in to save your resume to the cloud.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(
                      onLoginSuccess: () {
                        Navigator.of(context).pop();
                        _handleSaveToCloud(context, state);
                      },
                    ),
                  ),
                );
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await context.read<ResumeCubit>().saveToCloud(state.resume);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text('Resume saved to cloud successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error saving to cloud: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _handleDuplicate(
    BuildContext context,
    ResumeUpdated state,
  ) async {
    final user = SupabaseService().currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text(
            'You need to be signed in to duplicate your resume.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(
                      onLoginSuccess: () {
                        Navigator.of(context).pop();
                        _handleDuplicate(context, state);
                      },
                    ),
                  ),
                );
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      if (state.resume.id.startsWith('temp_')) {
        // If it's a temp resume, save it first (effectively duplicating it from temp to cloud)
        await context.read<ResumeCubit>().saveToCloud(state.resume);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Resume saved to cloud!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        await context.read<ResumeCubit>().duplicateResume(state.resume.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Resume duplicated successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error duplicating resume: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}
