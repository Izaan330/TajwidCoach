import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sheikh_model.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sheikh_provider.dart';
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hasIjazah ? 'View My Ijazah' : 'Digital Ijazah Certificate',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    hasIjazah ? 'Issued on ${certificate!.issuedDate.toString().split(' ')[0]}' : 'Earn your Ijazah with this Sheikh',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
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
                            label: const Text('Message'),
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
                        flex: 2,
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
                              : Text(
                                  isAssigned
                                      ? 'Active Mentor'
                                      : (widget.sheikh.isAvailable
                                          ? 'Enroll — ₹${widget.sheikh.pricePerSession}'
                                          : 'Currently Unavailable'),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
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

    setState(() => _isEnrolling = true);

    try {
      await context.read<SheikhProvider>().enrollWithSheikh(
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

