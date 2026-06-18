import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/premium_provider.dart';
import '../../providers/streak_provider.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    final premiumProvider = context.watch<PremiumProvider>();
    final isPremium = premiumProvider.isPremium;
    final isLoading = premiumProvider.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Upgrade'),
        actions: [
          TextButton(
            onPressed: (_isRestoring || isLoading)
                ? null
                : () async {
                    setState(() => _isRestoring = true);
                    try {
                      final restored = await premiumProvider.restorePurchases();
                      if (context.mounted) {
                        if (restored) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Purchases restored successfully!'),
                              backgroundColor: AppTheme.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No active subscriptions found to restore.'),
                              backgroundColor: AppTheme.qalqalahRed,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    } on PlatformException catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Restore failed: ${e.message ?? e.toString()}'),
                            backgroundColor: AppTheme.qalqalahRed,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Restore failed: $e'),
                            backgroundColor: AppTheme.qalqalahRed,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } finally {
                      if (context.mounted) {
                        setState(() => _isRestoring = false);
                      }
                    }
                  },
            child: _isRestoring
                ? const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Restore',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.premiumGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: AppTheme.premiumGold, size: 54),
                  const SizedBox(height: 12),
                  const Text(
                    'Quran Pro: Tajwid AI Premium',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AI coaching + offline access + ad-free\nElevate your Quran journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          '7-Day Free Trial',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Status
            if (isPremium)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.ikhfaGreenBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.ikhfaGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppTheme.ikhfaGreen, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'You are a Premium member! Enjoy all features.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ikhfaGreen,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Plans
            ...PremiumProvider.plans.map(
              (plan) => _PlanCard(
                plan: plan,
                isPurchased:
                    isPremium && premiumProvider.currentPlanId == plan.id,
                isLoading: isLoading,
                onPurchase: () async {
                  try {
                    await premiumProvider.purchasePlan(plan.id);
                  } on PlatformException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Purchase failed: ${e.message ?? e.toString()}'),
                          backgroundColor: AppTheme.qalqalahRed,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Purchase failed: $e'),
                          backgroundColor: AppTheme.qalqalahRed,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // Streak Boosters
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Streak Boosters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _BoosterCard(
                    title: '1 Refresh',
                    description: 'Refill 1 Streak Freeze',
                    price: '₹49',
                    icon: Icons.ac_unit_rounded,
                    iconColor: AppTheme.info,
                    onTap: () {
                      context.read<StreakProvider>().purchaseFreezes(1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Streak Freeze added!')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BoosterCard(
                    title: '3 Pack',
                    description: 'Save 30% on Freezes',
                    price: '₹99',
                    icon: Icons.ac_unit_rounded,
                    iconColor: AppTheme.info,
                    onTap: () {
                      context.read<StreakProvider>().purchaseFreezes(3);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('3 Streak Freezes added!')),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Payment methods
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Text(
                    'Accepted Payment Methods',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _PaymentBadge('UPI'),
                      _PaymentBadge('Google Pay'),
                      _PaymentBadge('Apple Pay'),
                      _PaymentBadge('Razorpay'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Features comparison
            const Text(
              'What\'s Included',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _FeatureComparisonTable(),
            const SizedBox(height: 16),

            // Legal
            const Text(
              'Cancel anytime. Subscriptions automatically renew. 7-day trial then ₹199/year.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppTheme.textHint),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final PremiumPlan plan;
  final bool isPurchased;
  final bool isLoading;
  final VoidCallback onPurchase;

  const _PlanCard({
    required this.plan,
    required this.isPurchased,
    required this.isLoading,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: plan.isPopular ? AppTheme.primaryGreen : AppTheme.divider,
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: plan.isPopular
            ? [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                  blurRadius: 16,
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (plan.isPopular)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Most Popular',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        plan.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.price,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      plan.period,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Features
            ...plan.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPurchased || isLoading ? null : onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPurchased
                      ? AppTheme.success
                      : plan.isPopular
                          ? AppTheme.primaryGreen
                          : AppTheme.textSecondary,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPurchased) ...[
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                          ],
                          Text(isPurchased ? 'Current Plan' : 'Start Free Trial'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoosterCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _BoosterCard({
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCream,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGreen,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String label;
  const _PaymentBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FeatureComparisonTable extends StatelessWidget {
  Widget _buildCell(String val) {
    if (val == '✅') return const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 18);
    if (val == '🔒') return const Icon(Icons.lock_rounded, color: AppTheme.textHint, size: 18);
    if (val == '❌ Yes') return const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cancel_rounded, color: AppTheme.qalqalahRed, size: 16), SizedBox(width: 4), Text('Yes', style: TextStyle(fontSize: 12))]);
    if (val == '✅ None') return const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 16), SizedBox(width: 4), Text('None', style: TextStyle(fontSize: 12))]);
    return Text(val, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12));
  }

  @override
  Widget build(BuildContext context) {
    const features = [
      ['Full Quran (114 Surahs)', '✅', '✅'],
      ['Qaris available', '3', '15'],
      ['Tajwid rules analyzed', '5', '25+'],
      ['Word-level feedback', '🔒', '✅'],
      ['Hifz Mode', '🔒', '✅'],
      ['Offline audio', '🔒', '✅'],
      ['Ad-free experience', '🔒', '✅'],
      ['Sheikh waveform compare', '🔒', '✅'],
      ['Premium Mushaf themes', '🔒', '✅'],
      ['Extra streak freezes', '🔒', '✅'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: AppTheme.greenGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Feature',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Free',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          ...features.asMap().entries.map((e) {
            final i = e.key;
            final row = e.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: i % 2 == 0
                    ? AppTheme.backgroundCream.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(row[0], style: const TextStyle(fontSize: 13)),
                  ),
                  Expanded(
                    child: Center(child: _buildCell(row[1])),
                  ),
                  Expanded(
                    child: Center(child: _buildCell(row[2])),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

