import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/resume_models.dart';
import '../../cubit/resume_cubit.dart';

class ExperienceEditor extends StatelessWidget {
  final SectionModel section;

  const ExperienceEditor({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final experiences = section.experienceData ?? [];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (experiences.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No work experience added yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add your first position to get started',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          )
        else
          ...experiences.asMap().entries.map((entry) {
            final idx = entry.key;
            final exp = entry.value;
            return _ExperienceCard(
              experience: exp,
              index: idx,
              onUpdate: (updated) => _updateExp(context, idx, updated),
              onRemove: () => _removeExp(context, idx),
            );
          }),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _addExp(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Work Experience'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updateExp(BuildContext context, int index, ExperienceModel updated) {
    final current = List<ExperienceModel>.from(section.experienceData ?? []);
    current[index] = updated;
    context.read<ResumeCubit>().updateExperiences(section.id, current);
  }

  void _addExp(BuildContext context) {
    final current = List<ExperienceModel>.from(section.experienceData ?? []);
    current.add(ExperienceModel(id: const Uuid().v4()));
    context.read<ResumeCubit>().updateExperiences(section.id, current);
  }

  void _removeExp(BuildContext context, int index) {
    final current = List<ExperienceModel>.from(section.experienceData ?? []);
    current.removeAt(index);
    context.read<ResumeCubit>().updateExperiences(section.id, current);
  }
}

class _ExperienceCard extends StatelessWidget {
  final ExperienceModel experience;
  final int index;
  final Function(ExperienceModel) onUpdate;
  final VoidCallback onRemove;

  const _ExperienceCard({
    required this.experience,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.tertiary],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.business_center_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Position ${index + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colorScheme.error,
                  ),
                  tooltip: 'Remove',
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _ModernField(
                  label: 'Company Name',
                  icon: Icons.apartment_rounded,
                  value: experience.company,
                  onChanged: (val) =>
                      onUpdate(experience.copyWith(company: val)),
                  hint: 'Google, Microsoft, etc.',
                ),
                const SizedBox(height: 8),
                _ModernField(
                  label: 'Job Title / Role',
                  icon: Icons.work_outline_rounded,
                  value: experience.role,
                  onChanged: (val) => onUpdate(experience.copyWith(role: val)),
                  hint: 'Senior Software Engineer',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ModernField(
                        label: 'Start Date',
                        icon: Icons.calendar_today_rounded,
                        value: experience.startDate,
                        onChanged: (val) =>
                            onUpdate(experience.copyWith(startDate: val)),
                        hint: 'Jan 2020',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ModernField(
                        label: 'End Date',
                        icon: Icons.event_rounded,
                        value: experience.endDate,
                        onChanged: (val) =>
                            onUpdate(experience.copyWith(endDate: val)),
                        hint: 'Present',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description Points
                _DescriptionPointsSection(
                  points: experience.descriptionPoints,
                  onUpdate: (points) =>
                      onUpdate(experience.copyWith(descriptionPoints: points)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionPointsSection extends StatelessWidget {
  final List<String> points;
  final Function(List<String>) onUpdate;

  const _DescriptionPointsSection({
    required this.points,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_list_bulleted_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Key Responsibilities & Achievements',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...points.asMap().entries.map((entry) {
            final idx = entry.key;
            final point = entry.value;
            return _BulletPoint(
              text: point,
              index: idx,
              onChanged: (val) {
                final updated = List<String>.from(points);
                updated[idx] = val;
                onUpdate(updated);
              },
              onRemove: () {
                final updated = List<String>.from(points);
                updated.removeAt(idx);
                onUpdate(updated);
              },
            );
          }),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              final updated = List<String>.from(points);
              updated.add('');
              onUpdate(updated);
            },
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: const Text('Add Achievement'),
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatefulWidget {
  final String text;
  final int index;
  final Function(String) onChanged;
  final VoidCallback onRemove;

  const _BulletPoint({
    required this.text,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_BulletPoint> createState() => _BulletPointState();
}

class _BulletPointState extends State<_BulletPoint> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(_BulletPoint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 14),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              maxLines: null,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'e.g., Led a team of 5 engineers to deliver...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onRemove,
            icon: Icon(Icons.close_rounded, size: 18, color: colorScheme.error),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ModernField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String value;
  final Function(String) onChanged;
  final String? hint;

  const _ModernField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  @override
  State<_ModernField> createState() => _ModernFieldState();
}

class _ModernFieldState extends State<_ModernField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_ModernField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
