import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumate/features/resume/data/models/resume_models.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_cubit.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_state.dart';
import 'package:resumate/features/resume/presentation/widgets/modern_section_card.dart';

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
                      return ModernSectionCard(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Section',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap any section below to add it to your resume',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
