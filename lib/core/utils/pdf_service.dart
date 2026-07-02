// core/utils — PDF document builders for invoices & financial reports.
// Returns raw bytes consumed by the in-app PdfPreview (view / print / download).
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../state/app_state.dart';
import 'formatters.dart';
import '../../modules/pos_inventory/models/pos_models.dart';

const _gold = PdfColor.fromInt(0xFFC9A24B);
const _ink = PdfColor.fromInt(0xFF1A1C22);
const _muted = PdfColor.fromInt(0xFF6A7080);
const _line = PdfColor.fromInt(0xFFDCDFE6);

/// Premium A4 invoice document.
Future<Uint8List> buildInvoicePdf(Invoice inv) async {
  final doc = pw.Document();
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    build: (context) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header band
        pw.Container(
          padding: const pw.EdgeInsets.all(18),
          decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF0E0E12), borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('HAIR AGAIN', style: pw.TextStyle(color: _gold, fontSize: 26, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
                pw.SizedBox(height: 2),
                pw.Text(appState.clinicName, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                pw.Text(appState.clinicAddress, style: const pw.TextStyle(color: PdfColor.fromInt(0xFF9A9AA6), fontSize: 9)),
                pw.Text('${appState.clinicPhone}  •  ${appState.clinicEmail}', style: const pw.TextStyle(color: PdfColor.fromInt(0xFF9A9AA6), fontSize: 9)),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text('INVOICE', style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(inv.id, style: const pw.TextStyle(color: _gold, fontSize: 11)),
                pw.Text(prettyDate(inv.date), style: const pw.TextStyle(color: PdfColor.fromInt(0xFF9A9AA6), fontSize: 9)),
              ]),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('BILLED TO', style: pw.TextStyle(color: _muted, fontSize: 9, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
            pw.SizedBox(height: 4),
            pw.Text(inv.patientName, style: pw.TextStyle(color: _ink, fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ]),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0x223FA787), borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Text(inv.balance <= 0 ? 'PAID IN FULL' : 'PARTIALLY PAID', style: pw.TextStyle(color: const PdfColor.fromInt(0xFF2C8367), fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ),
        ]),
        pw.SizedBox(height: 18),
        // Items table
        pw.TableHelper.fromTextArray(
          headerAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(color: _muted, fontSize: 9, fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _line, width: 1))),
          cellStyle: pw.TextStyle(color: _ink, fontSize: 10),
          cellHeight: 26,
          cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.center, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight},
          headers: ['TREATMENT / ITEM', 'QTY', 'UNIT PRICE', 'AMOUNT'],
          data: inv.lines.map((l) => [l.name, '${l.qty}', money(l.price), money(l.total)]).toList(),
        ),
        pw.SizedBox(height: 16),
        // Totals
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
          pw.SizedBox(
            width: 240,
            child: pw.Column(children: [
              _totRow('Subtotal', money(inv.subtotal)),
              _totRow('Advance Paid', '- ${money(inv.advance)}'),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(color: _gold, borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text('BALANCE DUE', style: pw.TextStyle(color: _ink, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text(money(inv.balance), style: pw.TextStyle(color: _ink, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ]),
              ),
            ]),
          ),
        ]),
        pw.Spacer(),
        pw.Divider(color: _line),
        pw.Center(child: pw.Text('Thank you for choosing HAIR AGAIN — Hair Transplant & Care, Karachi', style: const pw.TextStyle(color: _muted, fontSize: 9))),
      ],
    ),
  ));
  return doc.save();
}

pw.Widget _totRow(String k, String v) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(k, style: const pw.TextStyle(color: _muted, fontSize: 10)),
        pw.Text(v, style: pw.TextStyle(color: _ink, fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ]),
    );

/// Financial summary report document.
Future<Uint8List> buildReportPdf() async {
  final doc = pw.Document();
  final rows = appState.monthlySales;
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    build: (context) => [
      pw.Text('FINANCIAL REPORT', style: pw.TextStyle(color: _ink, fontSize: 22, fontWeight: pw.FontWeight.bold)),
      pw.Text('${appState.clinicName} • Generated ${prettyDate(DateTime.now())}', style: const pw.TextStyle(color: _muted, fontSize: 9)),
      pw.SizedBox(height: 18),
      pw.Row(children: [
        _kpi('Gross Revenue', moneyShort(appState.grossRevenue)),
        _kpi('Operational Cost', moneyShort(appState.operationalCost)),
        _kpi('Net Margin', '${appState.netMarginPct.toStringAsFixed(1)}%'),
        _kpi('Unpaid', moneyShort(appState.pendingInstallments)),
      ]),
      pw.SizedBox(height: 20),
      pw.Text('MONTHLY SALES SUMMARY', style: pw.TextStyle(color: _ink, fontSize: 12, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(color: _muted, fontSize: 9, fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _line, width: 1))),
        cellStyle: pw.TextStyle(color: _ink, fontSize: 10),
        cellHeight: 24,
        cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight, 2: pw.Alignment.center, 3: pw.Alignment.centerRight},
        headers: ['MONTH', 'REVENUE', 'PROCEDURES', 'AVG / CASE'],
        data: rows.map((r) => [r.month, moneyShort(r.revenue), '${r.procedures}', moneyShort(r.procedures == 0 ? 0 : r.revenue / r.procedures)]).toList(),
      ),
    ],
  ));
  return doc.save();
}

pw.Widget _kpi(String label, String value) => pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.only(right: 8),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: _line), borderRadius: pw.BorderRadius.circular(8)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(label, style: const pw.TextStyle(color: _muted, fontSize: 8)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(color: _ink, fontSize: 13, fontWeight: pw.FontWeight.bold)),
        ]),
      ),
    );
