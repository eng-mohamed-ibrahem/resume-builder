import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumate/features/resume/data/models/resume_models.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_cubit.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_state.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/education_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/experience_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/header_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/list_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/project_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/skill_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/summary_editor.dart';

class ResumeEditor extends StatelessWidget {
  const ResumeEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ResumeCubit, ResumeState>(
      builder: (context, state) {
        if (state is ResumeUpdated) {
          final sections = state.resume.sections;
          return Container(
            color: colorScheme.surfaceContainerLowest,
            child: Column(
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer.withValues(alpha: 0.3),
                        colorScheme.surfaceContainerLowest,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit_document,
                          color: colorScheme.onPrimary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resume Editor',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Drag sections to reorder',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            context.read<ResumeCubit>().resetToInitial(),
                        icon: Icon(
                          Icons.home_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        label: Text(
                          'Home',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Resume Title Editor
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                  ),
                  child: TextFormField(
                    initialValue: state.resume.title,
                    decoration: InputDecoration(
                      labelText: 'Resume Title',
                      hintText: 'e.g., Software Engineer Resume',
                      prefixIcon: const Icon(Icons.title_rounded),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) =>
                        context.read<ResumeCubit>().updateTitle(value),
                  ),
                ),
                // Sections List
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      return _ModernSectionCard(
                        key: ValueKey(section.id),
                        section: section,
                        index: index,
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      context.read<ResumeCubit>().reorderSections(
                        oldIndex,
                        newIndex,
                      );
                    },
                  ),
                ),
                // Add Section Panel
                _ModernAddSectionPanel(),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _ModernSectionCard extends StatefulWidget {
  final SectionModel section;
  final int index;

  const _ModernSectionCard({
    required super.key,
    required this.section,
    required this.index,
  });

  @override
  State<_ModernSectionCard> createState() => _ModernSectionCardState();
}

class _ModernSectionCardState extends State<_ModernSectionCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getSectionIcon(widget.section.type),
              color: colorScheme.primary,
              size: 16,
            ),
          ),
          title: Text(
            widget.section.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              Icon(
                Icons.drag_indicator_rounded,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 20,
              ),
              const SizedBox(width: 8),
              if (_isExpanded)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showDeleteDialog(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error.withValues(alpha: 0.7),
                        size: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
              ),
              padding: const EdgeInsets.only(top: 16),
              child: _buildSectionEditor(context, widget.section),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSectionIcon(SectionType type) {
    switch (type) {
      case SectionType.header:
        return Icons.person_outline_rounded;
      case SectionType.summary:
        return Icons.short_text_rounded;
      case SectionType.workExperience:
        return Icons.business_center_outlined;
      case SectionType.projects:
        return Icons.code_rounded;
      case SectionType.education:
        return Icons.school_outlined;
      case SectionType.skills:
        return Icons.auto_awesome_outlined;
      case SectionType.certifications:
        return Icons.verified_outlined;
      case SectionType.languages:
        return Icons.language_rounded;
      case SectionType.custom:
        return Icons.dashboard_customize_outlined;
    }
  }

  Widget _buildSectionEditor(BuildContext context, SectionModel section) {
    switch (section.type) {
      case SectionType.header:
        return HeaderEditor(section: section);
      case SectionType.summary:
        return SummaryEditor(section: section);
      case SectionType.workExperience:
        return ExperienceEditor(section: section);
      case SectionType.projects:
        return ProjectEditor(section: section);
      case SectionType.education:
        return EducationEditor(section: section);
      case SectionType.skills:
        return SkillEditor(section: section);
      case SectionType.certifications:
      case SectionType.languages:
        return ListEditor(section: section);
      default:
        return const Text('Editor not implemented yet');
    }
  }

  void _showDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Section?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete the "${widget.section.title}" section? This action cannot be undone.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton.tonal(
              onPressed: () {
                context.read<ResumeCubit>().removeSection(widget.section.id);
                Navigator.of(dialogContext).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _ModernAddSectionPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Add Section',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SectionType.values
                  .where((t) => t != SectionType.header)
                  .map((type) => _SectionTypeChip(type: type))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTypeChip extends StatelessWidget {
  final SectionType type;

  const _SectionTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.read<ResumeCubit>().addSection(type),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTypeIcon(type),
                  size: 18,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTypeLabel(type),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(SectionType type) {
    switch (type) {
      case SectionType.summary:
        return Icons.article_rounded;
      case SectionType.workExperience:
        return Icons.work_rounded;
      case SectionType.projects:
        return Icons.code_rounded;
      case SectionType.education:
        return Icons.school_rounded;
      case SectionType.skills:
        return Icons.bolt_rounded;
      case SectionType.certifications:
        return Icons.verified_rounded;
      case SectionType.languages:
        return Icons.language_rounded;
      case SectionType.custom:
        return Icons.add_box_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getTypeLabel(SectionType type) {
    switch (type) {
      case SectionType.summary:
        return 'Summary';
      case SectionType.workExperience:
        return 'Experience';
      case SectionType.projects:
        return 'Projects';
      case SectionType.education:
        return 'Education';
      case SectionType.skills:
        return 'Skills';
      case SectionType.certifications:
        return 'Certifications';
      case SectionType.languages:
        return 'Languages';
      case SectionType.custom:
        return 'Custom';
      default:
        return '';
    }
  }
}
