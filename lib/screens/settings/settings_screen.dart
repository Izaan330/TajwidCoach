import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

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

          const SizedBox(height: 4),
          // Note about Tajweed mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '💡 Tajweed colors activate automatically in 🎨 Tajweed mode.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withAlpha(180),
                fontStyle: FontStyle.italic,
              ),
            ),
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

          const SizedBox(height: 32),
          // ───── Account ─────
          const _SectionHeader(title: 'Account'),
          const SizedBox(height: 8),

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
            child: Text(
              'TajwidCoach v1.0.0+1\nMade with ❤️ for the Ummah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withAlpha(180),
                fontStyle: FontStyle.italic,
              ),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              // The AuthWrapper at the root of the app will automatically
              // switch to the AuthScreen when isAuthenticated becomes false.
              Navigator.of(context).popUntil((route) => route.isFirst);
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
}

class _ScriptPickerSheet extends StatelessWidget {
  final SettingsProvider settings;
  const _ScriptPickerSheet({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                settings.setQuranScript(script);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ],
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

  String get _label {
    switch (script) {
      case QuranScript.mushaf:
        return '🕌 Mushaf (QCF)';
      case QuranScript.indoPak:
        return '🔠 Indo-Pak Script';
      case QuranScript.tajweed:
        return '🎨 Tajweed Colors';
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
    final settings = context.watch<SettingsProvider>();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withAlpha(20)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
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
                      fontFamily: settings.defaultFontFamily,
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isSelected)
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
    return Padding(
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

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppTheme.qalqalahRed : AppTheme.primaryGreen;
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
        trailing: const Icon(Icons.chevron_right_rounded,
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
