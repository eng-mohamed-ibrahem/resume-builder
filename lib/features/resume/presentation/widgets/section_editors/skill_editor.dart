import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/resume_models.dart';
import '../../cubit/resume_cubit.dart';

class SkillEditor extends StatefulWidget {
  final SectionModel section;

  const SkillEditor({super.key, required this.section});

  @override
  State<SkillEditor> createState() => _SkillEditorState();
}

class _SkillEditorState extends State<SkillEditor> {
  final TextEditingController _skillController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _skillController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final skills = widget.section.skillData ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                colorScheme.primaryContainer.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.tertiary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: colorScheme.tertiary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Add your technical and soft skills. Press Enter or tap the button to add.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Input Field
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillController,
                  focusNode: _focusNode,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a skill (e.g., Flutter, Leadership)',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.bolt_rounded,
                      color: colorScheme.tertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      _addSkill(context, val.trim());
                      _skillController.clear();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton.icon(
                  onPressed: () {
                    final val = _skillController.text.trim();
                    if (val.isNotEmpty) {
                      _addSkill(context, val);
                      _skillController.clear();
                      _focusNode.requestFocus();
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Skills Display
        if (skills.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.category_rounded,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No skills added yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start adding your skills above',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 16,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Skills (${skills.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (skills.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _clearAll(context),
                      icon: Icon(Icons.delete_sweep_rounded, size: 16),
                      label: Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final skill = entry.value;
                  return _SkillChip(
                    skill: skill,
                    onDelete: () => _removeSkill(context, idx),
                  );
                }).toList(),
              ),
            ],
          ),

        const SizedBox(height: 16),

        // Quick Add Suggestions
        if (skills.length < 3)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Quick Add',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _getSuggestions().map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    avatar: Icon(Icons.add, size: 14),
                    onPressed: () {
                      _addSkill(context, suggestion);
                    },
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
      ],
    );
  }

  List<String> _getSuggestions() {
    return [
      'JavaScript',
      'Python',
      'React',
      'Node.js',
      'Flutter',
      'Leadership',
      'Communication',
      'Problem Solving',
    ];
  }

  void _addSkill(BuildContext context, String name) {
    final current = List<SkillModel>.from(widget.section.skillData ?? []);
    // Check for duplicates
    if (current.any((s) => s.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Skill "$name" already added'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    current.add(SkillModel(id: const Uuid().v4(), name: name));
    context.read<ResumeCubit>().updateSkills(widget.section.id, current);
  }

  void _removeSkill(BuildContext context, int index) {
    final current = List<SkillModel>.from(widget.section.skillData ?? []);
    current.removeAt(index);
    context.read<ResumeCubit>().updateSkills(widget.section.id, current);
  }

  void _clearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: colorScheme.error),
              const SizedBox(width: 12),
              Text('Clear All Skills?'),
            ],
          ),
          content: Text(
            'This will remove all your skills. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<ResumeCubit>().updateSkills(widget.section.id, []);
                Navigator.pop(dialogContext);
              },
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              child: Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}

class _SkillChip extends StatefulWidget {
  final SkillModel skill;
  final VoidCallback onDelete;

  const _SkillChip({required this.skill, required this.onDelete});

  @override
  State<_SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<_SkillChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isHovered
                ? [
                    colorScheme.tertiaryContainer,
                    colorScheme.secondaryContainer,
                  ]
                : [
                    colorScheme.tertiaryContainer.withValues(alpha: 0.7),
                    colorScheme.secondaryContainer.withValues(alpha: 0.7),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? colorScheme.tertiary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: colorScheme.tertiary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onDelete,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.skill.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: _isHovered
                        ? colorScheme.error
                        : colorScheme.onTertiaryContainer.withValues(
                            alpha: 0.6,
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
}
