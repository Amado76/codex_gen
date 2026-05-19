import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Global singleton — used by ViewModels that lack BuildContext.
final localeNotifier = LocaleNotifier(_detectBrowserLang());

String _detectBrowserLang() {
  try {
    final lang = ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (lang == 'pt') return 'pt';
  } catch (_) {}
  return 'en';
}

class LocaleNotifier extends ValueNotifier<String> {
  LocaleNotifier(super.initial);
  void setEnglish() => value = 'en';
  void setPortuguese() => value = 'pt';
  void toggle() => value = value == 'pt' ? 'en' : 'pt';
  bool get isPt => value == 'pt';
}
