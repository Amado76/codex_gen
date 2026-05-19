import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/home_shell.dart';
import 'core/l10n/locale_notifier.dart';
import 'core/l10n/app_localizations.dart';

void main() {
  runApp(const CodexGenApp());
}

class CodexGenApp extends StatelessWidget {
  const CodexGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, _) {
        return AppLocaleInherited(
          notifier: localeNotifier,
          child: MaterialApp(
            title: 'CodexGen',
            debugShowCheckedModeBanner: false,
            locale: Locale(lang),
            supportedLocales: const [Locale('en'), Locale('pt')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1B3A6E),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            home: const HomeShell(),
          ),
        );
      },
    );
  }
}
