import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumate/features/resume/data/models/resume_models.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_cubit.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/education_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/experience_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/header_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/list_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/project_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/skill_editor.dart';
import 'package:resumate/features/resume/presentation/widgets/section_editors/summary_editor.dart';

/// Modern long-press-to-reorder section card.
/// Replace the old inline `_ModernSectionCard` with this widget.
class ModernSectionCard extends StatefulWidget {
  final SectionModel section;
  final int index;

  const ModernSectionCard({
    required Key key,
    required this.section,
    required this.index,
  }) : super(key: key);

  @override
  State<ModernSectionCard> createState() => _ModernSectionCardState();
}

class _ModernSectionCardState extends State<ModernSectionCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  late final AnimationController _dragAnim;
  late final Animation<double> _elevation;
  late final Animation<double> _tilt;

  @override
  void initState() {
    super.initState();
    _dragAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _elevation = Tween<double>(
      begin: 0,
      end: 12,
    ).animate(CurvedAnimation(parent: _dragAnim, curve: Curves.easeOutCubic));
    _tilt = Tween<double>(
      begin: 0,
      end: 0.035,
    ).animate(CurvedAnimation(parent: _dragAnim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _dragAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ReorderableDelayedDragStartListener(
      index: widget.index,
      child: AnimatedBuilder(
        animation: _dragAnim,
        builder: (_, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateZ(_tilt.value),
            alignment: Alignment.center,
            child: Material(
              elevation: _elevation.value,
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
              child: child,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              onExpansionChanged: (expanded) =>
                  setState(() => _isExpanded = expanded),
              leading: _sectionLeadingIcon(colorScheme),
              title: Text(
                widget.section.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              trailing: _trailingRow(colorScheme, theme),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildSectionEditor(context, widget.section),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLeadingIcon(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        _sectionIconData(widget.section.type),
        color: colorScheme.primary,
        size: 16,
      ),
    );
  }

  Widget _trailingRow(ColorScheme colorScheme, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isExpanded
              ? const Icon(Icons.drag_handle_rounded, key: ValueKey('drag'))
              : const SizedBox(width: 24, key: ValueKey('empty')),
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
    );
  }

  IconData _sectionIconData(SectionType type) {
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          'Are you sure you want to delete the "${widget.section.title}" section? '
          'This action cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
