import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/premium_provider.dart';
import '../../theme/app_theme.dart';
import '../settings/terms_of_use_screen.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selectedPlanId = 'premium_yearly';

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();

    // Pop the screen if premium is successfully acquired
    if (premium.isPremium && Navigator.of(context).canPop()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // ─── Background ────────────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A1E14),
                    Color(0xFF0D1628),
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
          ),
          
          // ─── Content ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // ─── Hero Badge ──────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.premiumGold.withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            size: 56,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'TajwidCoach',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Premium',
                          style: GoogleFonts.outfit(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.premiumGold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Elevate your Quranic journey with AI coaching',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ─── Free vs Premium comparison ──────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.menu_book_rounded, color: AppTheme.primaryGreen, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Reading the Quran is always FREE — all 114 Surahs, forever.',
                                  style: TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ─── Feature Grid ────────────────────────────
                        _buildFeatureRow(Icons.psychology_rounded, 'Advanced AI Engine', '25+ Tajwid rules analyzed'),
                        _buildFeatureRow(Icons.record_voice_over_rounded, '15 World-class Qaris', 'From Mishary to Husary & more'),
                        _buildFeatureRow(Icons.pinch_rounded, 'Word-level Feedback', 'Know exactly where you erred'),
                        _buildFeatureRow(Icons.menu_book_rounded, 'Hifz & Revision Tools', 'Progressive word hiding mode'),
                        _buildFeatureRow(Icons.download_rounded, 'Offline Quran & Audio', 'Read & listen without internet'),
                        _buildFeatureRow(Icons.graphic_eq_rounded, 'Sheikh Waveform Compare', 'See your voice vs a Qari'),
                        _buildFeatureRow(Icons.ac_unit_rounded, 'Extra Streak Freezes', 'Never lose your streak again'),
                        _buildFeatureRow(Icons.block_rounded, 'Ad-Free Experience', 'Pure, distraction-free reading'),
                        _buildFeatureRow(Icons.palette_rounded, 'Premium Mushaf Themes', 'Night in Madinah, Ottoman & more'),

                        const SizedBox(height: 12),
                        const Divider(color: AppTheme.divider, height: 40),

                        // ─── Premium Bridge Section ──────────────────
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'PREMIUM BRIDGE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.premiumGold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildBridgeRow(Icons.discount_rounded, '15% off all Sheikh sessions'),
                        _buildBridgeRow(Icons.card_giftcard_rounded, '₹100 Sheikh credit every quarter'),

                        const SizedBox(height: 32),

                        // ─── Regular Plans ──────────────────────────────
                        ...PremiumProvider.plans
                            .where((p) => p.tier != PremiumTier.sheikhPro)
                            .map((plan) => _buildPlanCard(plan)),

                        const SizedBox(height: 24),
                        
                        // ─── Sheikh/Institutional Header ────────────────
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppTheme.divider)),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'FOR TEACHERS & INSTITUTIONS',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryGreen,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: AppTheme.divider)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ─── Sheikh Pro Plan ────────────────────────────
                        ...PremiumProvider.plans
                            .where((p) => p.tier == PremiumTier.sheikhPro)
                            .map((plan) => _buildPlanCard(plan, isInstitutional: true)),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Footer Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundSurface.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: premium.isLoading 
                              ? null 
                              : () => premium.purchasePlan(_selectedPlanId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.premiumGold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: AppTheme.premiumGold.withValues(alpha: 0.4),
                          ),
                          child: premium.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                                )
                              : FittedBox(
                                  child: Text(
                                    'Continue with ${_getPlanName(_selectedPlanId)}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => premium.restorePurchases(),
                            child: const Text('Restore Purchases',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          ),
                          const Text(' • ', style: TextStyle(color: AppTheme.textHint)),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TermsOfUseScreen()),
                            ),
                            child: const Text('Terms of Use',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanName(String id) {
    return PremiumProvider.plans.firstWhere((p) => p.id == id).name;
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 18),
        ],
      ),
    );
  }

  Widget _buildBridgeRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.premiumGold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(PremiumPlan plan, {bool isInstitutional = false}) {
    final isSelected = _selectedPlanId == plan.id;
    
    final accentColor = isInstitutional ? AppTheme.primaryGreen : AppTheme.premiumGold;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? accentColor.withValues(alpha: 0.1) 
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : Colors.white30,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          plan.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? accentColor : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (plan.isPopular && !isInstitutional) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isInstitutional) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'EXCLUSIVELY FOR TEACHERS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    plan.description,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  plan.period,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
