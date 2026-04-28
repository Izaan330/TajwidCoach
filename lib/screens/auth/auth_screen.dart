import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  bool _codeSent = false;

  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _submit() async {
    HapticFeedback.mediumImpact();
    final auth = context.read<AuthProvider>();

    if (_codeSent) {
      await auth.signInWithSmsCode(_smsController.text.trim());
    } else {
      await auth.verifyPhoneNumber(_phoneController.text.trim());
      if (auth.error == null && mounted) {
        // Animate transition to OTP view
        _fadeController.reset();
        _slideController.reset();
        setState(() => _codeSent = true);
        _fadeController.forward();
        _slideController.forward();
      }
    }

    if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error!),
        backgroundColor: AppTheme.qalqalahRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // ─── Background ────────────────────────────────────────────────
          const Positioned.fill(child: _AuthBackground()),

          // ─── Scrollable Content ────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 32),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ─── Logo ─────────────────────────────────────
                        _buildLogo(),
                        const SizedBox(height: 48),

                        // ─── Glassmorphic Card ─────────────────────────
                        _buildFormCard(auth),

                        const SizedBox(height: 24),

                        // ─── Footer note ───────────────────────────────
                        const Text(
                          'By continuing, you agree to our Terms & Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textHint,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Logo container with glassmorphism
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF004D40), Color(0xFF00251A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppTheme.primaryGreen.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text('🌙', style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'TajwidCoach',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'MASTER THE ART OF RECITATION',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 2.5,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Bismillah
        const Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.premiumGold,
            fontFamily: 'AmiriQuran',
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildFormCard(AuthProvider auth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.backgroundSurface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Column(
                  key: ValueKey(_codeSent),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _codeSent
                          ? 'Verify your number'
                          : 'Sign in with Phone',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _codeSent
                          ? 'Enter the 6-digit code sent to your phone'
                          : 'We\'ll send you a verification code',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Field
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _codeSent
                    ? _buildOTPField()
                    : _buildPhoneField(),
              ),

              const SizedBox(height: 24),

              // CTA Button
              _buildSubmitButton(auth),

              // Back to phone
              if (_codeSent) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      _fadeController.reset();
                      _slideController.reset();
                      setState(() => _codeSent = false);
                      _fadeController.forward();
                      _slideController.forward();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14),
                    label: const Text('Change Phone Number'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '+1 234 567 8901',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.phone_rounded,
                  color: AppTheme.primaryGreen, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPField() {
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Code',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _smsController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.primaryGreen,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 12,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 28,
              letterSpacing: 12,
            ),
            counterText: '',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.message_rounded,
                  color: AppTheme.primaryGreen, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: auth.isLoading
              ? null
              : AppTheme.greenGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: auth.isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: auth.isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: auth.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.primaryGreen,
                  ),
                )
              : Text(
                  _codeSent ? 'Verify Code ✓' : 'Send Code →',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Background
// ─────────────────────────────────────────────────────────────────────────────
class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF004D40),
            Color(0xFF080E1A),
            Color(0xFF00251A),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(painter: _IslamicPatternPainter()),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 80.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawStar(canvas, Offset(x, y), 18, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    path.addRect(Rect.fromCircle(center: center, radius: r * 0.7));
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.785398);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(path, paint);
    canvas.restore();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
