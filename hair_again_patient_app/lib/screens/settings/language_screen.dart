import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'English';

  static const _languages = [
    _Lang('English',  'English',  '🇬🇧'),
    _Lang('Urdu',     'اردو',     '🇵🇰'),
    _Lang('Arabic',   'العربية',  '🇸🇦'),
    _Lang('Hindi',    'हिन्दी',   '🇮🇳'),
    _Lang('French',   'Français', '🇫🇷'),
    _Lang('German',   'Deutsch',  '🇩🇪'),
    _Lang('Spanish',  'Español',  '🇪🇸'),
    _Lang('Turkish',  'Türkçe',   '🇹🇷'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: const KAppBar(title: 'Language'),
      body: Column(children: [
        // Info
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kGold.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGold.withValues(alpha: 0.18)),
          ),
          child: Row(children: [
            const Icon(Icons.translate_rounded, color: kGold, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text('Select your preferred language for the app interface.', style: p.body(13, color: p.textMuted))),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            itemCount: _languages.length,
            itemBuilder: (_, i) {
              final lang = _languages[i];
              final sel = lang.code == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = lang.code),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: sel ? kGold.withValues(alpha: 0.08) : p.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: sel ? kGold.withValues(alpha: 0.5) : p.border, width: sel ? 1.5 : 1),
                    boxShadow: [if (sel) BoxShadow(color: kGold.withValues(alpha: 0.06), blurRadius: 10)],
                  ),
                  child: Row(children: [
                    Text(lang.flag, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(lang.code, style: p.body(15, weight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? kGold : p.text)),
                      Text(lang.native, style: p.body(13, color: p.textMuted)),
                    ])),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sel ? kGold : Colors.transparent,
                        border: Border.all(color: sel ? kGold : p.border, width: 2),
                      ),
                      child: sel ? const Icon(Icons.check, size: 13, color: Colors.black87) : null,
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: GoldButton(label: 'Apply Language', onTap: () => Navigator.pop(context)),
        ),
      ]),
    );
  }
}

class _Lang {
  final String code, native, flag;
  const _Lang(this.code, this.native, this.flag);
}
