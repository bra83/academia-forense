import 'package:flutter/material.dart';
import '../tokens/colors.dart';

/// Navigation item model for Academia Forense
class ForensicNavItem {
  const ForensicNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget? badge;
}

/// Standard 5 Canonical Navigation Tabs (§5.2)
class ForensicNavDestinations {
  ForensicNavDestinations._();

  static const List<ForensicNavItem> items = [
    ForensicNavItem(
      label: 'Início',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    ForensicNavItem(
      label: 'Estudar',
      icon: Icons.school_outlined,
      selectedIcon: Icons.school_rounded,
    ),
    ForensicNavItem(
      label: 'Biblioteca',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
    ),
    ForensicNavItem(
      label: 'Laboratório',
      icon: Icons.biotech_outlined,
      selectedIcon: Icons.biotech_rounded,
    ),
    ForensicNavItem(
      label: 'Meu Espaço',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];
}

/// Dual Responsive Navigation Scaffold (§5.2)
/// Renders a 5-tab Bottom NavigationBar on Android/Mobile,
/// and a lateral NavigationRail on Windows/Desktop (width >= 800dp).
class ForensicResponsiveScaffold extends StatefulWidget {
  const ForensicResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onNavigationIndexChanged,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.desktopBreakpoint = 800.0,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigationIndexChanged;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final double desktopBreakpoint;

  @override
  State<ForensicResponsiveScaffold> createState() => _ForensicResponsiveScaffoldState();
}

class _ForensicResponsiveScaffoldState extends State<ForensicResponsiveScaffold> {
  bool _isRailExtended = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= widget.desktopBreakpoint;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: ForensicColors.background,
            appBar: widget.appBar,
            floatingActionButton: widget.floatingActionButton,
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: ForensicColors.surface,
                  extended: _isRailExtended,
                  selectedIndex: widget.currentIndex,
                  onDestinationSelected: widget.onNavigationIndexChanged,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: IconButton(
                      icon: Icon(
                        _isRailExtended ? Icons.menu_open_rounded : Icons.menu_rounded,
                        color: ForensicColors.forestGreenDark,
                      ),
                      tooltip: _isRailExtended ? 'Recolher menu' : 'Expandir menu',
                      onPressed: () {
                        setState(() {
                          _isRailExtended = !_isRailExtended;
                        });
                      },
                    ),
                  ),
                  destinations: ForensicNavDestinations.items.map((item) {
                    return NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon, color: ForensicColors.forestGreenDark),
                      label: Text(
                        item.label,
                        style: TextStyle(
                          color: widget.currentIndex == ForensicNavDestinations.items.indexOf(item)
                              ? ForensicColors.forestGreenDark
                              : ForensicColors.textSecondary,
                          fontWeight: widget.currentIndex == ForensicNavDestinations.items.indexOf(item)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const VerticalDivider(width: 1, thickness: 1, color: ForensicColors.borders),
                Expanded(child: widget.body),
              ],
            ),
          );
        }

        // Mobile / Tablet Narrow: Bottom NavigationBar
        return Scaffold(
          backgroundColor: ForensicColors.background,
          appBar: widget.appBar,
          floatingActionButton: widget.floatingActionButton,
          body: widget.body,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ForensicColors.borders, width: 1.0)),
            ),
            child: NavigationBar(
              selectedIndex: widget.currentIndex,
              onDestinationSelected: widget.onNavigationIndexChanged,
              destinations: ForensicNavDestinations.items.map((item) {
                return NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
