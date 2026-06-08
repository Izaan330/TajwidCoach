import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/ijazah_model.dart';
import '../../services/pdf_service.dart';
import 'package:printing/printing.dart';

class IjazahCertificateScreen extends StatelessWidget {
  final IjazahCertificate certificate;

  const IjazahCertificateScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Ijazah Certificate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () async {
              final pdfBytes = await PdfService.generateIjazahPdf(certificate);
              await Printing.sharePdf(
                bytes: pdfBytes,
                filename: 'Ijazah_${certificate.studentName.replaceAll(' ', '_')}.pdf',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Certificate Card
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFB8860B), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentAmber.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(17),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '☪',
                          style: TextStyle(fontSize: 36, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Certificate of Ijazah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'شهادة الإجازة',
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'AmiriQuran',
                            fontSize: 18,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'This is to certify that',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          certificate.studentName,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.premiumGoldLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'has successfully completed recitation of\nthe Holy Quran with correct Tajwid',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  AppTheme.primaryGreen.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'According to the narration of',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                certificate.attestation,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Sheikh Signature
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Issued by',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  certificate.sheikhName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  certificate.masjid,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Date',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${certificate.issuedDate.day}/${certificate.issuedDate.month}/${certificate.issuedDate.year}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stamp area
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryGreen,
                              width: 2,
                            ),
                            color:
                                AppTheme.primaryGreen.withValues(alpha: 0.05),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                '☪',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              Text(
                                'Quran Pro',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dua
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Text(
                    '"The best among you are those who learn the Quran and teach it."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '— Sahih Al-Bukhari',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share PDF'),
                    onPressed: () async {
                      final pdfBytes = await PdfService.generateIjazahPdf(certificate);
                      await Printing.sharePdf(
                        bytes: pdfBytes,
                        filename: 'Ijazah_${certificate.studentName.replaceAll(' ', '_')}.pdf',
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

