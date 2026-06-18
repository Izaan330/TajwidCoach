import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last Updated: April 29, 2026',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildSection(
              '1. Information We Collect',
              'We collect information you provide directly to us when you create an account, such as your name, email address, and phone number. We also collect audio recordings of your recitations to provide AI-powered feedback.',
            ),
            _buildSection(
              '2. How We Use Information',
              'We use the information we collect to:\n• Provide and improve our AI Tajwid analysis\n• Personalize your learning experience\n• Process payments through RevenueCat\n• Send important service notifications',
            ),
            _buildSection(
              '3. Data Storage & Security',
              'Your data is stored securely using Google Firebase. We implement industry-standard security measures to protect your personal information and recordings.',
            ),
            _buildSection(
              '4. Account Deletion',
              'You can delete your account and all associated data at any time through the Settings menu in the app. This action is permanent.',
            ),
            const SizedBox(height: 48),
            const Center(
              child: Text(
                'For any questions, contact us at:\nd.insuree@gmail.com',
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
