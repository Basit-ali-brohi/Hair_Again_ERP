// core/utils — in-app PDF preview dialog with built-in print & download/share,
// wrapping the `printing` package's PdfPreview.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../state/app_state.dart';

Future<void> showPdfPreview(
  BuildContext context, {
  required String title,
  required Future<Uint8List> Function() build,
}) {
  final p = appState.palette;
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: SizedBox(
        width: 780,
        height: 640,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: p.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.picture_as_pdf_outlined, color: p.gold, size: 18)),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: p.display(24), maxLines: 1, overflow: TextOverflow.ellipsis)),
              IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: p.textMuted)),
            ]),
          ),
          Divider(height: 1, color: p.border),
          Expanded(
            child: PdfPreview(
              build: (format) => build(),
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              allowPrinting: true,
              allowSharing: true,
              initialPageFormat: PdfPageFormat.a4,
              pdfFileName: '${title.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}.pdf',
              loadingWidget: Center(child: CircularProgressIndicator(color: p.gold)),
              previewPageMargin: const EdgeInsets.all(12),
            ),
          ),
        ]),
      ),
    ),
  );
}
