import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'terms_of_use_screen.dart';

class AcknowledgmentsScreen extends StatelessWidget {
  const AcknowledgmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Acknowledgments'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildIntro(),
          const SizedBox(height: 32),
          _buildSection(
            'Qari Recitations',
            'All Quranic recitations provided in this app are sourced from public collections. We acknowledge the beautiful performances of the world-renowned reciters who bring the words of Allah to life.',
            [
              'Mahmoud Khalil Al-Husary',
              'Mohamed Siddiq Al-Minshawi',
              'Mishary Rashid Alafasy',
              'Abdul Rahman Al-Sudais',
              'Saud Al-Shuraym',
              'Sa\'d Al-Ghamdi',
              'Ahmad Al-Ajmy',
              'Abdullah Basfar',
              'Yasser Al-Dossary',
              'Maher Al-Muaiqly',
            ],
          ),
          const Divider(height: 64),
          _buildSection(
            'Data & Infrastructure',
            'Quran Pro: Tajwid AI is built upon the incredible work of the open-source Islamic tech community. We are grateful for the APIs and datasets provided by:',
            [
              'Islamic.Network (AlQuran.cloud) — Audio CDN & API',
              'Quran.com — Text & Translation data',
              'Tanzil.net — Vetted Quranic text',
              'EveryAyah.com — Global Audio Repository',
              'GlobalQuran.com — Historical archives',
            ],
          ),
          const Divider(height: 64),
          _buildSection(
            'Technical Foundations',
            'Special thanks to the developers of the frameworks and libraries that power our AI and interface.',
            [
              'Flutter & Dart — UI Framework',
              'RevenueCat — Subscription management',
              'Firebase — Backend services',
              'Google Fonts — Typography',
            ],
          ),
          const SizedBox(height: 48),
          _buildNotice(context),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gratitude & Recognition',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Quran Pro: Tajwid AI is a collaborative effort of modern technology and centuries of Islamic scholarship. We stand on the shoulders of giants.',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String description, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => _buildChip(item)).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          const Text(
            'Copyright Notice',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'If you are a rights holder for any content used in this app and believe it has been used inappropriately, please contact us at d.insuree@gmail.com. We respect all intellectual property and will promptly address your concerns.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfUseScreen()),
            ),
            child: const Text(
              'View Full Takedown Policy',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
