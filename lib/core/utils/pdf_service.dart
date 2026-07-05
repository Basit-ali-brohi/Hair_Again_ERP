// core/utils — PDF document builders for invoices & financial reports.
// Returns raw bytes consumed by the in-app PdfPreview (view / print / download).
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../state/app_state.dart';
import 'formatters.dart';
import '../../modules/pos_inventory/models/pos_models.dart';
import '../../modules/appointments/models/appointment.dart';
import '../../modules/crm/models/patient.dart';
import '../../modules/hr/models/hr_models.dart';

const _gold = PdfColor.fromInt(0xFFC9A24B);
const _ink = PdfColor.fromInt(0xFF1A1C22);
const _muted = PdfColor.fromInt(0xFF6A7080);
const _line = PdfColor.fromInt(0xFFDCDFE6);

// Strips non-ASCII chars the built-in PDF fonts cannot render.
String _s(String t) => t
    .replaceAll('—', '-')
    .replaceAll('–', '-')
    .replaceAll('•', '|')
    .replaceAll('’', "'")
    .replaceAll('‘', "'")
    .replaceAll('“', '"')
    .replaceAll('”', '"');

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
                pw.Text(_s(appState.clinicName), style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                pw.Text(_s(appState.clinicAddress), style: const pw.TextStyle(color: PdfColor.fromInt(0xFF9A9AA6), fontSize: 9)),
                pw.Text('${appState.clinicPhone}  |  ${appState.clinicEmail}', style: const pw.TextStyle(color: PdfColor.fromInt(0xFF9A9AA6), fontSize: 9)),
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
        pw.Center(child: pw.Text('Thank you for choosing HAIR AGAIN - Hair Transplant & Care, Karachi', style: const pw.TextStyle(color: _muted, fontSize: 9))),
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
      pw.Text('${_s(appState.clinicName)}  |  Generated ${prettyDate(DateTime.now())}', style: const pw.TextStyle(color: _muted, fontSize: 9)),
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

// ── Appointments PDF ──────────────────────────────────────────────────────────
Future<Uint8List> buildAppointmentsPdf(List<Appointment> appts) async {
  final doc = pw.Document();
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    build: (context) => [
      _pdfHeader('APPOINTMENTS REPORT'),
      pw.Text('${_s(appState.clinicName)}  |  Generated ${prettyDate(DateTime.now())}', style: const pw.TextStyle(color: _muted, fontSize: 9)),
      pw.SizedBox(height: 18),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(color: _muted, fontSize: 9, fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _line, width: 1))),
        cellStyle: pw.TextStyle(color: _ink, fontSize: 10),
        cellHeight: 26,
        cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerLeft, 2: pw.Alignment.centerLeft, 3: pw.Alignment.centerLeft, 4: pw.Alignment.center},
        headers: ['PATIENT', 'TREATMENT', 'DOCTOR', 'DATE & TIME', 'STATUS'],
        data: appts.map((a) => [
          a.patientName, a.treatment, 'Dr. ${a.surgeon}',
          prettyDate(a.when), a.status.label,
        ]).toList(),
      ),
      pw.SizedBox(height: 16),
      pw.Text('Total: ${appts.length} appointment${appts.length == 1 ? '' : 's'}',
          style: pw.TextStyle(color: _muted, fontSize: 9, fontWeight: pw.FontWeight.bold)),
    ],
  ));
  return doc.save();
}

// ── Payroll PDF ───────────────────────────────────────────────────────────────
Future<Uint8List> buildPayrollPdf(List<PayrollRecord> records, {String monthLabel = ''}) async {
  final doc = pw.Document();
  final total = records.fold<double>(0, (s, r) => s + r.netSalary);
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    build: (context) => [
      _pdfHeader('PAYROLL REPORT${monthLabel.isNotEmpty ? ' — $monthLabel' : ''}'),
      pw.Text('${_s(appState.clinicName)}  |  Generated ${prettyDate(DateTime.now())}', style: const pw.TextStyle(color: _muted, fontSize: 9)),
      pw.SizedBox(height: 18),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(color: _muted, fontSize: 9, fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _line, width: 1))),
        cellStyle: pw.TextStyle(color: _ink, fontSize: 10),
        cellHeight: 26,
        cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerLeft, 2: pw.Alignment.center, 3: pw.Alignment.centerRight, 4: pw.Alignment.centerRight, 5: pw.Alignment.centerRight, 6: pw.Alignment.centerRight},
        headers: ['EMPLOYEE', 'DESIGNATION', 'DAYS', 'BASIC', 'ALLOWANCES', 'DEDUCTIONS', 'NET (PKR)'],
        data: records.map((r) => [
          r.employeeName, r.designation,
          '${r.presentDays}/${r.workingDays}',
          money(r.basicSalary), money(r.allowances),
          money(r.deductions), money(r.netSalary),
        ]).toList(),
      ),
      pw.SizedBox(height: 16),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(color: _gold, borderRadius: pw.BorderRadius.circular(6)),
          child: pw.Row(children: [
            pw.Text('TOTAL NET PAYROLL:', style: pw.TextStyle(color: _ink, fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 16),
            pw.Text(money(total), style: pw.TextStyle(color: _ink, fontSize: 13, fontWeight: pw.FontWeight.bold)),
          ]),
        ),
      ]),
    ],
  ));
  return doc.save();
}

// ── Patient Profile PDF ───────────────────────────────────────────────────────
Future<Uint8List> buildPatientPdf(Patient pt) async {
  final doc = pw.Document();
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ── Dark header band ──────────────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFF0E0E12),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('HAIR AGAIN', style: pw.TextStyle(color: _gold, fontSize: 24, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
              pw.SizedBox(height: 3),
              pw.Text('Hair Transplant & Care, Karachi', style: const pw.TextStyle(color: PdfColor.fromInt(0xFF9A9AA6), fontSize: 9)),
            ]),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text('PATIENT DOSSIER', style: pw.TextStyle(color: PdfColors.white, fontSize: 15, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
              pw.SizedBox(height: 4),
              pw.Text('Generated ${prettyDate(DateTime.now())}', style: const pw.TextStyle(color: PdfColor.fromInt(0xFF9A9AA6), fontSize: 9)),
              pw.Text('ID: ${pt.id}', style: const pw.TextStyle(color: PdfColor.fromInt(0xFF9A9AA6), fontSize: 8)),
            ]),
          ]),
        ),
        // Gold accent stripe under header
        pw.Container(height: 3, decoration: const pw.BoxDecoration(color: _gold)),
        pw.SizedBox(height: 20),

        // ── Patient identity card ─────────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFF7F5F1),
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2DDD5)),
          ),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
            pw.Container(
              width: 62, height: 62, alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(color: _gold, borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Text(pt.initials, style: pw.TextStyle(color: _ink, fontSize: 22, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(pt.name, style: pw.TextStyle(color: _ink, fontSize: 19, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text('${pt.gender}  |  ${pt.age} yrs  |  ${pt.city}  |  ${pt.status.label}',
                  style: const pw.TextStyle(color: _muted, fontSize: 10)),
              pw.SizedBox(height: 4),
              pw.Text('${pt.phone}    ${pt.email}', style: const pw.TextStyle(color: _muted, fontSize: 10)),
            ])),
            pw.SizedBox(width: 12),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: pw.BoxDecoration(color: _gold, borderRadius: pw.BorderRadius.circular(5)),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                  pw.Text('NORWOOD STAGE', style: pw.TextStyle(color: _ink, fontSize: 7, fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
                  pw.SizedBox(height: 3),
                  pw.Text('Stage ${pt.norwood}', style: pw.TextStyle(color: _ink, fontSize: 15, fontWeight: pw.FontWeight.bold)),
                ]),
              ),
              pw.SizedBox(height: 5),
              pw.SizedBox(
                width: 90,
                child: pw.Text(norwoodDesc(pt.norwood), style: const pw.TextStyle(color: _muted, fontSize: 8), textAlign: pw.TextAlign.right),
              ),
            ]),
          ]),
        ),
        pw.SizedBox(height: 22),

        // ── Contact + Clinical (two columns) ──────────────────────────────────
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: _line), borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _sectionLabel('CONTACT INFORMATION'),
              pw.SizedBox(height: 10),
              _infoRow('Phone', pt.phone),
              _infoRow('Email', pt.email),
              _infoRow('City', pt.city),
              _infoRow('Gender', pt.gender),
              _infoRow('Age', '${pt.age} years'),
            ]),
          )),
          pw.SizedBox(width: 14),
          pw.Expanded(child: pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: _line), borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _sectionLabel('CLINICAL PROFILE'),
              pw.SizedBox(height: 10),
              _infoRow('Status', pt.status.label),
              _infoRow('Norwood Scale', 'Stage ${pt.norwood} of 7'),
              _infoRow('Hair Loss', norwoodDesc(pt.norwood)),
              _infoRow('Journey Steps', '${pt.journey.length} milestone${pt.journey.length == 1 ? '' : 's'}'),
              _infoRow('Completed', '${pt.journey.where((s) => s.done).length} done'),
            ]),
          )),
        ]),
        pw.SizedBox(height: 22),

        // ── Journey table ─────────────────────────────────────────────────────
        if (pt.journey.isNotEmpty) ...[
          _sectionLabel('TRANSPLANT JOURNEY'),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerAlignment: pw.Alignment.centerLeft,
            headerStyle: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1A1C22)),
            cellStyle: pw.TextStyle(color: _ink, fontSize: 10),
            cellHeight: 26,
            cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerLeft, 2: pw.Alignment.center, 3: pw.Alignment.center},
            oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF8F6F2)),
            headers: ['MILESTONE', 'DETAIL', 'DATE', 'STATUS'],
            data: pt.journey.map((s) => [s.title, s.detail, s.date, s.done ? 'Completed' : 'Pending']).toList(),
          ),
        ],

        pw.Spacer(),
        // ── Footer ────────────────────────────────────────────────────────────
        pw.Divider(color: _line),
        pw.SizedBox(height: 3),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('HAIR AGAIN  |  Confidential Patient Record', style: const pw.TextStyle(color: _muted, fontSize: 8)),
          pw.Text('Patient ID: ${pt.id}  |  ${appState.clinicPhone}', style: const pw.TextStyle(color: _muted, fontSize: 8)),
        ]),
      ],
    ),
  ));
  return doc.save();
}

// ── Finance Report PDF ────────────────────────────────────────────────────────
Future<Uint8List> buildFinancePdf() async => buildReportPdf();

pw.Widget _sectionLabel(String title) => pw.Row(children: [
  pw.Container(width: 3, height: 13, color: _gold),
  pw.SizedBox(width: 7),
  pw.Text(title, style: pw.TextStyle(color: _ink, fontSize: 9, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
]);

pw.Widget _infoRow(String label, String value) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 7),
  child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
    pw.Text(label, style: const pw.TextStyle(color: _muted, fontSize: 9)),
    pw.Text(value, style: pw.TextStyle(color: _ink, fontSize: 9, fontWeight: pw.FontWeight.bold)),
  ]),
);

// ── Shared header ─────────────────────────────────────────────────────────────
pw.Widget _pdfHeader(String title) => pw.Container(
  padding: const pw.EdgeInsets.all(16),
  decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF0E0E12), borderRadius: pw.BorderRadius.circular(6)),
  child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
    pw.Text('HAIR AGAIN', style: pw.TextStyle(color: _gold, fontSize: 20, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
    pw.Text(title, style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
  ]),
);
