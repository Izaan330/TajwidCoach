import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/recording_model.dart';
import '../../services/recording_service.dart';
import 'ijazah_editor_screen.dart';
import 'package:just_audio/just_audio.dart';

class StudentProfileScreen extends StatelessWidget {
  final UserModel student;
  
  const StudentProfileScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium),
            color: AppTheme.accentAmber,
            tooltip: 'Issue Ijazah',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IjazahEditorScreen(student: student),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 32),
            _buildStatsRow(),
            const SizedBox(height: 32),
            const Text(
              'Recitation History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecordingHistory(),
            const SizedBox(height: 100), // padding for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => IjazahEditorScreen(student: student),
            ),
          );
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.workspace_premium, color: Colors.white),
        label: const Text('Issue Ijazah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.1),
            backgroundImage: student.photoUrl != null ? NetworkImage(student.photoUrl!) : null,
            child: student.photoUrl == null 
                ? const Icon(Icons.person, size: 50, color: AppTheme.accentAmber)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            student.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            student.email ?? 'No email provided',
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Current Streak',
            value: '${student.streakDays}',
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Unlocked Badges',
            value: '${student.badges.length}',
            icon: Icons.shield,
            iconColor: AppTheme.accentAmber,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingHistory() {
    final RecordingService recordingService = RecordingService();
    
    return StreamBuilder<List<RecordingModel>>(
      stream: recordingService.getStudentHistory(student.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error loading history: ${snapshot.error}'));
        }
        
        final recordings = snapshot.data ?? [];
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
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
                      : (recording.sheikhFeedback != null 
                          ? Colors.orange.withValues(alpha: 0.1) 
                          : Colors.grey.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recording.sheikhApproved 
                      ? 'Approved' 
                      : (recording.sheikhFeedback != null ? 'Reviewed' : 'Pending'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: recording.sheikhApproved 
                        ? Colors.green 
                        : (recording.sheikhFeedback != null ? Colors.orange : Colors.grey),
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
            if (recording.sheikhFeedback != null) ...[
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
                    const Text('Your Feedback', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                    const SizedBox(height: 4),
                    Text(recording.sheikhFeedback!, style: const TextStyle(fontSize: 14)),
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
