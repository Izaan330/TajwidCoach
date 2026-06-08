import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/premium_provider.dart';
import '../../services/revenue_cat_service.dart';
import '../../theme/app_theme.dart';
import 'privacy_policy_screen.dart';
import '../progress/family_leaderboard_screen.dart';
import '../store/paywall_screen.dart';
import 'acknowledgments_screen.dart';
import 'terms_of_use_screen.dart';
import 'feedback_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final premium = context.watch<PremiumProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ───── Subscription ─────
          const _SectionHeader(title: 'Subscription'),
          const SizedBox(height: 8),
          _SettingsCard(
            icon: Icons.workspace_premium_rounded,
            iconColor: AppTheme.premiumGold,
            title: premium.isPremium ? 'Premium Active' : 'Upgrade to Premium',
            subtitle: premium.isPremium 
                ? 'You are enjoying all pro features' 
                : 'Unlock AI feedback, offline mode, and more',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaywallScreen()),
            ),
            trailing: premium.isPremium 
                ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen)
                : const Icon(Icons.chevron_right_rounded),
          ),
          const SizedBox(height: 16),
          if (premium.isPremium) ...[
            _SettingsCard(
              icon: Icons.manage_accounts_rounded,
              title: 'Manage Subscription',
              subtitle: 'Update payment method or cancel plan',
              onTap: () => RevenueCatService.presentCustomerCenter(),
            ),
            const SizedBox(height: 16),
          ],

          // ───── Family Plan ─────
          if (premium.isFamilyPlan) ...[
            const _SectionHeader(title: 'Family Plan'),
            const SizedBox(height: 8),
            _SettingsCard(
              icon: Icons.group_add_rounded,
              title: 'Manage Family',
              subtitle: 'Invite members and see leaderboard',
              onTap: () => _showFamilyManager(context, premium),
            ),
            const SizedBox(height: 16),
          ],
          // ───── Quran Display ─────
          const _SectionHeader(title: 'Quran Display'),
          const SizedBox(height: 8),

          // Script Type
          _SettingsCard(
            icon: Icons.auto_stories_rounded,
            title: 'Quran Script',
            subtitle: settings.scriptName,
            onTap: () => _showScriptPicker(context, settings),
          ),

          // Font Size
          _FontSizeCard(settings: settings),

          const SizedBox(height: 16),
          // ───── Translation ─────
          const _SectionHeader(title: 'Translation'),
          const SizedBox(height: 8),

          _SettingsCard(
            icon: Icons.translate_rounded,
            title: 'Translation Language',
            subtitle: settings.translationName,
            onTap: () => _showTranslationPicker(context, settings),
          ),

          const SizedBox(height: 16),
          // ───── Reading ─────
          const _SectionHeader(title: 'Reading'),
          const SizedBox(height: 8),

          _SwitchCard(
            icon: Icons.format_align_left_rounded,
            title: 'Show Translation',
            subtitle: 'Display translation below each verse',
            value: settings.showTranslation,
            onChanged: (v) => settings.setShowTranslation(v),
          ),


          const SizedBox(height: 16),
          // ───── Support & Community ─────
          const _SectionHeader(title: 'Support & Community'),
          const SizedBox(height: 8),

          _SettingsCard(
            icon: Icons.feedback_rounded,
            title: 'Feedback',
            subtitle: 'Send us your thoughts and suggestions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            ),
          ),

          _SettingsCard(
            icon: Icons.star_rate_rounded,
            title: 'Rate Us',
            subtitle: 'Love the app? Leave a review',
            onTap: () async {
              final inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                await inAppReview.requestReview();
              } else {
                await inAppReview.openStoreListing(
                  appStoreId: '6745678901', // Replace with real App Store ID before release
                );
              }
            },
          ),

          _SettingsCard(
            icon: Icons.share_rounded,
            title: 'Share',
            subtitle: 'Share Quran Pro with friends',
            onTap: () {
              // Direct OS native share sheet via share_plus
              importSharePlusAndShare(context);
            },
          ),

          const SizedBox(height: 16),
          // ───── Legal ─────
          const _SectionHeader(title: 'Legal'),
          const SizedBox(height: 8),

          _SettingsCard(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),

          _SettingsCard(
            icon: Icons.favorite_rounded,
            title: 'Acknowledgments',
            subtitle: 'Attributions & Sources',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AcknowledgmentsScreen()),
            ),
          ),

          _SettingsCard(
            icon: Icons.description_rounded,
            title: 'Terms of Use',
            subtitle: 'Usage policy & takedown notice',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfUseScreen()),
            ),
          ),

          const SizedBox(height: 32),
          // ───── Account ─────
          const _SectionHeader(title: 'Account'),
          const SizedBox(height: 8),

          _SettingsCard(
            icon: Icons.person_rounded,
            title: 'Edit Name',
            subtitle: (user?.name.isNotEmpty == true) ? user!.name : 'Tap to set your name',
            onTap: () => _showEditNameDialog(context, user?.name ?? ''),
          ),

          _SettingsCard(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () => _showLogoutDialog(context),
          ),

          _SettingsCard(
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account',
            subtitle: 'Permanently remove your data',
            onTap: () => _showDeleteAccountDialog(context),
            isDanger: true,
          ),

          const SizedBox(height: 32),
          // Info
          Center(
            child: Column(
              children: [
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final versionText = snapshot.hasData
                        ? 'Quran Pro v${snapshot.data!.version}'
                        : 'Quran Pro v1.0.0';
                    return Text(
                      versionText,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withAlpha(180),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Made with ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withAlpha(180),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Icon(Icons.favorite_rounded, color: AppTheme.qalqalahRed, size: 14),
                    Text(
                      ' for the Ummah',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withAlpha(180),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showScriptPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ScriptPickerSheet(settings: settings),
    );
  }

  void _showTranslationPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TranslationPickerSheet(settings: settings),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await context.read<AuthProvider>().updateProfile(name: name);
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (dialogCtx.mounted) {
                Navigator.of(dialogCtx).popUntil((route) => route.isFirst);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text(
          'This action is permanent and will delete all your progress, recordings, and personal data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().deleteAccount();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFamilyManager(BuildContext context, PremiumProvider premium) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FamilyManagerSheet(premium: premium),
    );
  }
}

class _ScriptPickerSheet extends StatelessWidget {
  final SettingsProvider settings;
  const _ScriptPickerSheet({required this.settings});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Quran Script',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Switch between rendering modes. Tajweed mode adds color-coding.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            for (final script in QuranScript.values) ...[
              _ScriptOption(
                script: script,
                isSelected: settings.quranScript == script,
                onTap: () {
                  final premium = context.read<PremiumProvider>();
                  if (script != QuranScript.indoPak && !premium.isPremium) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PaywallScreen()),
                    );
                    return;
                  }
                  settings.setQuranScript(script);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScriptOption extends StatelessWidget {
  final QuranScript script;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScriptOption({
    required this.script,
    required this.isSelected,
    required this.onTap,
  });

  String get _arabicSample {
    switch (script) {
      case QuranScript.mushaf:
        return 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
      case QuranScript.indoPak:
        return 'بِسۡمِ اللّٰہِ الرَّحۡمٰنِ الرَّحِیۡمِ';
      case QuranScript.tajweed:
        return 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
    }
  }

  String get _fontFamily {
    switch (script) {
      case QuranScript.indoPak:
        return 'IndoPak';
      case QuranScript.tajweed:
      case QuranScript.mushaf:
        return 'UthmanicHafs';
    }
  }

  String get _label {
    switch (script) {
      case QuranScript.mushaf:
        return 'Mushaf (QCF)';
      case QuranScript.indoPak:
        return 'Indo-Pak Script';
      case QuranScript.tajweed:
        return 'Tajweed Colors';
    }
  }

  IconData get _iconData {
    switch (script) {
      case QuranScript.mushaf:
        return Icons.auto_stories_rounded;
      case QuranScript.indoPak:
        return Icons.translate_rounded;
      case QuranScript.tajweed:
        return Icons.color_lens_rounded;
    }
  }

  String get _description {
    switch (script) {
      case QuranScript.mushaf:
        return 'Pixel-perfect Madani Mushaf. Exactly like the printed Quran.';
      case QuranScript.indoPak:
        return 'South Asian style (popular in India, Pakistan, Bangladesh).';
      case QuranScript.tajweed:
        return 'Uthmani text with color-coded Tajweed rules.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();
    final isLocked = script != QuranScript.indoPak && !premium.isPremium;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withAlpha(20)
              : AppTheme.backgroundElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen.withAlpha(30) : AppTheme.backgroundSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconData,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _arabicSample,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isLocked)
              const Icon(Icons.lock_outline_rounded,
                  color: AppTheme.textHint, size: 20)
            else if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.primaryGreen),
          ],
        ),
      ),
    );
  }
}

class _TranslationPickerSheet extends StatelessWidget {
  final SettingsProvider settings;
  const _TranslationPickerSheet({required this.settings});

  static const _options = [
    (TranslationLanguage.english, 'English', 'Sahih International',
        'en.sahih'),
    (TranslationLanguage.urdu, 'Urdu', 'جالندھری', 'ur.jalandhry'),
    (TranslationLanguage.hindi, 'Hindi / हिन्दी', 'Standard', 'hi.hindi'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Translation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            for (final opt in _options) ...[
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: settings.translationLanguage == opt.$1
                    ? AppTheme.primaryGreen.withAlpha(20)
                    : null,
                title: Text(opt.$2,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(opt.$3),
                trailing: settings.translationLanguage == opt.$1
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppTheme.primaryGreen)
                    : null,
                onTap: () {
                  settings.setTranslationLanguage(opt.$1);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textSecondary.withAlpha(180),
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;
  final Color? iconColor;
  final Widget? trailing;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppTheme.qalqalahRed : (iconColor ?? AppTheme.primaryGreen);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDanger ? AppTheme.qalqalahRed : AppTheme.textPrimary,
            )),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryGreen,
      ),
    );
  }
}

class _FontSizeCard extends StatelessWidget {
  final SettingsProvider settings;
  const _FontSizeCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.format_size_rounded,
                      color: AppTheme.primaryGreen, size: 20),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Arabic Font Size',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('${settings.quranFontSize.toInt()}px',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
            Slider(
              value: settings.quranFontSize,
              min: 18,
              max: 48,
              divisions: 10,
              activeColor: AppTheme.primaryGreen,
              label: '${settings.quranFontSize.toInt()}px',
              onChanged: (v) => settings.setQuranFontSize(v),
            ),
            // Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCream,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: settings.defaultFontFamily,
                  fontSize: settings.quranFontSize,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyManagerSheet extends StatelessWidget {
  final PremiumProvider premium;
  const _FamilyManagerSheet({required this.premium});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: 40,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '👨‍👩‍👧‍👦 Family Manager',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (premium.familyCode == null)
            Center(
              child: Column(
                children: [
                  const Text(
                    'No family group created yet.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => premium.generateFamilyCode(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Generate Family Code'),
                  ),
                ],
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Your Family Invite Code',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    premium.familyCode!,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Share this code with up to 2 family members to join your plan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FamilyLeaderboardScreen()),
                ),
                icon: const Icon(Icons.leaderboard_rounded),
                label: const Text('View Family Leaderboard'),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryGreen),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Family Members',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...premium.familyMemberUids.map((uid) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.backgroundCream,
                    child: Icon(Icons.person_rounded, color: AppTheme.primaryGreen),
                  ),
                  title: Text('Member ${uid.substring(0, 5)}...'),
                  subtitle: Text(uid == premium.userId ? 'Owner' : 'Family Member'),
                  trailing: uid != premium.userId
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
                          onPressed: () {
                            // Logic to remove member
                          },
                        )
                      : const Text('You', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                )),
            if (premium.familyMemberUids.length < 3)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    '+ Waiting for more members...',
                    style: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

void importSharePlusAndShare(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  
  Share.share(
    'Assalamu Alaikum! Join me in using Quran Pro: Tajwid AI to learn and master Quranic Tajweed with real-time AI audio feedback. 📖🎤 Download now and let\'s build our daily Quran habits together! https://quranpro.ai',
    subject: 'Quran Pro: Tajwid AI - Learn Quranic Tajweed',
    sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
  );
}
