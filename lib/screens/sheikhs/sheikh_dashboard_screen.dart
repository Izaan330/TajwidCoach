import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../theme/app_theme.dart';
import '../../providers/sheikh_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/recording_model.dart';
import 'student_profile_screen.dart';
import '../../models/sheikh_model.dart';

class SheikhDashboardScreen extends StatefulWidget {
  const SheikhDashboardScreen({super.key});

  @override
  State<SheikhDashboardScreen> createState() => _SheikhDashboardScreenState();
}

class _SheikhDashboardScreenState extends State<SheikhDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<SheikhProvider>().listenToPendingReviews(auth.user!.uid);
        context.read<SheikhProvider>().listenToMyStudents(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sheikhProvider = context.watch<SheikhProvider>();
    final currentSheikh = sheikhProvider.currentSheikh;
    final pendingCount = sheikhProvider.pendingReviews.length;
    final studentCount = sheikhProvider.myStudentUids.length;

    final isPro = currentSheikh?.tier == SheikhTier.pro || currentSheikh?.tier == SheikhTier.madrasa;

    return DefaultTabController(
      length: isPro ? 3 : 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundCream,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundDark,
          toolbarHeight: 64,
          centerTitle: false,
          elevation: 0,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Sheikh Dashboard',
              style: GoogleFonts.outfit(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ),
          actions: [
            if (currentSheikh != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentSheikh.isAvailable ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: currentSheikh.isAvailable
                          ? AppTheme.primaryGreen
                          : AppTheme.textHint,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: currentSheikh.isAvailable,
                      activeThumbColor: AppTheme.primaryGreen,
                      activeTrackColor:
                          AppTheme.primaryGreen.withValues(alpha: 0.3),
                      onChanged: (val) {
                        sheikhProvider.toggleAvailability(
                            currentSheikh.id, val);
                      },
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'logout') {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign Out'),
                        content:
                            const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AuthProvider>().signOut();
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Sign Out', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _StatItem(
                        label: 'Pending',
                        value: '$pendingCount',
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _StatItem(
                        label: 'Students',
                        value: '$studentCount',
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 12),
                      const _StatItem(
                        label: 'Earnings',
                        value: '₹0',
                        color: AppTheme.accentAmber,
                      ),
                    ],
                  ),
                ),
                TabBar(
                  labelColor: AppTheme.primaryGreen,
                  unselectedLabelColor: AppTheme.textHint,
                  indicatorColor: AppTheme.primaryGreen,
                  tabs: [
                    const Tab(text: 'Pending'),
                    const Tab(text: 'Students'),
                    if (isPro) const Tab(text: 'Earnings'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            if (currentSheikh != null && !currentSheikh.isVerified)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.orange.withValues(alpha: 0.1),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Colors.orange, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your profile is under review. You will appear in the search list once verified by our team.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(children: [
                const _PendingReviewsTab(),
                const _MyStudentsTab(),
                if (isPro) const _EarningsTab(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _PendingReviewsTab extends StatelessWidget {
  const _PendingReviewsTab();

  @override
  Widget build(BuildContext context) {
    final sheikhProvider = context.watch<SheikhProvider>();
    final pending = sheikhProvider.pendingReviews;

    if (sheikhProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🙌', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text(
              'All caught up!',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            Text(
              'No pending reviews from students.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final review = pending[index];
        return _ReviewCard(review: review);
      },
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final RecordingModel review;
  const _ReviewCard({required this.review});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          AppTheme.primaryGreen.withValues(alpha: 0.1),
                      child: const Icon(Icons.person,
                          color: AppTheme.primaryGreen),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Surah ${widget.review.surahName}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Ayah ${widget.review.ayahReference}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  _timeAgo(widget.review.timestamp),
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.textHint),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AudioPlayerWidget(audioUrl: widget.review.audioUrl ?? ''),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                hintText: 'Add your feedback here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _submit(false),
                    style:
                        OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Needs Work'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _submit(true),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit(bool approved) async {
    if (_feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add feedback first')),
      );
      return;
    }

    await context.read<SheikhProvider>().submitFeedback(
          widget.review.id,
          _feedbackController.text,
          approved,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approved ? 'Approved!' : 'Feedback sent')),
      );
    }
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
    _init();
  }

  Future<void> _init() async {
    if (widget.audioUrl.isEmpty) return;
    try {
      await _player.setUrl(widget.audioUrl);
      _player.durationStream.listen((d) {
        if (mounted) setState(() => _duration = d ?? Duration.zero);
      });
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _player.playerStateStream.listen((state) {
        if (mounted) setState(() => _isPlaying = state.playing);
      });
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              size: 36,
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
          const SizedBox(width: 12),
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
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textSecondary),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textSecondary),
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

class _MyStudentsTab extends StatelessWidget {
  const _MyStudentsTab();

  @override
  Widget build(BuildContext context) {
    final sheikhProvider = context.watch<SheikhProvider>();
    final students = sheikhProvider.myStudents;

    if (students.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textHint),
            SizedBox(height: 16),
            Text('No students assigned yet.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.1),
              backgroundImage: student.photoUrl != null
                  ? NetworkImage(student.photoUrl!)
                  : null,
              child: student.photoUrl == null
                  ? const Icon(Icons.person, color: AppTheme.accentAmber)
                  : null,
            ),
            title: Text(student.name),
            subtitle: Text('Streak: ${student.streakDays} days'),
            trailing: const Icon(Icons.workspace_premium_rounded,
                color: AppTheme.accentAmber),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentProfileScreen(student: student),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _EarningsTab extends StatelessWidget {
  const _EarningsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.goldAccentGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentAmber.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: Colors.black, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Total Earnings',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  '₹4,250.00',
                  style: GoogleFonts.outfit(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Next Payout: May 15',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Recent Payouts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          const _PayoutItem(date: 'April 30, 2024', amount: '₹1,500', status: 'Completed'),
          const _PayoutItem(date: 'April 15, 2024', amount: '₹2,750', status: 'Completed'),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.help_outline_rounded, size: 16),
              label: const Text('How are earnings calculated?'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.textHint),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutItem extends StatelessWidget {
  final String date;
  final String amount;
  final String status;

  const _PayoutItem({required this.date, required this.amount, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(status, style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
            ],
          ),
          Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
