import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/ijazah_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  /// Generates a PDF document for an Ijazah Certificate.
  static Future<Uint8List> generateIjazahPdf(IjazahCertificate certificate) async {
    final pdf = pw.Document();

    // Use a standard font for now. In a real app, load Arabic TTF fonts if needed.
    final font = await PdfGoogleFonts.cairoSemiBold();
    final fontRegular = await PdfGoogleFonts.cairoRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.teal800,
                width: 6,
              ),
            ),
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'CERTIFICATE OF IJAZAH',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 32,
                      color: PdfColors.teal900,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'In the Name of Allah, the Most Gracious, the Most Merciful',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 14,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'This is to certify that',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 18,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    certificate.studentName,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 36,
                      color: PdfColors.teal800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    'has successfully completed the recitation of the Holy Quran in the Riwayah of:',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 16,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    certificate.attestation,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 24,
                      color: PdfColors.purple800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Text(
                      'Verified at ${certificate.masjid}',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 14,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text(
                            DateFormat('MMMM d, yyyy').format(certificate.issuedDate),
                            style: pw.TextStyle(font: font, fontSize: 16),
                          ),
                          pw.Container(width: 150, height: 1, color: PdfColors.black),
                          pw.SizedBox(height: 5),
                          pw.Text('Date of Issue', style: pw.TextStyle(font: fontRegular, fontSize: 12)),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(
                            certificate.sheikhName,
                            style: pw.TextStyle(font: font, fontSize: 16),
                          ),
                          pw.Container(width: 150, height: 1, color: PdfColors.black),
                          pw.SizedBox(height: 5),
                          pw.Text('Certifying Sheikh', style: pw.TextStyle(font: fontRegular, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'Certificate ID: ${certificate.id}',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
