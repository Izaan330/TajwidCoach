import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _smsController = TextEditingController();
  bool _codeSent = false;
  bool _isEmailAuth = true; // Default to email auth
  bool _isSignUp = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _smsController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _submit() async {
    HapticFeedback.mediumImpact();
    final auth = context.read<AuthProvider>();

    if (_isEmailAuth) {
      if (_isSignUp) {
        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: AppTheme.qalqalahRed,
          ));
          return;
        }
        await auth.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
      } else {
        await auth.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    } else {
      if (_codeSent) {
        await auth.signInWithSmsCode(_smsController.text.trim());
      } else {
        await auth.verifyPhoneNumber(_phoneController.text.trim());
        if (auth.error == null && mounted) {
          _fadeController.reset();
          _slideController.reset();
          setState(() => _codeSent = true);
          _fadeController.forward();
          _slideController.forward();
        }
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

  void _showForgotPasswordDialog() {
    final controller = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Email Address'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = controller.text.trim();
              await context.read<AuthProvider>().sendPasswordResetEmail(email);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Reset link sent! Please check your email.'),
                backgroundColor: AppTheme.primaryGreen,
              ));
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
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
              // ─── Mode Toggle (Phone/Email) ───
              if (!_codeSent) _buildAuthModeToggle(),
              const SizedBox(height: 20),

              // Header
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Column(
                  key: ValueKey('${_codeSent}_${_isEmailAuth}_${_isSignUp}'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _codeSent
                          ? 'Verify your number'
                          : (_isEmailAuth 
                              ? (_isSignUp ? 'Create Account' : 'Welcome Back') 
                              : 'Sign in with Phone'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _codeSent
                          ? 'Enter the 6-digit code sent to your phone'
                          : (_isEmailAuth 
                              ? (_isSignUp ? 'Join the community & master recitation' : 'Log in to continue your progress')
                              : 'We\'ll send you a verification code'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fields
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _codeSent
                    ? _buildOTPField()
                    : (_isEmailAuth ? _buildEmailFields() : _buildPhoneField()),
              ),

              if (_isEmailAuth && !_isSignUp) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text('Forgot Password?',
                        style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 24),
              ],

              // CTA Button
              _buildSubmitButton(auth),

              const SizedBox(height: 16),

              // ─── Switch Login/Signup ───
              if (!_codeSent && _isEmailAuth) _buildSignupToggle(),

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

  Widget _buildAuthModeToggle() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleItem('Email', _isEmailAuth, () => setState(() => _isEmailAuth = true)),
          _buildToggleItem('Phone', !_isEmailAuth, () => setState(() => _isEmailAuth = false)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.black : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupToggle() {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _isSignUp = !_isSignUp),
        child: RichText(
          text: TextSpan(
            text: _isSignUp ? 'Already have an account? ' : 'New to TajwidCoach? ',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            children: [
              TextSpan(
                text: _isSignUp ? 'Sign In' : 'Join Now',
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailFields() {
    return Column(
      key: const ValueKey('email_fields'),
      children: [
        if (_isSignUp) ...[
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Your name',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 16),
        ],
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'you@example.com',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hint: '••••••••',
          icon: Icons.lock_rounded,
          obscureText: !_showPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppTheme.textHint,
              size: 18,
            ),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        ),
        if (_isSignUp) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: '••••••••',
            icon: Icons.lock_clock_rounded,
            obscureText: !_showConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppTheme.textHint,
                size: 18,
              ),
              onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 18),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
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
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: auth.isLoading ? null : AppTheme.greenGradient,
          borderRadius: BorderRadius.circular(16),
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
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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
                  _codeSent ? 'Verify Code ✓' : (_isEmailAuth ? (_isSignUp ? 'Create Account' : 'Sign In') : 'Send Code →'),
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
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
