import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/resume_models.dart';
import '../../cubit/resume_cubit.dart';

class ProjectEditor extends StatelessWidget {
  final SectionModel section;

  const ProjectEditor({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final projects = section.projectData ?? [];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (projects.isEmpty)
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
                  Icons.code_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No projects added yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Showcase your best work',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projects.length,
            onReorder: (oldIndex, newIndex) =>
                _onReorder(context, oldIndex, newIndex),
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  final double animValue = Curves.easeInOut.transform(
                    animation.value,
                  );
                  final double elevation = lerpDouble(0, 6, animValue)!;
                  return Material(
                    elevation: elevation,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: child,
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final proj = projects[index];
              return _ProjectCard(
                key: ValueKey(proj.id),
                project: proj,
                index: index,
                onUpdate: (updated) => _updateProj(context, index, updated),
                onRemove: () => _removeProj(context, index),
              );
            },
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _addProj(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Project'),
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

  void _onReorder(BuildContext context, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final current = List<ProjectModel>.from(section.projectData ?? []);
    final item = current.removeAt(oldIndex);
    current.insert(newIndex, item);
    context.read<ResumeCubit>().updateProjects(section.id, current);
  }

  void _updateProj(BuildContext context, int index, ProjectModel updated) {
    final current = List<ProjectModel>.from(section.projectData ?? []);
    current[index] = updated;
    context.read<ResumeCubit>().updateProjects(section.id, current);
  }

  void _addProj(BuildContext context) {
    final current = List<ProjectModel>.from(section.projectData ?? []);
    current.add(ProjectModel(id: const Uuid().v4()));
    context.read<ResumeCubit>().updateProjects(section.id, current);
  }

  void _removeProj(BuildContext context, int index) {
    final current = List<ProjectModel>.from(section.projectData ?? []);
    current.removeAt(index);
    context.read<ResumeCubit>().updateProjects(section.id, current);
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final int index;
  final Function(ProjectModel) onUpdate;
  final VoidCallback onRemove;

  const _ProjectCard({
    required Key key,
    required this.project,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Drag Handle
                ReorderableDragStartListener(
                  index: index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    project.name.isNotEmpty
                        ? project.name
                        : 'New Project ${index + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
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
                  label: 'Project Name',
                  icon: Icons.title_rounded,
                  value: project.name,
                  onChanged: (val) => onUpdate(project.copyWith(name: val)),
                  hint: 'E-commerce Mobile App',
                ),
                const SizedBox(height: 12),
                _ModernField(
                  label: 'Short Description',
                  icon: Icons.description_rounded,
                  value: project.description,
                  onChanged: (val) =>
                      onUpdate(project.copyWith(description: val)),
                  hint: 'A full-stack mobile shopping application...',
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                // Description Points
                _DetailPointsSection(
                  points: project.descriptionPoints,
                  onUpdate: (points) =>
                      onUpdate(project.copyWith(descriptionPoints: points)),
                ),

                const SizedBox(height: 20),

                // Links Section
                _LinksSection(
                  links: project.links,
                  onUpdate: (links) => onUpdate(project.copyWith(links: links)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPointsSection extends StatelessWidget {
  final List<String> points;
  final Function(List<String>) onUpdate;

  const _DetailPointsSection({required this.points, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.star_rounded, size: 18, color: colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Key Features & Achievements',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
            label: const Text('Add Feature'),
            style: TextButton.styleFrom(foregroundColor: colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}

class _LinksSection extends StatelessWidget {
  final List<ProjectLink> links;
  final Function(List<ProjectLink>) onUpdate;

  const _LinksSection({required this.links, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Project Links',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...links.asMap().entries.map((entry) {
            final idx = entry.key;
            final link = entry.value;
            return _LinkRow(
              link: link,
              onUpdate: (label, url) {
                final updated = List<ProjectLink>.from(links);
                updated[idx] = ProjectLink(label: label, url: url);
                onUpdate(updated);
              },
              onRemove: () {
                final updated = List<ProjectLink>.from(links);
                updated.removeAt(idx);
                onUpdate(updated);
              },
            );
          }),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              final updated = List<ProjectLink>.from(links);
              updated.add(ProjectLink(label: '', url: ''));
              onUpdate(updated);
            },
            icon: const Icon(Icons.add_link_rounded, size: 18),
            label: const Text('Add Link'),
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatefulWidget {
  final ProjectLink link;
  final Function(String, String) onUpdate;
  final VoidCallback onRemove;

  const _LinkRow({
    required this.link,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<_LinkRow> {
  late TextEditingController _labelController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.link.label);
    _urlController = TextEditingController(text: widget.link.url);
  }

  @override
  void didUpdateWidget(_LinkRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_labelController.text != widget.link.label) {
      _labelController.text = widget.link.label;
    }
    if (_urlController.text != widget.link.url) {
      _urlController.text = widget.link.url;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _labelController,
              onChanged: (val) => widget.onUpdate(val, _urlController.text),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Label',
                hintText: 'GitHub, Demo, etc.',
                prefixIcon: Icon(Icons.label_rounded, size: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _urlController,
              onChanged: (val) => widget.onUpdate(_labelController.text, val),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'URL',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.public_rounded, size: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
              color: colorScheme.secondary,
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
                hintText: 'e.g., Implemented real-time notifications...',
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
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
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
