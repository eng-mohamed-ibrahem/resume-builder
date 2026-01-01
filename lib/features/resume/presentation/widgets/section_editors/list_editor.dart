import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/resume_models.dart';
import '../../cubit/resume_cubit.dart';

class ListEditor extends StatefulWidget {
  final SectionModel section;

  const ListEditor({super.key, required this.section});

  @override
  State<ListEditor> createState() => _ListEditorState();
}

class _ListEditorState extends State<ListEditor> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  IconData _getSectionIcon() {
    if (widget.section.type == SectionType.certifications) {
      return Icons.verified_rounded;
    } else if (widget.section.type == SectionType.languages) {
      return Icons.language_rounded;
    }
    return Icons.list_rounded;
  }

  Color _getSectionColor(ColorScheme colorScheme) {
    if (widget.section.type == SectionType.certifications) {
      return colorScheme.secondary;
    } else if (widget.section.type == SectionType.languages) {
      return colorScheme.tertiary;
    }
    return colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final list = widget.section.listData ?? [];
    final sectionColor = _getSectionColor(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                sectionColor.withValues(alpha: 0.15),
                sectionColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sectionColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: sectionColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getSectionIcon(), color: sectionColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getHelpText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

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
                  controller: _inputController,
                  focusNode: _focusNode,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: _getPlaceholder(),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    prefixIcon: Icon(_getSectionIcon(), color: sectionColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      _add(context, val.trim());
                      _inputController.clear();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton.icon(
                  onPressed: () {
                    final val = _inputController.text.trim();
                    if (val.isNotEmpty) {
                      _add(context, val);
                      _inputController.clear();
                      _focusNode.requestFocus();
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    backgroundColor: sectionColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // List Display
        if (list.isEmpty)
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
                  _getSectionIcon(),
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No ${widget.section.title.toLowerCase()} added yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start adding items above',
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
                  Icon(Icons.list_alt_rounded, size: 16, color: sectionColor),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.section.title} (${list.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (list.isNotEmpty)
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
              ...list.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return _ListItemCard(
                  item: item,
                  index: idx,
                  sectionColor: sectionColor,
                  onUpdate: (val) => _update(context, idx, val),
                  onRemove: () => _remove(context, idx),
                );
              }),
            ],
          ),

        const SizedBox(height: 16),

        // Quick suggestions (for languages)
        if (widget.section.type == SectionType.languages && list.length < 3)
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
                children: ['English', 'Spanish', 'French', 'Mandarin', 'Arabic']
                    .map((lang) {
                      return ActionChip(
                        label: Text(lang),
                        avatar: Icon(Icons.add, size: 14),
                        onPressed: () => _add(context, lang),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        side: BorderSide(
                          color: sectionColor.withValues(alpha: 0.3),
                        ),
                        labelStyle: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    })
                    .toList(),
              ),
            ],
          ),
      ],
    );
  }

  String _getHelpText() {
    if (widget.section.type == SectionType.certifications) {
      return 'Add your professional certifications and credentials';
    } else if (widget.section.type == SectionType.languages) {
      return 'List the languages you speak and your proficiency level';
    }
    return 'Add items to this section';
  }

  String _getPlaceholder() {
    if (widget.section.type == SectionType.certifications) {
      return 'e.g., AWS Certified Solutions Architect';
    } else if (widget.section.type == SectionType.languages) {
      return 'e.g., English (Native), Spanish (Professional)';
    }
    return 'Enter ${widget.section.title.toLowerCase()}...';
  }

  void _update(BuildContext context, int index, String value) {
    final current = List<String>.from(widget.section.listData ?? []);
    current[index] = value;
    context.read<ResumeCubit>().updateListData(widget.section.id, current);
  }

  void _add(BuildContext context, String value) {
    final current = List<String>.from(widget.section.listData ?? []);
    // Check for duplicates
    if (current.any((item) => item.toLowerCase() == value.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$value" already added'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    current.add(value);
    context.read<ResumeCubit>().updateListData(widget.section.id, current);
  }

  void _remove(BuildContext context, int index) {
    final current = List<String>.from(widget.section.listData ?? []);
    current.removeAt(index);
    context.read<ResumeCubit>().updateListData(widget.section.id, current);
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
              Text('Clear All Items?'),
            ],
          ),
          content: Text(
            'This will remove all items from ${widget.section.title}. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<ResumeCubit>().updateListData(
                  widget.section.id,
                  [],
                );
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

class _ListItemCard extends StatefulWidget {
  final String item;
  final int index;
  final Color sectionColor;
  final Function(String) onUpdate;
  final VoidCallback onRemove;

  const _ListItemCard({
    required this.item,
    required this.index,
    required this.sectionColor,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_ListItemCard> createState() => _ListItemCardState();
}

class _ListItemCardState extends State<_ListItemCard> {
  late TextEditingController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item);
  }

  @override
  void didUpdateWidget(_ListItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.item) {
      _controller.text = widget.item;
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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.sectionColor.withValues(alpha: 0.05)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? widget.sectionColor.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.2),
            width: _isHovered ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.sectionColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${widget.index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.sectionColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onUpdate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter item...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onRemove,
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: _isHovered
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                tooltip: 'Remove',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
