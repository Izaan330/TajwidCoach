import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Terms of Use'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Use',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last Updated: May 4, 2026',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing or using TajwidCoach, you agree to be bound by these Terms of Use and all applicable laws and regulations.',
            ),
            _buildSection(
              '2. License to Use',
              'We grant you a personal, non-exclusive, non-transferable license to use the app for your personal Quranic education.',
            ),
            _buildSection(
              '3. Notice and Takedown Policy (DMCA)',
              'TajwidCoach respects the intellectual property rights of others. We source Quranic recitations from public repositories (such as Islamic.Network and EveryAyah.com).\n\nIf you believe that any content in the app infringes upon your copyright, please submit a notice to our designated agent at support@tajwidcoach.ai with the following information:\n\n• Identification of the copyrighted work claimed to have been infringed.\n• Identification of the material that is claimed to be infringing.\n• Your contact information (address, phone number, and email).\n• A statement that you have a good faith belief that use of the material is not authorized.\n• A statement that the information in the notification is accurate, and under penalty of perjury, that you are authorized to act on behalf of the owner.',
            ),
            _buildSection(
              '4. Prohibited Conduct',
              'You agree not to attempt to decompile, reverse engineer, or extract the source code or proprietary AI models of TajwidCoach.',
            ),
            const SizedBox(height: 48),
            const Center(
              child: Text(
                'For legal inquiries, contact us at:\nsupport@tajwidcoach.ai',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
