import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/sheikh_model.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sheikh_provider.dart';
import '../../services/recording_service.dart';
import '../../models/recording_model.dart';
import '../../providers/premium_provider.dart';
import 'ijazah_certificate_screen.dart';
import '../../models/ijazah_model.dart';

class SheikhProfileScreen extends StatefulWidget {
  final SheikhModel sheikh;

  const SheikhProfileScreen({super.key, required this.sheikh});

  @override
  State<SheikhProfileScreen> createState() => _SheikhProfileScreenState();
}

class _SheikhProfileScreenState extends State<SheikhProfileScreen> {
  bool _isEnrolling = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isAssigned = user?.sheikhId == widget.sheikh.id;
    final premium = context.watch<PremiumProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.greenGradient,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          widget.sheikh.name
                              .split(' ')
                              .map((w) => w[0])
                              .take(2)
                              .join(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.sheikh.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.sheikh.englishName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat(Icons.star_rounded, widget.sheikh.rating.toStringAsFixed(1), 'Rating', AppTheme.accentAmber),
                        _div(),
                        _Stat(Icons.people_rounded, '${widget.sheikh.totalStudents}', 'Students', AppTheme.primaryGreen),
                        _div(),
                        _Stat(Icons.location_on_rounded, widget.sheikh.city, 'City', AppTheme.qalqalahRed),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // About
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.sheikh.bio,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Masjid
                  _InfoRow(Icons.location_on_rounded, widget.sheikh.masjid, 'Masjid'),
                  const SizedBox(height: 8),
                  _InfoRow(
                    Icons.people_rounded,
                    '${widget.sheikh.currentStudents}/${widget.sheikh.groupClassSize} students enrolled',
                    'Capacity',
                  ),
                  const SizedBox(height: 16),

                  // Specializations
                  const Text(
                    'Specializations',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.sheikh.specializations
                        .map(
                          (spec) => Chip(
                            label: Text(spec),
                            backgroundColor: AppTheme.primaryGreen.withValues(
                              alpha: 0.1,
                            ),
                            labelStyle: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // Group class info
                  if (widget.sheikh.offersGroupClasses)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.idghamBlueBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.groups_rounded, size: 28, color: AppTheme.idghamBlue),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Group Classes Available',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.idghamBlue,
                                ),
                              ),
                              Text(
                                'Max ${widget.sheikh.groupClassSize} students per session',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Ijazah CTA
                  StreamBuilder<List<IjazahCertificate>>(
                    stream: context.read<SheikhProvider>().getStudentCertificates(auth.user?.uid ?? ''),
                    builder: (context, snapshot) {
                      final hasIjazah = snapshot.hasData && 
                          snapshot.data!.any((c) => c.sheikhId == widget.sheikh.id);
                      final IjazahCertificate? certificate = hasIjazah 
                          ? snapshot.data!.firstWhere((c) => c.sheikhId == widget.sheikh.id)
                          : null;

                      return GestureDetector(
                        onTap: () {
                          if (hasIjazah) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => IjazahCertificateScreen(certificate: certificate!),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('You haven\'t earned an Ijazah from this Sheikh yet.')),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: hasIjazah 
                                ? const [Color(0xFF6A1B9A), Color(0xFF4527A0)]
                                : [Colors.grey.shade400, Colors.grey.shade600],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: hasIjazah ? [
                              BoxShadow(
                                color: const Color(0xFF6A1B9A).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ] : null,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.workspace_premium_rounded, size: 28, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasIjazah ? 'View My Ijazah' : 'Digital Ijazah Certificate',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      hasIjazah ? 'Issued on ${certificate!.issuedDate.toString().split(' ')[0]}' : 'Earn your Ijazah with this Sheikh',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white70,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 24),

                  // Enroll/Book button
                  Row(
                    children: [
                      if (isAssigned)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.message_rounded),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Message'),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Messaging feature coming soon!')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppTheme.primaryGreen),
                              foregroundColor: AppTheme.primaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      if (isAssigned) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (widget.sheikh.isAvailable && !isAssigned && !_isEnrolling)
                              ? _enroll
                              : (isAssigned ? null : null),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: isAssigned ? AppTheme.primaryGreen.withValues(alpha: 0.1) : null,
                            foregroundColor: isAssigned ? AppTheme.primaryGreen : null,
                            elevation: isAssigned ? 0 : null,
                          ),
                          child: _isEnrolling
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    isAssigned
                                        ? 'Active Mentor'
                                        : (widget.sheikh.isAvailable
                                            ? (premium.isPremium
                                                ? 'Enroll — ₹${premium.getEffectiveSessionPrice(widget.sheikh.pricePerSession)} (15% Premium Discount)'
                                                : 'Enroll — ₹${widget.sheikh.pricePerSession}')
                                            : 'Currently Unavailable'),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  if (isAssigned) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'My Recitations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecordingHistory(auth.user!.uid),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingHistory(String userId) {
    final RecordingService recordingService = RecordingService();
    
    return StreamBuilder<List<RecordingModel>>(
      stream: recordingService.getStudentHistory(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error loading history: ${snapshot.error}'));
        }
        
        final allRecordings = snapshot.data ?? [];
        final recordings = allRecordings.where((r) => r.sheikhId == widget.sheikh.id).toList();
        
        if (recordings.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No recitation history found.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recordings.length,
          itemBuilder: (context, index) {
            final recording = recordings[index];
            return _HistoryCard(recording: recording);
          },
        );
      },
    );
  }

  Future<void> _enroll() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to enroll')),
      );
      return;
    }

    final premium = context.read<PremiumProvider>();
    final sheikhProvider = context.read<SheikhProvider>();
    final effectivePrice = premium.getEffectiveSessionPrice(widget.sheikh.pricePerSession);

    final enrollSuccess = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EnrollmentPaymentDialog(
        sheikh: widget.sheikh,
        effectivePrice: effectivePrice,
      ),
    );

    if (enrollSuccess == true) {
      setState(() => _isEnrolling = true);

      try {
        await sheikhProvider.enrollWithSheikh(
              auth.user!.uid,
              widget.sheikh.id,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully enrolled with ${widget.sheikh.name}!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Enrollment failed: $e')),
          );
        }
      }

      if (mounted) {
        setState(() => _isEnrolling = false);
      }
    }
  }

  Widget _div() => Container(width: 1, height: 40, color: AppTheme.divider);
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  const _Stat(this.icon, this.value, this.label, this.iconColor);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String label;
  const _InfoRow(this.icon, this.text, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final RecordingModel recording;

  const _HistoryCard({required this.recording});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Surah ${recording.surahName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: recording.sheikhApproved 
                      ? Colors.green.withValues(alpha: 0.1) 
                      : ((recording.sheikhFeedback != null || recording.sheikhFeedbackAudioUrl != null)
                          ? Colors.orange.withValues(alpha: 0.1) 
                          : Colors.grey.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recording.sheikhApproved 
                      ? 'Approved' 
                      : ((recording.sheikhFeedback != null || recording.sheikhFeedbackAudioUrl != null) ? 'Reviewed' : 'Pending'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: recording.sheikhApproved 
                        ? Colors.green 
                        : ((recording.sheikhFeedback != null || recording.sheikhFeedbackAudioUrl != null) ? Colors.orange : Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Ayah ${recording.ayahReference}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _AudioPlayerWidget(audioUrl: recording.audioUrl ?? ''),
            if (recording.sheikhFeedback != null || recording.sheikhFeedbackAudioUrl != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCream,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sheikh Feedback', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                    const SizedBox(height: 4),
                    if (recording.sheikhFeedback != null && recording.sheikhFeedback!.isNotEmpty) ...[
                      Text(recording.sheikhFeedback!, style: const TextStyle(fontSize: 14)),
                      if (recording.sheikhFeedbackAudioUrl != null) const SizedBox(height: 8),
                    ],
                    if (recording.sheikhFeedbackAudioUrl != null)
                      _AudioPlayerWidget(audioUrl: recording.sheikhFeedbackAudioUrl!),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _timeAgo(recording.timestamp),
                style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class _AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  const _AudioPlayerWidget({required this.audioUrl});

  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });
    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.playerStateStream.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
    _init();
  }

  @override
  void didUpdateWidget(covariant _AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _init();
    }
  }

  Future<void> _init() async {
    if (widget.audioUrl.isEmpty) return;
    try {
      if (widget.audioUrl.startsWith('/') || widget.audioUrl.startsWith('file:///')) {
        await _player.setFilePath(widget.audioUrl.replaceFirst('file://', ''));
      } else {
        await _player.setUrl(widget.audioUrl);
      }
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.divider.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: AppTheme.primaryGreen,
              size: 32,
            ),
            onPressed: () {
              if (widget.audioUrl.isEmpty) return;
              if (_isPlaying) {
                _player.pause();
              } else {
                _player.play();
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 2,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: AppTheme.primaryGreen,
                    inactiveTrackColor: AppTheme.divider,
                    thumbColor: AppTheme.primaryGreen,
                  ),
                  child: Slider(
                    value: _position.inMilliseconds.toDouble(),
                    max: _duration.inMilliseconds.toDouble() > 0 
                      ? _duration.inMilliseconds.toDouble() 
                      : 1.0,
                    onChanged: (value) {
                      _player.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
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

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}

class _EnrollmentPaymentDialog extends StatefulWidget {
  final SheikhModel sheikh;
  final int effectivePrice;

  const _EnrollmentPaymentDialog({
    required this.sheikh,
    required this.effectivePrice,
  });

  @override
  State<_EnrollmentPaymentDialog> createState() => _EnrollmentPaymentDialogState();
}

class _EnrollmentPaymentDialogState extends State<_EnrollmentPaymentDialog> {
  bool _processing = false;
  String _statusText = '';

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();
    final hasEnoughCredits = premium.sheikhCredits >= widget.effectivePrice;
    final remainingAmount = widget.effectivePrice - premium.sheikhCredits;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.payment_rounded, color: AppTheme.primaryGreen),
          SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Secure Checkout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enrolling with:',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sheikh.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      widget.sheikh.englishName,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Session Price:'),
                Text('₹${widget.sheikh.pricePerSession}'),
              ],
            ),
            if (premium.isPremium) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Premium Discount (15%):', style: TextStyle(color: Colors.green)),
                  Text('-₹${widget.sheikh.pricePerSession - widget.effectivePrice}', style: const TextStyle(color: Colors.green)),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '₹${widget.effectivePrice}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Credits Balance:'),
                Text(
                  '₹${premium.sheikhCredits}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasEnoughCredits ? AppTheme.primaryGreen : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_processing) ...[
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppTheme.primaryGreen),
                    const SizedBox(height: 12),
                    Text(
                      _statusText,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ] else if (hasEnoughCredits) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have sufficient credits! Tap below to complete your enrollment.',
                        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Insufficient credits (₹$remainingAmount due). Please purchase a package via Google Play Billing:',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.red),
              ),
              const SizedBox(height: 12),
              _buildCreditPackageRow(
                context,
                premium,
                title: '₹100 Credits',
                price: '₹100',
                planId: 'credits_100',
              ),
              const SizedBox(height: 8),
              _buildCreditPackageRow(
                context,
                premium,
                title: '₹500 Credits',
                price: '₹500',
                planId: 'credits_500',
              ),
              const SizedBox(height: 8),
              _buildCreditPackageRow(
                context,
                premium,
                title: '₹1000 Credits',
                price: '₹1000',
                planId: 'credits_1000',
              ),
            ],
          ],
        ),
      ),
      actions: _processing
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              if (hasEnoughCredits)
                ElevatedButton(
                  onPressed: () => _payWithCredits(premium),
                  child: const Text('Pay with Credits'),
                ),
            ],
    );
  }

  Widget _buildCreditPackageRow(
    BuildContext context,
    PremiumProvider premium, {
    required String title,
    required String price,
    required String planId,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.divider.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Google Play Consumable',
                  style: TextStyle(fontSize: 9, color: AppTheme.textHint),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _purchaseCredits(premium, planId),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Buy $price',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseCredits(PremiumProvider premium, String planId) async {
    setState(() {
      _processing = true;
      _statusText = 'Initializing Google Play purchase...';
    });

    try {
      await premium.purchasePlan(planId);
      if (mounted) {
        setState(() {
          _processing = false;
          _statusText = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _processing = false;
          _statusText = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
  }

  Future<void> _payWithCredits(PremiumProvider premium) async {
    setState(() {
      _processing = true;
      _statusText = 'Deducting credits...';
    });

    await Future.delayed(const Duration(milliseconds: 800));
    final success = await premium.useSheikhCredits(widget.effectivePrice);
    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      setState(() {
        _processing = false;
        _statusText = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to deduct credits. Please try again.')),
      );
    }
  }
}

