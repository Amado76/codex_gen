import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/card_data.dart';
import '../../model/card_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/models/card_background.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/background_selector_widget.dart';
import '../form_widgets/html_editor_field.dart';
import '../form_widgets/color_picker_section.dart';

class EditorFormPanel extends StatelessWidget {
  final CardData card;
  final bool showFrontFields;
  final bool isExporting;

  // Controllers (owned by ViewModel)
  final TextEditingController titleCtrl;
  final TextEditingController subtypeCtrl;
  final TextEditingController descCtrl;
  final TextEditingController goldCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController maestriaCtrl;
  final TextEditingController damageCtrl;
  final TextEditingController requirementCtrl;
  final TextEditingController backTextCtrl;
  final TextEditingController frameHexCtrl;
  final TextEditingController iconHexCtrl;
  final TextEditingController textHexCtrl;

  // Callbacks → ViewModel
  final VoidCallback onFormChanged;
  final ValueChanged<bool> onToggleSide;
  final ValueChanged<CardType> onSetType;
  final ValueChanged<Color> onSetFrameColor;
  final ValueChanged<String> onApplyFrameHex;
  final ValueChanged<Color> onSetIconColor;
  final ValueChanged<String> onApplyIconHex;
  final VoidCallback onClearIconColor;
  final ValueChanged<Color> onSetTextColor;
  final ValueChanged<String> onApplyTextHex;
  final VoidCallback onClearTextColor;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final VoidCallback onExportFront;
  final VoidCallback onExportBack;
  final ValueChanged<CardBackground> onSetBackground;

  const EditorFormPanel({
    super.key,
    required this.card,
    required this.showFrontFields,
    required this.isExporting,
    required this.titleCtrl,
    required this.subtypeCtrl,
    required this.descCtrl,
    required this.goldCtrl,
    required this.weightCtrl,
    required this.maestriaCtrl,
    required this.damageCtrl,
    required this.requirementCtrl,
    required this.backTextCtrl,
    required this.frameHexCtrl,
    required this.iconHexCtrl,
    required this.textHexCtrl,
    required this.onFormChanged,
    required this.onToggleSide,
    required this.onSetType,
    required this.onSetFrameColor,
    required this.onApplyFrameHex,
    required this.onSetIconColor,
    required this.onApplyIconHex,
    required this.onClearIconColor,
    required this.onSetTextColor,
    required this.onApplyTextHex,
    required this.onClearTextColor,
    required this.onPickImage,
    required this.onClearImage,
    required this.onExportFront,
    required this.onExportBack,
    required this.onSetBackground,
  });

  bool get _isArmor => card.cardType == CardType.armor;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      width: 290,
      color: kBgPanel,
      child: Column(
        children: [
          _buildHeader(s),
          _buildSideToggle(s),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showFrontFields) ..._frontFields(s),
                  if (!showFrontFields) ..._backFields(s),
                  const SizedBox(height: 16),
                  _section(s.backgroundSec, [
                    BackgroundSelectorWidget(current: card.background, onChange: onSetBackground),
                  ]),
                  const SizedBox(height: 16),
                  _section(s.frameColorSec, [
                    ColorSwatchPicker(selected: card.frameColor, presets: kPresetColors, onColorSelected: onSetFrameColor),
                    const SizedBox(height: 8),
                    HexColorInput(preview: card.frameColor, controller: frameHexCtrl, onHexChanged: onApplyFrameHex),
                  ]),
                  const SizedBox(height: 16),
                  _section(s.iconColorSec, [
                    Row(children: [
                      Expanded(child: HexColorInput(
                        preview: card.iconColor ?? contrastTextColor(card.frameColor),
                        controller: iconHexCtrl,
                        onHexChanged: onApplyIconHex,
                      )),
                      const SizedBox(width: 8),
                      TextButton(onPressed: onClearIconColor, style: TextButton.styleFrom(foregroundColor: kTextDim), child: Text(s.auto, style: const TextStyle(fontSize: 10))),
                    ]),
                  ]),
                  const SizedBox(height: 16),
                  _section(s.textColorSec, [
                    Row(children: [
                      Expanded(child: HexColorInput(
                        preview: card.textColorOverride ?? contrastTextColor(card.frameColor),
                        controller: textHexCtrl,
                        onHexChanged: onApplyTextHex,
                      )),
                      const SizedBox(width: 8),
                      TextButton(onPressed: onClearTextColor, style: TextButton.styleFrom(foregroundColor: kTextDim), child: Text(s.auto, style: const TextStyle(fontSize: 10))),
                    ]),
                  ]),
                  const SizedBox(height: 20),
                  _buildExportButtons(s),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(S s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: kBgHeader, border: Border(bottom: BorderSide(color: kBorderMid, width: 1))),
      child: Row(
        children: [
          Expanded(child: Text('CARD GENERATOR', style: GoogleFonts.cinzel(color: kAccentGold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
          _typeChip(s.weapon,  CardType.weapon),
          const SizedBox(width: 6),
          _typeChip(s.armor,   CardType.armor),
        ],
      ),
    );
  }

  Widget _typeChip(String label, CardType type) {
    final sel = type == card.cardType;
    return GestureDetector(
      onTap: () => onSetType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF1B4A8A) : const Color(0xFF0D1A30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? kAccentBlue : const Color(0xFF1E3A6E)),
        ),
        child: Text(label, style: GoogleFonts.cinzel(color: sel ? kAccentGold : kTextDim, fontSize: 8, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Side toggle ───────────────────────────────────────────────────────────

  Widget _buildSideToggle(S s) {
    return Container(
      decoration: const BoxDecoration(color: kBgHeader, border: Border(bottom: BorderSide(color: kBorderMid, width: 1))),
      child: Row(children: [
        _sideTab(s.front, showFrontFields,  () => onToggleSide(true)),
        _sideTab(s.back,  !showFrontFields, () => onToggleSide(false)),
      ]),
    );
  }

  Widget _sideTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? kBgPanel : kBgHeader,
            border: Border(bottom: BorderSide(color: active ? kAccentBlue : Colors.transparent, width: 2)),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(color: active ? kAccentGold : kTextDim, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
        ),
      ),
    );
  }

  // ── Field groups ──────────────────────────────────────────────────────────

  List<Widget> _frontFields(S s) => [
    _section('CONTENT', [
      _field(s.cardName,    titleCtrl),
      const SizedBox(height: 10),
      _field(s.cardSubtype, subtypeCtrl),
      const SizedBox(height: 10),
      _field(s.mastery,     descCtrl, maxLines: 2),
    ]),
    const SizedBox(height: 16),
    _section('STATS', [
      _field(s.goldValueHint,                             goldCtrl),
      const SizedBox(height: 10),
      _field(_isArmor ? s.damageCA : s.mastery,          maestriaCtrl),
      const SizedBox(height: 10),
      _field(_isArmor ? s.damageCA : s.damageCA,         damageCtrl),
    ]),
    const SizedBox(height: 16),
    _section(s.imageSection, [_imagePicker(s)]),
  ];

  List<Widget> _backFields(S s) => [
    _section('CONTENT', [
      _field(s.cardName,    titleCtrl),
      const SizedBox(height: 10),
      _field(s.cardSubtype, subtypeCtrl),
    ]),
    const SizedBox(height: 16),
    _section('STATS', [
      _field(s.goldValueHint,                     goldCtrl),
      const SizedBox(height: 10),
      _field(s.weightHint,                        weightCtrl),
      const SizedBox(height: 10),
      _field(s.damageCA,                          damageCtrl),
      if (_isArmor) ...[
        const SizedBox(height: 10),
        _field(s.requirementHint, requirementCtrl),
      ],
    ]),
    const SizedBox(height: 16),
    _section(s.backTextLabel, [
      HtmlEditorField(controller: backTextCtrl, label: s.contentHtml, onChanged: onFormChanged),
    ]),
  ];

  // ── Image picker ──────────────────────────────────────────────────────────

  Widget _imagePicker(S s) {
    final img = card.cardImage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (img != null) ...[
          ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.memory(img, height: 65, fit: BoxFit.cover)),
          const SizedBox(height: 7),
        ],
        OutlinedButton.icon(
          onPressed: onPickImage,
          icon: const Icon(Icons.upload_file, size: 14),
          label: Text(img != null ? s.changeImage : s.selectImage, style: const TextStyle(fontSize: 11)),
          style: OutlinedButton.styleFrom(
            foregroundColor: kTextMuted,
            side: const BorderSide(color: Color(0xFF2A4070)),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        if (img != null)
          TextButton(
            onPressed: onClearImage,
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF885544)),
            child: Text(s.removeImage, style: const TextStyle(fontSize: 10)),
          ),
      ],
    );
  }

  // ── Export buttons ────────────────────────────────────────────────────────

  Widget _buildExportButtons(S s) {
    return Row(children: [
      Expanded(child: _exportBtn(s.frontPng, Icons.image_outlined, onExportFront)),
      const SizedBox(width: 8),
      Expanded(child: _exportBtn(s.backPng,  Icons.flip,           onExportBack)),
    ]);
  }

  Widget _exportBtn(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: isExporting ? null : onTap,
        icon: Icon(icon, size: 14),
        label: Text(label, style: GoogleFonts.cinzel(fontWeight: FontWeight.w700, fontSize: 9)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B4A8A),
          foregroundColor: kAccentGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.cinzel(color: kAccentBlue, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 2)),
        const SizedBox(height: 2),
        Container(height: 1, color: const Color(0xFF1E3A6E)),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          onChanged: (_) => onFormChanged(),
          decoration: InputDecoration(
            filled: true,
            fillColor: kBgField,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border:        OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorderStrong)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kBorderStrong)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: kAccentBlue, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
