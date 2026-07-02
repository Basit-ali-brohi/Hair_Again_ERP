// core/utils — shared snackbar + confirm dialog helpers.
import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';

void toast(BuildContext context, String msg) {
  final p = appState.palette;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: p.body(13, color: p.text)),
    backgroundColor: p.surfaceAlt,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
    duration: const Duration(seconds: 2),
  ));
}

Future<bool> confirm(BuildContext context, String title, String body) async {
  final p = appState.palette;
  final res = await showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: p.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: p.border)),
      child: Container(
        width: 380, padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title.toUpperCase(), style: p.display(24)),
          const SizedBox(height: 10),
          Text(body, style: p.body(13, color: p.textMuted)),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: GhostButton(label: 'Cancel', onTap: () => Navigator.pop(context, false))),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(onTap: () => Navigator.pop(context, true), child: Container(padding: const EdgeInsets.symmetric(vertical: 13), alignment: Alignment.center, decoration: BoxDecoration(color: p.danger, borderRadius: BorderRadius.circular(8)), child: Text('Confirm', style: p.body(13.5, color: Colors.white, weight: FontWeight.w700))))),
          ]),
        ]),
      ),
    ),
  );
  return res ?? false;
}
