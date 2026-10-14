import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:freelancer_business_os/models/client.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/models/project.dart';

import 'package:web/web.dart' as web; 

class InvoicePdfService {
  static Future<void> compileAndDownloadInvoicePdf({
    required Invoice invoice,
    required Project? project,
    required Client? client,
    required String currencySymbol,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final totalCash = (invoice.totalAmountInCents / 100).toStringAsFixed(2);
          final issueDateStr = "${invoice.createdDate.day}/${invoice.createdDate.month}/${invoice.createdDate.year}";

          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('FREELANCER BUSINESS OS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('INVOICE RECEIPT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 24),

                pw.Text('Invoice ID: INV-${invoice.id.substring(0, 6).toUpperCase()}', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('Issue Date Calendar: $issueDateStr', style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 14),
                pw.Text('AGGREGATE AMOUNT DUE:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text('$currencySymbol$totalCash', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 32),

                pw.Text('CLIENT RECIPIENT METADATA:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('Name Identifier: ${client?.name ?? "Corporate Partner"}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Company Business Name: ${client?.companyName ?? "Independent Workspace"}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Communication Email Channel: ${client?.email ?? "billing@corporate.com"}', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 32),

                pw.Text('BILLABLE LINE ITEMS HISTORY SUMMARY:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Description Overview Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text('Total Gross Billing Ledger', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(project?.projectName ?? 'Core System Consulting Engagement', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('$currencySymbol$totalCash', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    final Uint8List pdfBytesBytesBuffer = await pdf.save();

    // 🌟 SECURE MODERN WEB PREVIEW DOWNLOAD INJECTION
    if (kIsWeb) {
      final blobDataFileBlob = web.Blob(
        [pdfBytesBytesBuffer.toJS].toJS,
        web.BlobPropertyBag(type: 'application/pdf'),
      );
      final stringLinkUrlToken = web.URL.createObjectURL(blobDataFileBlob);

      // Spawn an anchor link onto the browser document window natively
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = stringLinkUrlToken;
      anchor.download = "Invoice_INV-${invoice.id.substring(0, 6).toUpperCase()}.pdf";
      
      web.document.body?.appendChild(anchor);
      anchor.click();
      
      // Cleanup DOM node memory blocks
      web.document.body?.removeChild(anchor);
      web.URL.revokeObjectURL(stringLinkUrlToken);
    } else {
      debugPrint('Mobile storage document stream pipeline targeted.');
    }
  }
}
