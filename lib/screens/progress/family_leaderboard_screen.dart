import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../providers/premium_provider.dart';
import '../../providers/auth_provider.dart';

class FamilyLeaderboardScreen extends StatelessWidget {
  const FamilyLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Family Leaderboard'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Family Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.emeraldGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.family_restroom_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Family Progress',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${premium.familyMemberUids.length} Active Members',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Leaderboard List
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Weekly Rankings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 16),
            
            if (premium.familyMemberUids.isEmpty)
              const Center(
                child: Text('Invite your family to start competing!'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: premium.familyMemberUids.length,
                itemBuilder: (context, index) {
                  final uid = premium.familyMemberUids[index];
                  final isMe = uid == auth.user?.uid;
                  
                  // Mock data for progress
                  final streak = 5 + (index * 2);
                  final xp = 1200 - (index * 150);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.primaryGreen.withValues(alpha: 0.05) : AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMe ? AppTheme.primaryGreen.withValues(alpha: 0.3) : AppTheme.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isMe ? AppTheme.primaryGreen : AppTheme.backgroundCream,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isMe ? Colors.white : AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMe ? 'You' : 'Member ${uid.substring(0, 4)}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '$streak Day Streak',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$xp XP',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const Text(
                              'This Week',
                              style: TextStyle(fontSize: 10, color: AppTheme.textHint),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
