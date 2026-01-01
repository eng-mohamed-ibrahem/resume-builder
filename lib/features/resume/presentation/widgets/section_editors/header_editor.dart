import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/resume_models.dart';
import '../../cubit/resume_cubit.dart';

class HeaderEditor extends StatelessWidget {
  final SectionModel section;

  const HeaderEditor({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final data = section.headerData ?? HeaderModel();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Info Section
        _SectionHeader(
          icon: Icons.person_rounded,
          title: 'Personal Information',
          color: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _ModernTextField(
          label: 'Full Name',
          icon: Icons.badge_rounded,
          value: data.fullName,
          onChanged: (val) => _update(context, data.copyWith(fullName: val)),
          hint: 'John Doe',
        ),
        const SizedBox(height: 8),
        _ModernTextField(
          label: 'Job Title',
          icon: Icons.work_outline_rounded,
          value: data.jobTitle,
          onChanged: (val) => _update(context, data.copyWith(jobTitle: val)),
          hint: 'Senior Software Engineer',
        ),
        const SizedBox(height: 8),
        _ModernTextField(
          label: 'Location',
          icon: Icons.location_on_rounded,
          value: data.location,
          onChanged: (val) => _update(context, data.copyWith(location: val)),
          hint: 'San Francisco, CA',
        ),

        const SizedBox(height: 16),

        // Contact Section
        _SectionHeader(
          icon: Icons.contact_mail_rounded,
          title: 'Contact Information',
          color: colorScheme.tertiary,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ModernTextField(
                label: 'Email',
                icon: Icons.email_rounded,
                value: data.email,
                onChanged: (val) => _update(context, data.copyWith(email: val)),
                hint: 'john@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernTextField(
                label: 'Phone',
                icon: Icons.phone_rounded,
                value: data.phoneNumber,
                onChanged: (val) =>
                    _update(context, data.copyWith(phoneNumber: val)),
                hint: '+1 (555) 123-4567',
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Links Section
        _SectionHeader(
          icon: Icons.link_rounded,
          title: 'Professional Links',
          color: colorScheme.secondary,
        ),
        const SizedBox(height: 12),
        _ModernTextField(
          label: 'Website',
          icon: Icons.language_rounded,
          value: data.website,
          onChanged: (val) => _update(context, data.copyWith(website: val)),
          hint: 'www.johndoe.com',
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ModernTextField(
                label: 'LinkedIn',
                icon: Icons.business_center_rounded,
                value: data.linkedin,
                onChanged: (val) =>
                    _update(context, data.copyWith(linkedin: val)),
                hint: 'linkedin.com/in/johndoe',
                keyboardType: TextInputType.url,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernTextField(
                label: 'GitHub',
                icon: Icons.code_rounded,
                value: data.github,
                onChanged: (val) =>
                    _update(context, data.copyWith(github: val)),
                hint: 'github.com/johndoe',
                keyboardType: TextInputType.url,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _update(BuildContext context, HeaderModel updated) {
    context.read<ResumeCubit>().updateHeader(section.id, updated);
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ModernTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String value;
  final Function(String) onChanged;
  final String? hint;
  final TextInputType? keyboardType;

  const _ModernTextField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.hint,
    this.keyboardType,
  });

  @override
  State<_ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<_ModernTextField> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.selection = TextSelection.collapsed(
      offset: widget.value.length,
    );
  }

  @override
  void didUpdateWidget(_ModernTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the value changed from outside (not from user typing)
    if (widget.value != oldWidget.value && _controller.text != widget.value) {
      final currentSelection = _controller.selection;
      _controller.text = widget.value;

      // Preserve cursor position if it's still valid
      if (currentSelection.baseOffset <= widget.value.length) {
        _controller.selection = currentSelection;
      } else {
        _controller.selection = TextSelection.collapsed(
          offset: widget.value.length,
        );
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

    return Focus(
      onFocusChange: (focused) {
        setState(() => _isFocused = focused);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isFocused
              ? colorScheme.primaryContainer.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.2),
            width: _isFocused ? 2 : 1,
          ),
        ),
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isFocused
                    ? colorScheme.primary.withValues(alpha: 0.15)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                color: _isFocused
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              color: _isFocused
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

// Extension for copyWith
extension HeaderModelX on HeaderModel {
  HeaderModel copyWith({
    String? fullName,
    String? jobTitle,
    String? email,
    String? phoneNumber,
    String? location,
    String? website,
    String? linkedin,
    String? github,
  }) {
    return HeaderModel(
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
    );
  }
}
