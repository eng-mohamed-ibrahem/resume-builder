import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/resume_models.dart';
import '../../cubit/resume_cubit.dart';

class EducationEditor extends StatelessWidget {
  final SectionModel section;

  const EducationEditor({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final education = section.educationData ?? [];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (education.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No education added yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add your academic background',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          )
        else
          ...education.asMap().entries.map((entry) {
            final idx = entry.key;
            final edu = entry.value;
            return _EducationCard(
              education: edu,
              index: idx,
              onUpdate: (updated) => _updateEdu(context, idx, updated),
              onRemove: () => _removeEdu(context, idx),
            );
          }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _addEdu(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Education'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
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

  void _updateEdu(BuildContext context, int index, EducationModel updated) {
    final current = List<EducationModel>.from(section.educationData ?? []);
    current[index] = updated;
    context.read<ResumeCubit>().updateEducation(section.id, current);
  }

  void _addEdu(BuildContext context) {
    final current = List<EducationModel>.from(section.educationData ?? []);
    current.add(EducationModel(id: const Uuid().v4()));
    context.read<ResumeCubit>().updateEducation(section.id, current);
  }

  void _removeEdu(BuildContext context, int index) {
    final current = List<EducationModel>.from(section.educationData ?? []);
    current.removeAt(index);
    context.read<ResumeCubit>().updateEducation(section.id, current);
  }
}

class _EducationCard extends StatelessWidget {
  final EducationModel education;
  final int index;
  final Function(EducationModel) onUpdate;
  final VoidCallback onRemove;

  const _EducationCard({
    required this.education,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.tertiaryContainer.withValues(alpha: 0.1),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withValues(alpha: 0.2),
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
                      colors: [
                        colorScheme.tertiary,
                        colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Education ${index + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.tertiary,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ModernField(
                  label: 'Institution / University',
                  icon: Icons.domain_rounded,
                  value: education.institution,
                  onChanged: (val) =>
                      onUpdate(education.copyWith(institution: val)),
                  hint: 'Stanford University',
                ),
                const SizedBox(height: 12),
                _ModernField(
                  label: 'Degree',
                  icon: Icons.workspace_premium_rounded,
                  value: education.degree,
                  onChanged: (val) => onUpdate(education.copyWith(degree: val)),
                  hint: 'Bachelor of Science in Computer Science',
                ),
                const SizedBox(height: 12),
                _ModernField(
                  label: 'Description / Specialization',
                  icon: Icons.description_rounded,
                  value: education.description,
                  onChanged: (val) =>
                      onUpdate(education.copyWith(description: val)),
                  hint: 'Major in AI, Minor in Mathematics',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ModernField(
                        label: 'Start Date',
                        icon: Icons.calendar_today_rounded,
                        value: education.startDate,
                        onChanged: (val) =>
                            onUpdate(education.copyWith(startDate: val)),
                        hint: 'Sep 2016',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ModernField(
                        label: 'End Date',
                        icon: Icons.event_rounded,
                        value: education.endDate,
                        onChanged: (val) =>
                            onUpdate(education.copyWith(endDate: val)),
                        hint: 'Jun 2020',
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
  final int? maxLines;

  const _ModernField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.hint,
    this.maxLines = 1,
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
      maxLines: widget.maxLines,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
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
          borderSide: BorderSide(color: colorScheme.tertiary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}