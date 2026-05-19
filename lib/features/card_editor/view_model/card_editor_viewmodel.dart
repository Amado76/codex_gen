import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../model/card_data.dart';
import '../../../core/models/card_background.dart';
import '../model/card_type.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../services/image_picker_service.dart';
import '../../../services/export_service.dart';

class CardEditorViewModel extends ChangeNotifier {
  // ── Card collection ───────────────────────────────────────────────────────
  final List<CardData> _cards = [];

  int _selectedIndex = 0;

  List<CardData> get cards => List.unmodifiable(_cards);
  int get selectedIndex => _selectedIndex;
  CardData get current => _cards[_selectedIndex];

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _showFrontFields = true;
  bool _pdfLandscape = false;
  bool _isExporting = false;
  bool _isExportingPdf = false;
  String _pdfStatus = '';

  bool _isDirty = false;

  bool get showFrontFields => _showFrontFields;
  bool get pdfLandscape    => _pdfLandscape;
  bool get isExporting     => _isExporting;
  bool get isExportingPdf  => _isExportingPdf;
  bool get isDirty         => _isDirty;
  String get pdfStatus     => _pdfStatus;

  // ── Form controllers ──────────────────────────────────────────────────────
  final titleCtrl       = TextEditingController();
  final subtypeCtrl     = TextEditingController();
  final descCtrl        = TextEditingController();
  final goldCtrl        = TextEditingController();
  final weightCtrl      = TextEditingController();
  final maestriaCtrl    = TextEditingController();
  final damageCtrl      = TextEditingController();
  final requirementCtrl = TextEditingController();
  final backTextCtrl    = TextEditingController();
  final frameHexCtrl    = TextEditingController();
  final iconHexCtrl     = TextEditingController();
  final textHexCtrl     = TextEditingController();

  CardEditorViewModel() {
    final s = S(localeNotifier.value);
    _cards.add(CardData(
      title: s.newCard,
      goldValue: '10 gp',
      weight: '4 lb.',
      maestria: s.mastery,
      damage: '1d8',
      subtype: s.defaultWeaponSubtype,
      backText:
          '<b>Heavy.</b> Creatures that are Small or Tiny have disadvantage on attack rolls with heavy weapons.',
    ));
    _loadControllers(current);
  }

  // ── Controller sync ───────────────────────────────────────────────────────
  void _loadControllers(CardData card) {
    titleCtrl.text       = card.title;
    subtypeCtrl.text     = card.subtype;
    descCtrl.text        = card.description;
    goldCtrl.text        = card.goldValue;
    weightCtrl.text      = card.weight;
    maestriaCtrl.text    = card.maestria;
    damageCtrl.text      = card.damage;
    requirementCtrl.text = card.requirement;
    backTextCtrl.text    = card.backText;
    frameHexCtrl.text    = colorToHex(card.frameColor);
    iconHexCtrl.text     = card.iconColor != null ? colorToHex(card.iconColor!) : '';
    textHexCtrl.text     = card.textColorOverride != null ? colorToHex(card.textColorOverride!) : '';
  }

  void _syncFromControllers() {
    _isDirty = true;
    _cards[_selectedIndex] = current.copyWith(
      title:       titleCtrl.text,
      subtype:     subtypeCtrl.text,
      description: descCtrl.text,
      goldValue:   goldCtrl.text,
      weight:      weightCtrl.text,
      maestria:    maestriaCtrl.text,
      damage:      damageCtrl.text,
      requirement: requirementCtrl.text,
      backText:    backTextCtrl.text,
    );
    notifyListeners();
  }

  // ── Card selection ────────────────────────────────────────────────────────
  void selectCard(int index) {
    _isDirty = false;
    _selectedIndex = index;
    _loadControllers(_cards[index]);
    notifyListeners();
  }

  // ── Card mutations ────────────────────────────────────────────────────────
  void syncFromForm() => _syncFromControllers();

  void addCard() {
    final s = S(localeNotifier.value);
    final newCard = CardData(
      title: '${s.newCard} ${_cards.length + 1}',
      goldValue: '10 gp',
      weight: '4 lb.',
      maestria: s.mastery,
      damage: '1d8',
      subtype: s.defaultWeaponSubtype,
      frameColor: current.frameColor,
    );
    _cards.add(newCard);
    _selectedIndex = _cards.length - 1;
    _loadControllers(newCard);
    notifyListeners();
  }

  void duplicateCard() {
    final s = S(localeNotifier.value);
    final dup = CardData(
      title: '${current.title} ${s.duplicateSuffix}',
      description: current.description,
      subtype: current.subtype,
      goldValue: current.goldValue,
      weight: current.weight,
      maestria: current.maestria,
      damage: current.damage,
      requirement: current.requirement,
      backText: current.backText,
      cardImage: current.cardImage,
      frameColor: current.frameColor,
      cardType: current.cardType,
      iconColor: current.iconColor,
      textColorOverride: current.textColorOverride,
    );
    _cards.insert(_selectedIndex + 1, dup);
    _selectedIndex = _selectedIndex + 1;
    notifyListeners();
  }

  void deleteCard() {
    if (_cards.length <= 1) return;
    _cards.removeAt(_selectedIndex);
    _selectedIndex = (_selectedIndex - 1).clamp(0, _cards.length - 1);
    _loadControllers(_cards[_selectedIndex]);
    notifyListeners();
  }

  // ── Color mutations ───────────────────────────────────────────────────────
  void setFrameColor(Color c) {
    _cards[_selectedIndex] = current.copyWith(frameColor: c);
    frameHexCtrl.text = colorToHex(c);
    notifyListeners();
  }

  void applyFrameHex(String hex) {
    final c = parseHex(hex);
    if (c != null) setFrameColor(c);
  }

  void setIconColor(Color c) {
    _cards[_selectedIndex] = current.copyWith(iconColor: c);
    iconHexCtrl.text = colorToHex(c);
    notifyListeners();
  }

  void applyIconHex(String hex) {
    final c = parseHex(hex);
    if (c != null) setIconColor(c);
  }

  void clearIconColor() {
    _cards[_selectedIndex] = current.copyWith(clearIconColor: true);
    iconHexCtrl.clear();
    notifyListeners();
  }

  void setTextColor(Color c) {
    _cards[_selectedIndex] = current.copyWith(textColorOverride: c);
    textHexCtrl.text = colorToHex(c);
    notifyListeners();
  }

  void applyTextHex(String hex) {
    final c = parseHex(hex);
    if (c != null) setTextColor(c);
  }

  void clearTextColor() {
    _cards[_selectedIndex] = current.copyWith(clearTextColor: true);
    textHexCtrl.clear();
    notifyListeners();
  }

  // ── Type mutation ─────────────────────────────────────────────────────────
  void setCardType(CardType t) {
    _cards[_selectedIndex] = current.copyWith(cardType: t);
    if (t == CardType.armor &&
        (subtypeCtrl.text == 'Arma Marcial' || subtypeCtrl.text == 'Martial Weapon')) {
      final s = S(localeNotifier.value);
      subtypeCtrl.text = s.defaultArmorSubtype;
      _cards[_selectedIndex] = _cards[_selectedIndex].copyWith(subtype: s.defaultArmorSubtype);
    }
    notifyListeners();
  }

  // ── Image mutation ────────────────────────────────────────────────────────
  Future<void> pickImage() async {
    final bytes = await pickImageFromDisk();
    if (bytes == null) return;
    _cards[_selectedIndex] = current.copyWith(cardImage: bytes);
    notifyListeners();
  }

  void clearImage() {
    _cards[_selectedIndex] = current.copyWith(clearImage: true);
    notifyListeners();
  }

  // ── Background ────────────────────────────────────────────────────────────
  void setBackground(CardBackground b) {
    _cards[_selectedIndex] = current.copyWith(background: b);
    notifyListeners();
  }

  // ── UI toggles ────────────────────────────────────────────────────────────
  void setShowFrontFields(bool v) {
    _showFrontFields = v;
    notifyListeners();
  }

  void setPdfLandscape(bool v) {
    _pdfLandscape = v;
    notifyListeners();
  }

  // ── Export (orchestration; capture is delegated to the View) ─────────────
  Future<void> exportSinglePng({
    required Future<Uint8List> Function() capture,
    required String filename,
  }) async {
    _isExporting = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 80));
      final bytes = await capture();
      downloadPng(bytes, filename);
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  Future<void> exportPdf({
    required Future<Uint8List> Function() captureFront,
    required Future<Uint8List> Function() captureBack,
    required Future<void> Function(int index) goToIndex,
  }) async {
    final savedIndex = _selectedIndex;
    final fronts = <Uint8List>[];
    final backs  = <Uint8List>[];

    _isExportingPdf = true;
    _pdfStatus = S(localeNotifier.value).starting;
    notifyListeners();

    try {
      for (int i = 0; i < _cards.length; i++) {
        _pdfStatus = S(localeNotifier.value).capturing(i + 1, _cards.length);
        notifyListeners();
        await goToIndex(i);
        fronts.add(await captureFront());
        backs.add(await captureBack());
        await Future.delayed(Duration.zero);
      }
      _pdfStatus = S(localeNotifier.value).generating;
      notifyListeners();
      await buildAndDownloadPdf(fronts, backs, landscape: _pdfLandscape);
    } finally {
      _selectedIndex = savedIndex;
      _loadControllers(_cards[savedIndex]);
      _isExportingPdf = false;
      _pdfStatus = '';
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    for (final c in [
      titleCtrl, subtypeCtrl, descCtrl, goldCtrl, weightCtrl,
      maestriaCtrl, damageCtrl, requirementCtrl, backTextCtrl,
      frameHexCtrl, iconHexCtrl, textHexCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
