import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'quran/quran_library_screen.dart';
import 'practice/practice_screen.dart';
import 'progress/progress_screen.dart';
import 'sheikhs/sheikh_list_screen.dart';
import 'sheikhs/sheikh_dashboard_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  late final AnimationController _micPulseController;

  static const List<Widget> _studentScreens = [
    HomeScreen(),
    QuranLibraryScreen(),
    PracticeScreen(),
    ProgressScreen(),
    SheikhListScreen(),
  ];

  static const List<_NavItem> _studentNavItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'Quran'),
    _NavItem(icon: Icons.mic_rounded, label: 'Practice'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Progress'),
    _NavItem(icon: Icons.school_rounded, label: 'Sheikhs'),
  ];

  @override
  void initState() {
    super.initState();
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _micPulseController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    debugPrint('MainNavigation: isSheikh = ${auth.isSheikh}, user = ${auth.user?.name}, role = ${auth.user?.role}');

    if (auth.isSheikh) {
      return const SheikhDashboardScreen();
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _studentScreens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundSurface,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryGreen.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_studentNavItems.length, (index) {
              final item = _studentNavItems[index];
              final isSelected = _selectedIndex == index;
              final isPractice = index == 2;

              if (isPractice) {
                return GestureDetector(
                  onTap: () => _onTabTap(index),
                  child: AnimatedBuilder(
                    animation: _micPulseController,
                    builder: (context, child) {
                      final pulseValue = isSelected
                          ? (0.85 + 0.15 * _micPulseController.value)
                          : 1.0;
                      final glowOpacity = isSelected
                          ? (0.3 + 0.25 * _micPulseController.value)
                          : 0.2;

                      return Transform.scale(
                        scale: pulseValue,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: AppTheme.greenGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen
                                    .withValues(alpha: glowOpacity),
                                blurRadius: 20,
                                spreadRadius: isSelected ? 4 : 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: Colors.black,
                            size: 26,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            item.icon,
                            key: ValueKey(isSelected),
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : AppTheme.textHint,
                            size: isSelected ? 26 : 24,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : AppTheme.textHint,
                          ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
