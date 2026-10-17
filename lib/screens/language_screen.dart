import 'package:flutter/material.dart';
import '../core.dart';
import '../services/app_state.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
  static const langs = [
    ['English', 'English'], ['Urdu', 'اردو'], ['Arabic', 'العربية'], ['French', 'Français'],
    ['Spanish', 'Español'], ['Chinese', '中文'], ['Hindi', 'हिन्दी'], ['Turkish', 'Türkçe'],
  ];
  @override
  Widget build(BuildContext context) => SubPage('Language',
      sub: 'Default is English',
      child: ValueListenableBuilder<String>(
        valueListenable: AppState.language,
        builder: (_, cur, __) => ListView(padding: const EdgeInsets.symmetric(horizontal: 22), children: [
          for (final l in langs)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Box(
                  color: cur == l[0] ? const Color(0xFFE3EEE7) : Colors.white,
                  border: cur == l[0] ? C.sage : null,
                  onTap: () => AppState.language.value = l[0],
                  child: Row(children: [
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l[0], style: body(17, c: C.forest, w: FontWeight.w800)),
                      Text(l[1], style: body(15)),
                    ])),
                    Icon(cur == l[0] ? Icons.check_circle : Icons.radio_button_unchecked, color: C.sage, size: 28),
                  ])),
            ),
          const SizedBox(height: 6),
          Text('Your choice is saved. Translations will be applied in a later update.', style: body(13)),
          const SizedBox(height: 16),
        ]),
      ));
}
