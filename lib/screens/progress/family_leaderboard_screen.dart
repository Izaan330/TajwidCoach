import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../providers/premium_provider.dart';
import '../../providers/auth_provider.dart';

class _MemberData {
  final String uid;
  final String name;
  final int streak;
  final int weeklyXp;

  _MemberData({
    required this.uid,
    required this.name,
    required this.streak,
    required this.weeklyXp,
  });
}

class FamilyLeaderboardScreen extends StatefulWidget {
  const FamilyLeaderboardScreen({super.key});

  @override
  State<FamilyLeaderboardScreen> createState() => _FamilyLeaderboardScreenState();
}

class _FamilyLeaderboardScreenState extends State<FamilyLeaderboardScreen> {
  List<_MemberData> _members = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMembers());
  }

  Future<void> _fetchMembers() async {
    final premium = context.read<PremiumProvider>();
    final uids = premium.familyMemberUids;

    if (uids.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final List<_MemberData> fetched = [];

      // Firestore 'in' queries support up to 30 items; batch if needed
      const batchSize = 30;
      for (int i = 0; i < uids.length; i += batchSize) {
        final batch = uids.sublist(i, (i + batchSize).clamp(0, uids.length));
        final snapshot = await firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in snapshot.docs) {
          final data = doc.data();
          fetched.add(_MemberData(
            uid: doc.id,
            name: (data['name'] as String?)?.isNotEmpty == true
                ? data['name'] as String
                : 'Member ${doc.id.substring(0, 4)}',
            streak: (data['currentStreak'] as num?)?.toInt() ?? 0,
            weeklyXp: (data['weeklyXp'] as num?)?.toInt() ??
                (data['totalXp'] as num?)?.toInt() ?? 0,
          ));
        }

        // Add any UIDs not found in Firestore as placeholders
        final foundUids = snapshot.docs.map((d) => d.id).toSet();
        for (final uid in batch) {
          if (!foundUids.contains(uid)) {
            fetched.add(_MemberData(
              uid: uid,
              name: 'Member ${uid.substring(0, 4)}',
              streak: 0,
              weeklyXp: 0,
            ));
          }
        }
      }

      // Sort by weeklyXp descending
      fetched.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));

      if (mounted) {
        setState(() {
          _members = fetched;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load leaderboard: $e';
          _loading = false;
        });
      }
    }
  }

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
            else if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final member = _members[index];
                  final isMe = member.uid == auth.user?.uid;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppTheme.primaryGreen.withValues(alpha: 0.05)
                          : AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMe
                            ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                            : AppTheme.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: index == 0
                              ? const Color(0xFFFFD700)
                              : index == 1
                                  ? const Color(0xFFC0C0C0)
                                  : index == 2
                                      ? const Color(0xFFCD7F32)
                                      : isMe
                                          ? AppTheme.primaryGreen
                                          : AppTheme.backgroundCream,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: index < 3 ? Colors.white : isMe ? Colors.white : AppTheme.textPrimary,
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
                                isMe ? '${member.name} (You)' : member.name,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${member.streak} Day Streak',
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${member.weeklyXp} XP',
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
