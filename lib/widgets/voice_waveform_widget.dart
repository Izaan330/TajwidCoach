import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum WaveformState { idle, recording, analyzing }

class VoiceWaveformWidget extends StatefulWidget {
  final WaveformState state;
  final int recordingSeconds;
  final VoidCallback? onTap;

  const VoiceWaveformWidget({
    super.key,
    required this.state,
    this.recordingSeconds = 0,
    this.onTap,
  });

  @override
  State<VoiceWaveformWidget> createState() => _VoiceWaveformWidgetState();
}

class _VoiceWaveformWidgetState extends State<VoiceWaveformWidget>
    with TickerProviderStateMixin {
  static const int _barCount = 28;
  static const double _barWidth = 4.0;
  static const double _barSpacing = 3.0;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  late AnimationController _spinController;

  final List<double> _barHeights = List.filled(_barCount, 20.0);
  Timer? _barTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Idle pulse controllers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Analyze spin controller
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _updateTimers(widget.state);
  }

  @override
  void didUpdateWidget(VoiceWaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateTimers(widget.state);
    }
  }

  void _updateTimers(WaveformState state) {
    if (state == WaveformState.recording) {
      _barTimer?.cancel();
      _barTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
        if (mounted) {
          setState(() {
            for (int i = 0; i < _barCount; i++) {
              // Create a wave-like pattern: center bars taller
              final centerDistance = (i - _barCount / 2).abs() / (_barCount / 2);
              final maxHeight = 60.0 * (1.0 - centerDistance * 0.4);
              _barHeights[i] = 8.0 + _random.nextDouble() * maxHeight;
            }
          });
        }
      });
    } else {
      _barTimer?.cancel();
      if (mounted) {
        setState(() {
          for (int i = 0; i < _barCount; i++) {
            _barHeights[i] = 20.0;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _barTimer?.cancel();
    _pulseController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.state) {
      case WaveformState.idle:
        return _buildIdleState();
      case WaveformState.recording:
        return _buildRecordingState();
      case WaveformState.analyzing:
        return _buildAnalyzingState();
    }
  }

  Widget _buildIdleState() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulse ring
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            return Transform.scale(
              scale: _pulseScale.value,
              child: Opacity(
                opacity: _pulseOpacity.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryGreen,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Inner pulse ring
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            return Transform.scale(
              scale: 1.0 + (_pulseScale.value - 1.0) * 0.5,
              child: Opacity(
                opacity: _pulseOpacity.value * 0.5,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Core mic button
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: AppTheme.greenGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.45),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.mic_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Waveform bars
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_barCount, (index) {
              final t = index / (_barCount - 1);
              // Gradient from teal at edges to bright green at center
              final color = Color.lerp(
                const Color(0xFF1DE9B6),
                AppTheme.primaryGreen,
                (1.0 - (t - 0.5).abs() * 2.0).clamp(0.0, 1.0),
              )!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: _barSpacing / 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width: _barWidth,
                  height: _barHeights[index],
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        // Stop button
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.stop_rounded, color: Colors.white, size: 32),
        ),
      ],
    );
  }

  Widget _buildAnalyzingState() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Spinning gradient arc
        RotationTransition(
          turns: _spinController,
          child: const SizedBox(
            width: 110,
            height: 110,
            child: CircularProgressIndicator(
              value: null,
              strokeWidth: 3.5,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryGreen,
              ),
            ),
          ),
        ),
        // Glow backing
        AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Opacity(
            opacity: _pulseOpacity.value,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withValues(alpha: 0.06),
              ),
            ),
          ),
        ),
        // Center icon + label
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.primaryGreen,
              size: 28,
            ),
            SizedBox(height: 4),
            Text(
              'AI',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
