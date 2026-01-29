import 'package:flutter/material.dart';

/// Sidebar navigation for the dashboard
class DashboardSidebar extends StatelessWidget {
  final bool isExpanded;
  final int selectedIndex;
  final Function(int) onNavItemTap;
  final VoidCallback onToggleExpanded;
  final VoidCallback onSignOut;
  final bool isDrawer;

  const DashboardSidebar({
    super.key,
    required this.isExpanded,
    required this.selectedIndex,
    required this.onNavItemTap,
    required this.onToggleExpanded,
    required this.onSignOut,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 260 : 80,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: isDrawer
            ? null
            : Border(
                right: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
      ),
      child: Column(
        children: [
          // Logo section
          Padding(
            padding: EdgeInsets.all(isExpanded ? 20 : 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Text(
                    'ResuMate',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 12 : 8,
                vertical: 8,
              ),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isExpanded: isExpanded,
                  isSelected: selectedIndex == 0,
                  onTap: () => onNavItemTap(0),
                ),
                _SidebarItem(
                  icon: Icons.description_outlined,
                  selectedIcon: Icons.description_rounded,
                  label: 'My Resumes',
                  isExpanded: isExpanded,
                  isSelected: selectedIndex == 1,
                  onTap: () => onNavItemTap(1),
                ),
                _SidebarItem(
                  icon: Icons.grid_view_outlined,
                  selectedIcon: Icons.grid_view_rounded,
                  label: 'Templates',
                  isExpanded: isExpanded,
                  isSelected: selectedIndex == 2,
                  onTap: () => onNavItemTap(2),
                  badge: 'NEW',
                ),
                _SidebarItem(
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics_rounded,
                  label: 'Analytics',
                  isExpanded: isExpanded,
                  isSelected: selectedIndex == 3,
                  onTap: () => onNavItemTap(3),
                ),

                const SizedBox(height: 16),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      'TOOLS',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                _SidebarItem(
                  icon: Icons.smart_toy_outlined,
                  selectedIcon: Icons.smart_toy_rounded,
                  label: 'AI Assistant',
                  isExpanded: isExpanded,
                  isSelected: selectedIndex == 4,
                  onTap: () => onNavItemTap(4),
                  badge: 'BETA',
                ),
                _SidebarItem(
                  icon: Icons.spellcheck_outlined,
                  selectedIcon: Icons.spellcheck_rounded,
                  label: 'ATS Checker',
                  isExpanded: isExpanded,
                  isSelected: selectedIndex == 5,
                  onTap: () => onNavItemTap(5),
                ),
              ],
            ),
          ),

          // Bottom section - Sign out only
          Container(
            padding: EdgeInsets.all(isExpanded ? 16 : 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: _SidebarItem(
              icon: Icons.logout_rounded,
              selectedIcon: Icons.logout_rounded,
              label: 'Sign Out',
              isExpanded: isExpanded,
              isSelected: false,
              onTap: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isExpanded ? 12 : 0,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                : _isHovered
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: widget.isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                widget.isSelected ? widget.selectedIcon : widget.icon,
                color: widget.isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 22,
              ),
              if (widget.isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: widget.isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.badge == 'NEW'
                          ? colorScheme.primaryContainer
                          : colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.badge!,
                      style: textTheme.labelSmall?.copyWith(
                        color: widget.badge == 'NEW'
                            ? colorScheme.primary
                            : colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
