import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_theme.dart';
import '../../providers/sheikh_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/ijazah_model.dart';
import '../../services/pdf_service.dart';
import 'package:printing/printing.dart';

class IjazahEditorScreen extends StatefulWidget {
  final UserModel student;
  const IjazahEditorScreen({super.key, required this.student});

  @override
  State<IjazahEditorScreen> createState() => _IjazahEditorScreenState();
}

class _IjazahEditorScreenState extends State<IjazahEditorScreen> {
  final _attestationController = TextEditingController();
  final _riwayahController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _riwayahController.text = 'Hafs an Asim';
    _attestationController.text = 'The student has successfully completed the recitation of the entire Quran with proper Tajwid rules.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Issue Ijazah'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentInfo(),
            const SizedBox(height: 32),
            _buildEditorField('Riwayah (Narration)', _riwayahController, hint: 'e.g. Hafs an Asim'),
            const SizedBox(height: 24),
            _buildEditorField('Attestation Text', _attestationController, hint: 'Details of completion...', maxLines: 5),
            const SizedBox(height: 40),
            _buildPreviewCard(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Issue Certificate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppTheme.accentAmber, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Text('Active Student', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditorField(String label, TextEditingController controller, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentAmber, width: 2),
      ),
      child: Column(
        children: [
          const Text('IJAZAH CERTIFICATE', style: TextStyle(fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.bold, color: AppTheme.accentAmber)),
          const SizedBox(height: 24),
          const Text('This is to certify that', style: TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          Text(widget.student.name.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 16),
          const Text('Has completed the recitation of the Holy Quran in the Riwayah of:', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(_riwayahController.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                children: [
                  Text('Sheikh Signature'),
                  SizedBox(height: 8),
                  Text('________________', style: TextStyle(color: AppTheme.divider)),
                ],
              ),
              Column(
                children: [
                  const Text('Issued Date'),
                  const SizedBox(height: 8),
                  Text(DateTime.now().toString().split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() async {
    setState(() => _isLoading = true);
    try {
      final sheikh = context.read<AuthProvider>().user;
      if (sheikh == null) return;

      final certificate = IjazahCertificate(
        id: const Uuid().v4(),
        studentId: widget.student.uid,
        studentName: widget.student.name,
        sheikhId: sheikh.uid,
        sheikhName: sheikh.name,
        sheikhSignature: 'signed',
        masjid: sheikh.masjid ?? 'Verified Masjid',
        attestation: _riwayahController.text,
        issuedDate: DateTime.now(),
      );

      await context.read<SheikhProvider>().submitIjazah(certificate);
      
      if (mounted) {
        _showSuccessDialog(certificate);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(IjazahCertificate certificate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ijazah Issued! 📜'),
        content: const Text('The certificate has been successfully recorded. Would you like to share or download the PDF version?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              final pdfBytes = await PdfService.generateIjazahPdf(certificate);
              await Printing.sharePdf(
                bytes: pdfBytes,
                filename: 'Ijazah_${certificate.studentName.replaceAll(' ', '_')}.pdf',
              );
            },
            child: const Text('Share PDF'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _attestationController.dispose();
    _riwayahController.dispose();
    super.dispose();
  }
}
