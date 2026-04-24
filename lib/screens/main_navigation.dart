import 'package:flutter/material.dart';
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

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

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
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    if (auth.isSheikh) {
      return const SheikhDashboardScreen();
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _studentScreens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_studentNavItems.length, (index) {
                final item = _studentNavItems[index];
                final isSelected = _selectedIndex == index;
                final isPractice = index == 2;

                if (isPractice) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppTheme.greenGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.mic_rounded, color: Colors.white, size: 26),
                    ),
                  );
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected ? AppTheme.primaryGreen : AppTheme.textHint,
                            size: 24,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppTheme.primaryGreen : AppTheme.textHint,
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
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
