import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/sheikh_model.dart';

class SheikhOnboardingScreen extends StatefulWidget {
  const SheikhOnboardingScreen({super.key});

  @override
  State<SheikhOnboardingScreen> createState() =>
      _SheikhOnboardingScreenState();
}

class _SheikhOnboardingScreenState extends State<SheikhOnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _englishNameController = TextEditingController();
  final _masjidController      = TextEditingController();
  final _cityController        = TextEditingController();
  final _bioController         = TextEditingController();
  final _phoneController       = TextEditingController();
  final _priceController       = TextEditingController();
  final _groupSizeController   = TextEditingController();

  bool _offersGroupClasses = false;

  final List<String> _selectedSpecializations = [];
  final List<String> _availableSpecializations = [
    'Hafs an Asim', 'Warsh an Nafi', 'Qalun an Nafi',
    'Al-Duri an Abu Amr', "Shu'bah an Asim", 'Khalaf an Hamzah',
    "Ten Qira'at", 'Tajwid Theory', 'Hifz Memorization',
    'Noorani Qaida', 'Maqamat', 'Tafsir',
    'Quranic Arabic', 'Child Education', 'Female Only Classes',
  ];

  late final AnimationController _progressController;

  static const _stepTitles = [
    'Welcome',
    'Personal Details',
    'Affiliation',
    'Specializations',
    'Pricing',
    'Review',
  ];

  static const _stepIcons = [
    Icons.auto_stories_rounded,
    Icons.person_rounded,
    Icons.location_city_rounded,
    Icons.school_rounded,
    Icons.payments_rounded,
    Icons.verified_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _priceController.text = '500';
    _groupSizeController.text = '5';
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 0,
    );
  }

  @override
  void dispose() {
    for (final c in [
      _englishNameController, _masjidController, _cityController,
      _bioController, _phoneController, _priceController,
      _groupSizeController, _pageController,
    ]) {
      c.dispose();
    }
    _progressController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (!_validateCurrentStep()) return;
    HapticFeedback.lightImpact();
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _submit();
    }
  }

  void _goBack() {
    HapticFeedback.lightImpact();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user != null && _phoneController.text.isEmpty) {
      _phoneController.text = user.phone;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundMid,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (p) => setState(() => _currentPage = p),
              children: [
                _buildIntroStep(),
                _buildPersonalInfoStep(),
                _buildProfessionalInfoStep(),
                _buildSpecializationStep(),
                _buildPricingStep(),
                _buildSummaryStep(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ─── Header with step indicator ─────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF0D1628)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: _goBack,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step ${_currentPage + 1} of 6',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _stepTitles[_currentPage],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Step icon badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.4)),
                    ),
                    child: Icon(_stepIcons[_currentPage],
                        color: AppTheme.primaryGreen, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Segmented progress
              Row(
                children: List.generate(6, (i) {
                  final active = i <= _currentPage;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.primaryGreen
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryGreen
                                      .withValues(alpha: 0.5),
                                  blurRadius: 6,
                                )
                              ]
                            : [],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Steps ───────────────────────────────────────────────────────────────
  Widget _buildIntroStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.emeraldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.auto_stories_rounded,
                color: Colors.white, size: 56),
          ),
          const SizedBox(height: 28),
          const Text(
            'Join as a Tajwid Scholar',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Share your knowledge and help students worldwide perfect their Quranic recitation.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 36),
          ...[
            ('🎓', 'Personalized student feedback'),
            ('📜', 'Issue digital Ijazah certificates'),
            ('📋', 'Manage your own student lists'),
          ].map((e) => _buildBenefitTile(e.$1, e.$2)),
        ],
      ),
    );
  }

  Widget _buildBenefitTile(String emoji, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppTheme.primaryGreen, size: 20),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildTextField('Full Name (English)', _englishNameController,
              hint: 'e.g. Sheikh Ahmed',
              icon: Icons.person_outline_rounded),
          const SizedBox(height: 16),
          _buildTextField('Phone Number', _phoneController,
              hint: '+1 000 000 0000',
              keyboardType: TextInputType.phone,
              icon: Icons.phone_outlined),
          const SizedBox(height: 16),
          _buildTextField('Brief Bio', _bioController,
              hint: 'Years of experience, teachers, qualifications...',
              maxLines: 5,
              icon: Icons.notes_rounded),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildTextField('Masjid / Institution', _masjidController,
              hint: 'e.g. Masjid Al-Haram',
              icon: Icons.account_balance_rounded),
          const SizedBox(height: 16),
          _buildTextField('City', _cityController,
              hint: 'e.g. Medina',
              icon: Icons.location_on_outlined),
        ],
      ),
    );
  }

  Widget _buildSpecializationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select the areas you are qualified to teach:',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _availableSpecializations.map((spec) {
              final isSelected = _selectedSpecializations.contains(spec);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isSelected) {
                      _selectedSpecializations.remove(spec);
                    } else {
                      _selectedSpecializations.add(spec);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryGreen.withValues(alpha: 0.15)
                        : AppTheme.backgroundSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryGreen.withValues(alpha: 0.6)
                          : AppTheme.divider,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  AppTheme.primaryGreen.withValues(alpha: 0.1),
                              blurRadius: 8,
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check_rounded,
                            color: AppTheme.primaryGreen, size: 14),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        spec,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildTextField('Session Price (₹)', _priceController,
              hint: 'e.g. 500',
              keyboardType: TextInputType.number,
              icon: Icons.currency_rupee_rounded),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Offer Group Classes',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      SizedBox(height: 2),
                      Text('Allow multiple students per session',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Switch(
                  value: _offersGroupClasses,
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    setState(() => _offersGroupClasses = val);
                  },
                ),
              ],
            ),
          ),
          if (_offersGroupClasses) ...[
            const SizedBox(height: 16),
            _buildTextField('Max Group Size', _groupSizeController,
                hint: 'e.g. 5',
                keyboardType: TextInputType.number,
                icon: Icons.group_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.emeraldGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(Icons.verified_rounded, color: Colors.white, size: 48),
                SizedBox(height: 10),
                Text('Review Your Profile',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                SizedBox(height: 4),
                Text('Everything look good?',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...[
            ('Scholar Name', _englishNameController.text, Icons.person_rounded),
            ('Phone', _phoneController.text, Icons.phone_rounded),
            ('Bio', _bioController.text, Icons.notes_rounded),
            ('Masjid', _masjidController.text, Icons.account_balance_rounded),
            ('City', _cityController.text, Icons.location_on_rounded),
            ('Specializations', _selectedSpecializations.join(', '),
                Icons.school_rounded),
            ('Price', '₹${_priceController.text} / session',
                Icons.payments_rounded),
            ('Group Classes',
                _offersGroupClasses
                    ? 'Enabled (Max ${_groupSizeController.text})'
                    : 'Disabled',
                Icons.group_rounded),
          ].map((e) => _buildSummaryRow(e.$1, e.$2, e.$3)),
          const SizedBox(height: 20),
          const Text(
            'By submitting, you agree to provide authentic and accurate feedback to students following the principles of Tajwid.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.textHint, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHint,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(value.isEmpty ? 'Not provided' : value,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Nav ──────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final authProvider = context.watch<AuthProvider>();
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundSurface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: authProvider.isLoading ? null : AppTheme.greenGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: authProvider.isLoading
                ? []
                : [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _goNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.primaryGreen),
                  )
                : Text(
                    _currentPage == 5 ? 'Complete ✓' : 'Next →',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ),
    );
  }

  // ─── Shared TextField ────────────────────────────────────────────────────
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? icon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: AppTheme.textHint, size: 20)
                : null,
          ),
        ),
      ],
    );
  }

  // ─── Validation ──────────────────────────────────────────────────────────
  bool _validateCurrentStep() {
    String? error;
    if (_currentPage == 1) {
      if (_englishNameController.text.trim().isEmpty) {
        error = 'Please enter your name';
      } else if (_bioController.text.trim().length < 20) {
        error = 'Bio must be at least 20 characters';
      }
    } else if (_currentPage == 2) {
      if (_masjidController.text.trim().isEmpty) {
        error = 'Please enter your masjid or institution';
      } else if (_cityController.text.trim().isEmpty) {
        error = 'Please enter your city';
      }
    } else if (_currentPage == 3) {
      if (_selectedSpecializations.isEmpty) {
        error = 'Please select at least one specialization';
      }
    } else if (_currentPage == 4) {
      if (_priceController.text.isEmpty) {
        error = 'Please enter a session price';
      }
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppTheme.qalqalahRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      return false;
    }
    return true;
  }

  // ─── Submit ───────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    final sheikhData = SheikhModel(
      id: user.uid,
      name: user.name,
      englishName: _englishNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: user.email ?? '',
      masjid: _masjidController.text.trim(),
      city: _cityController.text.trim(),
      specializations: _selectedSpecializations,
      bio: _bioController.text.trim(),
      pricePerSession: int.tryParse(_priceController.text) ?? 0,
      offersGroupClasses: _offersGroupClasses,
      groupClassSize: int.tryParse(_groupSizeController.text) ?? 5,
      isVerified: true,
      isAvailable: true,
    );

    await auth.upgradeToSheikh(sheikhData);
    if (!mounted) return;

    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error!),
        backgroundColor: AppTheme.qalqalahRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    await auth.refreshUserFromFirestore();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
