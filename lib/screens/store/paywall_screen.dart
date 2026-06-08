import 'dart:ui';
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

class _PaywallScreenState extends State<PaywallScreen>
    with TickerProviderStateMixin {
  String _selectedPlanId = 'yearly';
  final ScrollController _scrollController = ScrollController();

  late AnimationController _entranceController;
  late AnimationController _bgController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // Start entrance animation immediately
    _entranceController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entranceController.dispose();
    _bgController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();

    if (premium.isPremium && Navigator.of(context).canPop()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // ─── Parallax Animated Background ────────────────────────────────
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              final shift = _bgController.value;
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1.0 + shift * 2, -1.0),
                      end: Alignment(1.0 - shift * 2, 1.0),
                      colors: const [
                        Color(0xFF0A1E14),
                        Color(0xFF0D1628),
                        Color(0xFF000000),
                        Color(0xFF0D1628),
                      ],
                      stops: const [0.0, 0.4, 0.7, 1.0],
                    ),
                  ),
                ),
              );
            },
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
                    controller: _scrollController,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        // ─── Hero Section (Animated Entrance) ──────────────
                        _AnimatedHero(controller: _entranceController),
                        
                        const SizedBox(height: 32),

                        // ─── Feature Grid (Glassmorphism) ──────────────────
                        _buildAnimatedFeatureRow(0, Icons.psychology_rounded, 'Advanced AI Engine', '25+ Tajwid rules analyzed'),
                        _buildAnimatedFeatureRow(1, Icons.record_voice_over_rounded, '15 World-class Qaris', 'From Mishary to Husary & more'),
                        _buildAnimatedFeatureRow(2, Icons.pinch_rounded, 'Word-level Feedback', 'Know exactly where you erred'),
                        _buildAnimatedFeatureRow(3, Icons.menu_book_rounded, 'Hifz & Revision Tools', 'Progressive word hiding mode'),
                        _buildAnimatedFeatureRow(4, Icons.download_rounded, 'Offline Quran & Audio', 'Read & listen without internet'),
                        _buildAnimatedFeatureRow(5, Icons.graphic_eq_rounded, 'Sheikh Waveform Compare', 'See your voice vs a Qari'),
                        _buildAnimatedFeatureRow(6, Icons.ac_unit_rounded, 'Extra Streak Freezes', 'Never lose your streak again'),
                        _buildAnimatedFeatureRow(7, Icons.block_rounded, 'Ad-Free Experience', 'Pure, distraction-free reading'),
                        _buildAnimatedFeatureRow(8, Icons.palette_rounded, 'Premium Mushaf Themes', 'Night in Madinah, Ottoman & more'),

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

                // Footer Actions (with Shimmer CTA)
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              ElevatedButton(
                                onPressed: premium.isLoading 
                                    ? null 
                                    : () => premium.purchasePlan(_selectedPlanId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.premiumGold,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
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
                              if (!premium.isLoading)
                                AnimatedBuilder(
                                  animation: _shimmerController,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: 0,
                                      bottom: 0,
                                      left: -200 + (_shimmerController.value * 600),
                                      child: Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withValues(alpha: 0.0),
                                              Colors.white.withValues(alpha: 0.3),
                                              Colors.white.withValues(alpha: 0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
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

  Widget _buildAnimatedFeatureRow(int index, IconData icon, String title, String subtitle) {
    // Staggered slide and fade
    final slideAnim = Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(0.3 + (index * 0.05).clamp(0.0, 0.7), 1.0, curve: Curves.easeOutQuart),
      ),
    );
    final opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(0.3 + (index * 0.05).clamp(0.0, 0.7), 1.0, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: opacityAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
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
                    const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
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
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 250),
      tween: Tween<double>(begin: 1.0, end: isSelected ? 1.02 : 1.0),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlanId = plan.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
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
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ] : [],
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
          ),
        );
      },
    );
  }
}

class _AnimatedHero extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedHero({required this.controller});

  @override
  Widget build(BuildContext context) {
    final badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );
    final titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    final titleSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutQuart),
      ),
    );

    return Column(
      children: [
        ScaleTransition(
          scale: badgeScale,
          child: Container(
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
        ),
        const SizedBox(height: 24),
        FadeTransition(
          opacity: titleOpacity,
          child: SlideTransition(
            position: titleSlide,
            child: Column(
              children: [
                Text(
                  'Quran Pro: Tajwid AI',
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
