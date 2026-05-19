import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../model/spell_data.dart';
import '../../../core/models/card_background.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../services/image_picker_service.dart';
import '../../../services/export_service.dart';

class SpellCardViewModel extends ChangeNotifier {
  // ── Spell collection ───────────────────────────────────────────────────────
  final List<SpellData> _spells = [];

  int _selectedIndex = 0;

  List<SpellData> get spells => List.unmodifiable(_spells);
  int get selectedIndex => _selectedIndex;
  SpellData get current => _spells[_selectedIndex];

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _showFrontFields = true;
  bool _pdfLandscape    = false;
  bool _isExporting     = false;
  bool _isExportingPdf  = false;
  String _pdfStatus     = '';

  bool _isDirty = false;

  bool get showFrontFields => _showFrontFields;
  bool get pdfLandscape    => _pdfLandscape;
  bool get isExporting     => _isExporting;
  bool get isExportingPdf  => _isExportingPdf;
  bool get isDirty         => _isDirty;
  String get pdfStatus     => _pdfStatus;

  // ── Form controllers ──────────────────────────────────────────────────────
  final nameCtrl          = TextEditingController();
  final subtitleCtrl      = TextEditingController();
  final castingTimeCtrl   = TextEditingController();
  final rangeCtrl         = TextEditingController();
  final durationCtrl      = TextEditingController();
  final componentsCtrl    = TextEditingController();
  final effectCtrl        = TextEditingController();
  final hitEffectCtrl     = TextEditingController();
  final savingThrowCtrl   = TextEditingController();
  final classesCtrl       = TextEditingController();
  final descriptionCtrl   = TextEditingController();
  final backScalingCtrl   = TextEditingController();
  final howToUseCtrl      = TextEditingController();
  final tacticalTipsCtrl  = TextEditingController();
  final additionalInfoCtrl = TextEditingController();
  final loreCtrl          = TextEditingController();
  final accentHexCtrl     = TextEditingController();

  // Scaling entries controllers (parallel to scalingEntries)
  final List<TextEditingController> scalingLevelCtrls = [];
  final List<TextEditingController> scalingValueCtrls = [];

  SpellCardViewModel() {
    final s = S(localeNotifier.value);
    _spells.add(SpellData(
      name: s.newSpell,
      subtitle: s.defaultSubtitle,
      school: SpellSchool.evocacao,
      level: 0,
      castingTime: s.defaultCastingTime,
      range: s.defaultRange,
      duration: s.defaultDuration,
      components: 'V, S',
      effect: s.describeEffect,
    ));
    _loadControllers(current);
  }

  // ── Controller sync ───────────────────────────────────────────────────────
  void _loadControllers(SpellData s) {
    nameCtrl.text           = s.name;
    subtitleCtrl.text       = s.subtitle;
    castingTimeCtrl.text    = s.castingTime;
    rangeCtrl.text          = s.range;
    durationCtrl.text       = s.duration;
    componentsCtrl.text     = s.components;
    effectCtrl.text         = s.effect;
    hitEffectCtrl.text      = s.hitEffect;
    savingThrowCtrl.text    = s.savingThrow;
    classesCtrl.text        = s.classes;
    descriptionCtrl.text    = s.description;
    backScalingCtrl.text    = s.backScaling;
    howToUseCtrl.text       = s.howToUse;
    tacticalTipsCtrl.text   = s.tacticalTips;
    additionalInfoCtrl.text = s.additionalInfo;
    loreCtrl.text           = s.lore;
    accentHexCtrl.text      = colorToHex(s.accentColor);
    _rebuildScalingControllers(s.scalingEntries);
  }

  void _rebuildScalingControllers(List<ScalingEntry> entries) {
    for (final c in scalingLevelCtrls) c.dispose();
    for (final c in scalingValueCtrls) c.dispose();
    scalingLevelCtrls.clear();
    scalingValueCtrls.clear();
    for (final e in entries) {
      scalingLevelCtrls.add(TextEditingController(text: e.level));
      scalingValueCtrls.add(TextEditingController(text: e.value));
    }
  }

  void syncFromForm() {
    _isDirty = true;
    _spells[_selectedIndex] = current.copyWith(
      name:           nameCtrl.text,
      subtitle:       subtitleCtrl.text,
      castingTime:    castingTimeCtrl.text,
      range:          rangeCtrl.text,
      duration:       durationCtrl.text,
      components:     componentsCtrl.text,
      effect:         effectCtrl.text,
      hitEffect:      hitEffectCtrl.text,
      savingThrow:    savingThrowCtrl.text,
      classes:        classesCtrl.text,
      description:    descriptionCtrl.text,
      backScaling:    backScalingCtrl.text,
      howToUse:       howToUseCtrl.text,
      tacticalTips:   tacticalTipsCtrl.text,
      additionalInfo: additionalInfoCtrl.text,
      lore:           loreCtrl.text,
      scalingEntries: _readScalingEntries(),
    );
    notifyListeners();
  }

  List<ScalingEntry> _readScalingEntries() {
    final entries = <ScalingEntry>[];
    for (int i = 0; i < scalingLevelCtrls.length; i++) {
      entries.add(ScalingEntry(level: scalingLevelCtrls[i].text, value: scalingValueCtrls[i].text));
    }
    return entries;
  }

  // ── Spell selection ───────────────────────────────────────────────────────
  void selectSpell(int index) {
    _isDirty = false;
    _selectedIndex = index;
    _loadControllers(_spells[index]);
    notifyListeners();
  }

  // ── Spell mutations ───────────────────────────────────────────────────────
  void addSpell() {
    final loc = S(localeNotifier.value);
    final s = SpellData(
      name: '${loc.newSpell} ${_spells.length + 1}',
      subtitle: loc.defaultSubtitle,
      school: current.school,
      accentColor: current.accentColor,
    );
    _spells.add(s);
    _selectedIndex = _spells.length - 1;
    _loadControllers(s);
    notifyListeners();
  }

  void duplicateSpell() {
    final loc = S(localeNotifier.value);
    final dup = current.copyWith(name: '${current.name} ${loc.duplicateSuffix}');
    _spells.insert(_selectedIndex + 1, dup);
    _selectedIndex = _selectedIndex + 1;
    notifyListeners();
  }

  void deleteSpell() {
    if (_spells.length <= 1) return;
    _spells.removeAt(_selectedIndex);
    _selectedIndex = (_selectedIndex - 1).clamp(0, _spells.length - 1);
    _loadControllers(_spells[_selectedIndex]);
    notifyListeners();
  }

  // ── Field mutations ───────────────────────────────────────────────────────
  void setSchool(SpellSchool s) {
    _spells[_selectedIndex] = current.copyWith(school: s);
    notifyListeners();
  }

  void setLevel(int l) {
    _spells[_selectedIndex] = current.copyWith(level: l);
    notifyListeners();
  }

  void setConcentration(bool v) {
    _spells[_selectedIndex] = current.copyWith(concentration: v);
    notifyListeners();
  }

  void setDamageType(DamageType? d) {
    _spells[_selectedIndex] = d == null
        ? current.copyWith(clearDamageType: true)
        : current.copyWith(damageType: d);
    notifyListeners();
  }

  void setHasAttack(bool v) {
    _spells[_selectedIndex] = current.copyWith(hasAttack: v);
    notifyListeners();
  }

  void setIsRitual(bool v) {
    _spells[_selectedIndex] = current.copyWith(isRitual: v);
    notifyListeners();
  }

  // ── Color mutations ───────────────────────────────────────────────────────
  void setAccentColor(Color c) {
    _spells[_selectedIndex] = current.copyWith(accentColor: c);
    accentHexCtrl.text = colorToHex(c);
    notifyListeners();
  }

  void applyAccentHex(String hex) {
    final c = parseHex(hex);
    if (c != null) setAccentColor(c);
  }

  // ── Image ─────────────────────────────────────────────────────────────────
  Future<void> pickImage() async {
    final bytes = await pickImageFromDisk();
    if (bytes == null) return;
    _spells[_selectedIndex] = current.copyWith(spellImage: bytes);
    notifyListeners();
  }

  void clearImage() {
    _spells[_selectedIndex] = current.copyWith(clearImage: true);
    notifyListeners();
  }

  // ── Scaling entries ───────────────────────────────────────────────────────
  void addScalingEntry() {
    final entries = List<ScalingEntry>.from(current.scalingEntries)
      ..add(const ScalingEntry(level: '', value: ''));
    _spells[_selectedIndex] = current.copyWith(scalingEntries: entries);
    scalingLevelCtrls.add(TextEditingController());
    scalingValueCtrls.add(TextEditingController());
    notifyListeners();
  }

  void removeScalingEntry(int index) {
    final entries = List<ScalingEntry>.from(current.scalingEntries)..removeAt(index);
    scalingLevelCtrls[index].dispose();
    scalingValueCtrls[index].dispose();
    scalingLevelCtrls.removeAt(index);
    scalingValueCtrls.removeAt(index);
    _spells[_selectedIndex] = current.copyWith(scalingEntries: entries);
    notifyListeners();
  }

  void syncScalingEntry(int index) {
    final entries = List<ScalingEntry>.from(current.scalingEntries);
    entries[index] = ScalingEntry(
      level: scalingLevelCtrls[index].text,
      value: scalingValueCtrls[index].text,
    );
    _spells[_selectedIndex] = current.copyWith(scalingEntries: entries);
    notifyListeners();
  }

  // ── Background ────────────────────────────────────────────────────────────
  void setBackground(CardBackground b) {
    _spells[_selectedIndex] = current.copyWith(background: b);
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

  // ── Export ────────────────────────────────────────────────────────────────
  Future<void> exportSinglePng({
    required Future<Uint8List> Function() capture,
    required String filename,
  }) async {
    _isExporting = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 80));
      downloadPng(await capture(), filename);
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
      for (int i = 0; i < _spells.length; i++) {
        _pdfStatus = S(localeNotifier.value).capturing(i + 1, _spells.length);
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
      _loadControllers(_spells[savedIndex]);
      _isExportingPdf = false;
      _pdfStatus = '';
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    for (final c in [
      nameCtrl, subtitleCtrl, castingTimeCtrl, rangeCtrl, durationCtrl,
      componentsCtrl, effectCtrl, hitEffectCtrl, savingThrowCtrl, classesCtrl,
      descriptionCtrl, backScalingCtrl, howToUseCtrl, tacticalTipsCtrl,
      additionalInfoCtrl, loreCtrl, accentHexCtrl,
    ]) {
      c.dispose();
    }
    for (final c in scalingLevelCtrls) c.dispose();
    for (final c in scalingValueCtrls) c.dispose();
    super.dispose();
  }
}
