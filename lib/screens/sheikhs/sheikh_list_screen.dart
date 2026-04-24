import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/sheikh_model.dart';
import '../../providers/sheikh_provider.dart';
import 'sheikh_profile_screen.dart';
import 'sheikh_dashboard_screen.dart';
import 'sheikh_onboarding_screen.dart';
class SheikhListScreen extends StatefulWidget {
  const SheikhListScreen({super.key});

  @override
  State<SheikhListScreen> createState() => _SheikhListScreenState();
}

class _SheikhListScreenState extends State<SheikhListScreen> {
  String _selectedCity = 'All';
  static const List<String> _cities = [
    'All',
    'Delhi',
    'Mumbai',
    'Hyderabad',
    'Bengaluru',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isSheikh = auth.isSheikh;
    final sheikhProvider = context.watch<SheikhProvider>();
    final sheikhs = sheikhProvider.availableSheikhs;

    if (sheikhProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _selectedCity == 'All'
        ? sheikhs
        : sheikhs.where((s) => s.city == _selectedCity).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Sheikhs'),
        actions: [
          if (isSheikh)
            IconButton(
              icon: const Icon(Icons.dashboard_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SheikhDashboardScreen(),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!isSheikh)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _BecomeScholarCard(),
            ),
          // City filter
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _cities.length,
              itemBuilder: (context, i) {
                final city = _cities[i];
                final selected = city == _selectedCity;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCity = city),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selected ? AppTheme.primaryGreen : AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            selected ? AppTheme.primaryGreen : AppTheme.divider,
                      ),
                    ),
                    child: Text(
                      city,
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w400,
                        color: selected ? Colors.white : AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Sheikh cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _SheikhCard(
                sheikh: filtered[index],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        SheikhProfileScreen(sheikh: filtered[index]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheikhCard extends StatelessWidget {
  final SheikhModel sheikh;
  final VoidCallback onTap;

  const _SheikhCard({required this.sheikh, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.greenGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        sheikh.name.split(' ').map((w) => w[0]).take(2).join(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                sheikh.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (sheikh.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '✅ Verified',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sheikh.englishName,
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${sheikh.masjid} • ${sheikh.city}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Rating & Stats
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppTheme.accentAmber,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sheikh.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.people_rounded,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${sheikh.totalStudents} students',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: sheikh.isAvailable
                          ? AppTheme.ikhfaGreenBg
                          : AppTheme.divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sheikh.isAvailable ? '✅ Available' : '⏰ Busy',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sheikh.isAvailable
                            ? AppTheme.ikhfaGreen
                            : AppTheme.textHint,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Specializations
              Wrap(
                spacing: 6,
                children: sheikh.specializations
                    .map(
                      (spec) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundCream,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Text(
                          spec,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              // Book button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: sheikh.isAvailable ? onTap : null,
                  child: Text(
                    sheikh.isAvailable
                        ? 'Book Session — ₹${sheikh.pricePerSession}'
                        : 'Join Waitlist',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BecomeScholarCard extends StatelessWidget {
  const _BecomeScholarCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_stories, color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you a Tajwid Scholar?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Join our verified scholars to guide students.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SheikhOnboardingScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Become a Scholar'),
          ),
        ],
      ),
    );
  }
}
