import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/resume_models.dart';
import '../../cubit/resume_cubit.dart';

class SummaryEditor extends StatefulWidget {
  final SectionModel section;

  const SummaryEditor({super.key, required this.section});

  @override
  State<SummaryEditor> createState() => _SummaryEditorState();
}

class _SummaryEditorState extends State<SummaryEditor> {
  late TextEditingController _controller;
  bool _isFocused = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    final text = widget.section.summaryData ?? '';
    _controller = TextEditingController(text: text);
    _charCount = text.length;
    _controller.selection = TextSelection.collapsed(offset: text.length);
  }

  @override
  void didUpdateWidget(SummaryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.section.summaryData ?? '';
    // Only update if value changed externally and doesn't match current input
    if (widget.section.summaryData != oldWidget.section.summaryData &&
        _controller.text != newText) {
      final currentSelection = _controller.selection;
      _controller.text = newText;
      _charCount = newText.length;

      // Preserve cursor position if it's still valid
      if (currentSelection.baseOffset <= newText.length) {
        _controller.selection = currentSelection;
      } else {
        _controller.selection = TextSelection.collapsed(offset: newText.length);
      }
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
    final recommendedMax = 500;
    final progress = (_charCount / recommendedMax).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tips Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.3),
                colorScheme.secondaryContainer.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tips_and_updates_rounded,
                  color: colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Write a compelling 2-3 sentence summary highlighting your expertise and career goals',
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

        // Text Field
        Focus(
          onFocusChange: (focused) {
            setState(() => _isFocused = focused);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isFocused
                  ? colorScheme.primaryContainer.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isFocused
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.2),
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 6,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
              onChanged: (val) {
                setState(() => _charCount = val.length);
                context.read<ResumeCubit>().updateSummary(
                  widget.section.id,
                  val,
                );
              },
              decoration: InputDecoration(
                hintText:
                    'Example: Experienced software engineer with 5+ years building scalable web applications. Specialized in React and Node.js with a passion for creating user-centric solutions...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  height: 1.6,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Character Count and Progress
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress < 0.3
                            ? colorScheme.error
                            : progress < 0.6
                            ? Colors.orange
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        _charCount < 100
                            ? Icons.warning_amber_rounded
                            : _charCount > recommendedMax
                            ? Icons.info_outline_rounded
                            : Icons.check_circle_rounded,
                        size: 14,
                        color: progress < 0.3
                            ? colorScheme.error
                            : progress < 0.6
                            ? Colors.orange
                            : colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_charCount characters',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '• Recommended: 200-500',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quick Tips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickTip(
              icon: Icons.star_rounded,
              text: 'Highlight key achievements',
              color: colorScheme.tertiary,
            ),
            _QuickTip(
              icon: Icons.bolt_rounded,
              text: 'Be specific and quantifiable',
              color: colorScheme.secondary,
            ),
            _QuickTip(
              icon: Icons.auto_awesome_rounded,
              text: 'Show your value proposition',
              color: colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickTip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _QuickTip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
