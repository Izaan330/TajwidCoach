import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/tajwid_rule_model.dart';
import '../../utils/tajwid_rules_data.dart';
import '../../models/recording_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sheikh_provider.dart';
import '../store/paywall_screen.dart';
import '../../services/quran_database_helper.dart';
import '../../models/surah_model.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/tajweed_text.dart';


class AIFeedbackScreen extends StatefulWidget {
  final TajwidAnalysisResult result;
  final String surahName;
  final String ayahRef;
  final String? audioPath;
  final int durationSeconds;

  const AIFeedbackScreen({
    super.key,
    required this.result,
    required this.surahName,
    required this.ayahRef,
    this.audioPath,
    this.durationSeconds = 0,
  });

  @override
  State<AIFeedbackScreen> createState() => _AIFeedbackScreenState();
}

class _AIFeedbackScreenState extends State<AIFeedbackScreen> {
  bool _isSubmitting = false;
  AyahModel? _recitedAyahModel;
  bool _isLoadingRecited = false;
  AyahModel? _expectedAyahModel;
  bool _isLoadingExpected = false;

  @override
  void initState() {
    super.initState();
    _loadExpectedAyah();
    if (widget.result.isMismatch &&
        widget.result.recitedAyah != null &&
        widget.result.recitedAyah != 'Unknown') {
      _loadRecitedAyah();
    }
  }

  Future<void> _loadExpectedAyah() async {
    setState(() => _isLoadingExpected = true);
    try {
      final parts = widget.ayahRef.split(':');
      if (parts.length == 2) {
        final surahNum = int.tryParse(parts[0]);
        final ayahNum = int.tryParse(parts[1]);
        if (surahNum != null && ayahNum != null) {
          final model = await QuranDatabaseHelper.instance.getAyah(surahNum, ayahNum);
          if (mounted) {
            setState(() {
              _expectedAyahModel = model;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading expected ayah: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingExpected = false);
      }
    }
  }

  Future<void> _loadRecitedAyah() async {
    setState(() => _isLoadingRecited = true);
    try {
      final parts = widget.result.recitedAyah!.split(':');
      if (parts.length == 2) {
        final surahNum = int.tryParse(parts[0]);
        final ayahNum = int.tryParse(parts[1]);
        if (surahNum != null && ayahNum != null) {
          final model = await QuranDatabaseHelper.instance.getAyah(surahNum, ayahNum);
          if (mounted) {
            setState(() {
              _recitedAyahModel = model;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading recited ayah: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingRecited = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('AI Feedback'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Done'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.result.isMismatch) ...[
              _MismatchCard(
                result: widget.result,
                expectedAyahRef: widget.ayahRef,
                expectedAyahModel: _expectedAyahModel,
                isLoadingExpected: _isLoadingExpected,
                recitedAyahModel: _recitedAyahModel,
                isLoadingRecited: _isLoadingRecited,
                onTryAgain: () => Navigator.of(context).pop(),
                onSwitchAyah: (surahNum, ayahNum) {
                  Navigator.of(context).pop({
                    'action': 'switch_ayah',
                    'surahNumber': surahNum,
                    'ayahNumber': ayahNum,
                  });
                },
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Score Card
              _ScoreCard(result: widget.result, ayahRef: widget.ayahRef),
              const SizedBox(height: 16),

              // Encouragement
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppTheme.accentAmber, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.result.encouragement,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weak Words
              if (widget.result.weakWords.isNotEmpty) ...[
                _buildSectionTitle('Words Needing Attention', icon: Icons.error_rounded, color: AppTheme.qalqalahRed),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.qalqalahRedBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.result.weakWords
                        .map(
                          (word) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.cardWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.qalqalahRed.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              word,
                              style: const TextStyle(
                                fontFamily: 'AmiriQuran',
                                fontSize: 20,
                                color: AppTheme.qalqalahRed,
                                fontWeight: FontWeight.w600,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Rule Breakdown
              _buildSectionTitle('Tajwid Rule Breakdown', icon: Icons.bar_chart_rounded, color: AppTheme.primaryGreen),
              ...widget.result.ruleScores.map((rs) => _RuleScoreCard(ruleScore: rs)),
              
              if (widget.result.lockedRulesCount > 0) ...[
                const SizedBox(height: 12),
                _LockedRulesBanner(count: widget.result.lockedRulesCount),
              ],
              
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Next Ayah'),
                      onPressed: () =>
                          Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sheikh assessment CTA
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF4527A0)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Get Sheikh Feedback',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            user?.sheikhId != null
                                ? 'Send to your assigned Sheikh'
                                : 'Select a certified Sheikh for review',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : TextButton(
                            onPressed: _submitToSheikh,
                            child: Text(
                              user?.sheikhId != null ? 'Send' : 'Browse',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Note: Our AI analysis is a supporting tool and is continuously improving. For definitive feedback, we recommend submitting your recitation for Sheikh review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitToSheikh() async {
    final auth = context.read<AuthProvider>();
    final sheikhProvider = context.read<SheikhProvider>();
    final user = auth.user;

    if (user?.sheikhId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign a Sheikh first from the Sheikhs tab.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final recording = RecordingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user!.uid,
        ayahReference: widget.ayahRef.split('(').last.replaceAll(')', ''),
        surahName: widget.surahName,
        tajwidScore: widget.result.overallScore,
        weakWords: widget.result.weakWords,
        weakRuleIds: widget.result.weakRuleIds,
        audioLocalPath: widget.audioPath,
        timestamp: DateTime.now(),
        sheikhId: user.sheikhId,
        durationSeconds: widget.durationSeconds,
      );

      await sheikhProvider.submitRequest(recording);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording sent to your Sheikh!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }

  Widget _buildSectionTitle(String title, {IconData? icon, Color? color}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: color ?? AppTheme.textPrimary, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final TajwidAnalysisResult result;
  final String ayahRef;

  const _ScoreCard({required this.result, required this.ayahRef});

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppTheme.scoreColor(result.overallScore);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), blurRadius: 16),
        ],
      ),
      child: Column(
        children: [
          Text(
            ayahRef,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          // Score circle
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withValues(alpha: 0.12),
              border: Border.all(color: scoreColor, width: 4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FittedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${result.overallScore}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: scoreColor,
                      ),
                    ),
                    Text('%', style: TextStyle(fontSize: 14, color: scoreColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result.grade,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: scoreColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.feedback,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleScoreCard extends StatelessWidget {
  final RuleScore ruleScore;
  const _RuleScoreCard({required this.ruleScore});

  @override
  Widget build(BuildContext context) {
    final rule = TajwidRulesData.findById(ruleScore.ruleId);
    final bgColor = rule != null
        ? Color(int.parse(rule.backgroundHex.replaceFirst('#', '0xFF')))
        : AppTheme.idghamBlueBg;
    final fgColor = rule != null
        ? Color(int.parse(rule.colorHex.replaceFirst('#', '0xFF')))
        : AppTheme.idghamBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ruleScore.isWeak ? AppTheme.qalqalahRedBg : AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ruleScore.ruleName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: fgColor,
                      ),
                    ),
                  ),
                  if (ruleScore.isWeak)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.warning_rounded, color: AppTheme.qalqalahRed, size: 16),
                    ),
                ],
              ),
              Text(
                '${ruleScore.score}%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppTheme.scoreColor(ruleScore.score),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ruleScore.score / 100,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation(
                AppTheme.scoreColor(ruleScore.score),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ruleScore.feedback,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LockedRulesBanner extends StatelessWidget {
  final int count;
  const _LockedRulesBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.premiumGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.premiumGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.lock_rounded, color: AppTheme.premiumGold, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$count more rules detected!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.premiumGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Unlock the full 25-rule AI engine to see feedback on every mistake.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.premiumGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MismatchCard extends StatelessWidget {
  final TajwidAnalysisResult result;
  final String expectedAyahRef;
  final AyahModel? expectedAyahModel;
  final bool isLoadingExpected;
  final AyahModel? recitedAyahModel;
  final bool isLoadingRecited;
  final VoidCallback onTryAgain;
  final Function(int, int) onSwitchAyah;

  const _MismatchCard({
    required this.result,
    required this.expectedAyahRef,
    this.expectedAyahModel,
    required this.isLoadingExpected,
    required this.recitedAyahModel,
    required this.isLoadingRecited,
    required this.onTryAgain,
    required this.onSwitchAyah,
  });

  @override
  Widget build(BuildContext context) {
    // Extract transcription from feedback
    final cleanTranscription = result.feedback
        .replaceFirst("Transcription: '", "")
        .replaceFirst("' (mismatch)", "");

    final defaultFont = context.read<SettingsProvider>().defaultFontFamily;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentAmber.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentAmber.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentAmber.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.accentAmber,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ayah Mismatch Detected',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Our AI analysis detected that you recited a different verse than the one selected. Please make sure you recite the correct verse.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 20),

          // Expected Verse Details
          if (isLoadingExpected) ...[
            const CircularProgressIndicator(color: AppTheme.primaryGreen),
            const SizedBox(height: 20),
          ] else if (expectedAyahModel != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Expected Verse (Selected):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentAmber.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentAmber.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Surah $expectedAyahRef',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentAmber,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TajweedText(
                    text: expectedAyahModel!.arabicText,
                    tajweedTagText: expectedAyahModel!.tajweedText,
                    fontSize: 18,
                    fontFamily: defaultFont,
                    lineHeight: 1.8,
                    showTajweed: true,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Transcription heard details
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'What We Heard:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundCream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider, width: 1),
            ),
            child: Text(
              cleanTranscription,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'AmiriQuran',
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          ),
          
          if (isLoadingRecited) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppTheme.primaryGreen),
          ] else if (recitedAyahModel != null) ...[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Identified Verse:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Surah ${recitedAyahModel!.surahNumber}:${recitedAyahModel!.ayahNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TajweedText(
                    text: recitedAyahModel!.arabicText,
                    tajweedTagText: recitedAyahModel!.tajweedText,
                    fontSize: 18,
                    fontFamily: defaultFont,
                    lineHeight: 1.8,
                    showTajweed: true,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.swap_horiz_rounded),
              label: Text('Switch to Surah ${recitedAyahModel!.surahNumber}:${recitedAyahModel!.ayahNumber}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => onSwitchAyah(
                recitedAyahModel!.surahNumber,
                recitedAyahModel!.ayahNumber,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Expected Ayah Again'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onTryAgain,
          ),
        ],
      ),
    );
  }
}


