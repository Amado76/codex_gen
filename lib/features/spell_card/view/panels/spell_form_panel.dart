import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/spell_data.dart';
import '../../view_model/spell_card_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/background_selector_widget.dart';
import '../../../card_editor/view/form_widgets/html_editor_field.dart';
import '../../../card_editor/view/form_widgets/color_picker_section.dart';

class SpellFormPanel extends StatelessWidget {
  final SpellData spell;
  final SpellCardViewModel vm;
  final VoidCallback onExportFront;
  final VoidCallback onExportBack;

  const SpellFormPanel({
    super.key,
    required this.spell,
    required this.vm,
    required this.onExportFront,
    required this.onExportBack,
  });

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
              padding: const EdgeInsets.all(14),
              child: vm.showFrontFields ? _buildFrontForm(s) : _buildBackForm(s),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(S s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: const BoxDecoration(color: kBgHeader, border: Border(bottom: BorderSide(color: kBorderMid, width: 1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SPELL GENERATOR', style: GoogleFonts.cinzel(color: kAccentGold, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          _LevelPicker(current: spell.level, onChange: vm.setLevel, label: s.levelLabel),
        ],
      ),
    );
  }

  // ── Side toggle ───────────────────────────────────────────────────────────

  Widget _buildSideToggle(S s) {
    return Container(
      decoration: const BoxDecoration(color: kBgHeader, border: Border(bottom: BorderSide(color: kBorderMid, width: 1))),
      child: Row(children: [
        _sideTab(s.front, vm.showFrontFields,  () => vm.setShowFrontFields(true)),
        _sideTab(s.back,  !vm.showFrontFields, () => vm.setShowFrontFields(false)),
      ]),
    );
  }

  Widget _sideTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
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

  // ── Front form ────────────────────────────────────────────────────────────

  Widget _buildFrontForm(S s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(s.identity, [
          _SchoolDropdown(current: spell.school, onChange: vm.setSchool, label: s.spellSchool),
          const SizedBox(height: 10),
          _field(s.spellName, vm.nameCtrl),
          const SizedBox(height: 10),
          _field(s.subtitleHint, vm.subtitleCtrl),
        ]),
        const SizedBox(height: 14),
        _section(s.statsTopRow, [
          _field(s.castingTime, vm.castingTimeCtrl),
          const SizedBox(height: 8),
          _field(s.rangeField, vm.rangeCtrl),
          const SizedBox(height: 8),
          _field(s.durationField, vm.durationCtrl),
          const SizedBox(height: 8),
          _field(s.componentsField, vm.componentsCtrl),
          const SizedBox(height: 8),
          _BoolField(label: s.concentration, value: spell.concentration, onChange: vm.setConcentration),
        ]),
        const SizedBox(height: 14),
        _section(s.effectSection, [
          _field(s.effectText, vm.effectCtrl, maxLines: 3),
          const SizedBox(height: 8),
          _field(s.hitEffectField, vm.hitEffectCtrl, maxLines: 2),
        ]),
        const SizedBox(height: 14),
        _section(s.scalingOptional, [
          _ScalingEditor(vm: vm, s: s),
        ]),
        const SizedBox(height: 14),
        _section(s.statsBottomRow, [
          _field(s.savingThrow, vm.savingThrowCtrl),
          const SizedBox(height: 8),
          _DamageTypeDropdown(current: spell.damageType, onChange: vm.setDamageType, label: s.damageTypeField, noneLabel: s.noneLabel),
          const SizedBox(height: 8),
          _BoolField(label: s.magicAttack, value: spell.hasAttack, onChange: vm.setHasAttack),
          const SizedBox(height: 8),
          _BoolField(label: s.ritual, value: spell.isRitual, onChange: vm.setIsRitual),
        ]),
        const SizedBox(height: 14),
        _section(s.imageSection, [_imagePicker(s)]),
        const SizedBox(height: 14),
        _section(s.backgroundSec, [
          BackgroundSelectorWidget(current: spell.background, onChange: vm.setBackground),
        ]),
        const SizedBox(height: 14),
        _section(s.frameColorSec, [
          ColorSwatchPicker(selected: spell.accentColor, presets: kPresetColors, onColorSelected: vm.setAccentColor),
          const SizedBox(height: 8),
          HexColorInput(preview: spell.accentColor, controller: vm.accentHexCtrl, onHexChanged: vm.applyAccentHex),
        ]),
        const SizedBox(height: 14),
        _buildExportButtons(s),
      ],
    );
  }

  // ── Back form ─────────────────────────────────────────────────────────────

  Widget _buildBackForm(S s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(s.descriptionSec, [
          HtmlEditorField(controller: vm.descriptionCtrl, label: s.contentHtml, onChanged: vm.syncFromForm),
        ]),
        const SizedBox(height: 14),
        _section(s.scalingBack, [
          HtmlEditorField(controller: vm.backScalingCtrl, label: s.scalingTextHtml, onChanged: vm.syncFromForm),
        ]),
        const SizedBox(height: 14),
        _section(s.howToUseSec, [
          _field('', vm.howToUseCtrl, maxLines: 4),
        ]),
        const SizedBox(height: 14),
        _section(s.tacticalTipsSec, [
          _field(s.tipPerLine, vm.tacticalTipsCtrl, maxLines: 4),
        ]),
        const SizedBox(height: 14),
        _section(s.informationSec, [
          _field(s.classesHint, vm.classesCtrl),
          const SizedBox(height: 8),
          _field(s.additionalInfo, vm.additionalInfoCtrl, maxLines: 2),
        ]),
        const SizedBox(height: 14),
        _section(s.loreSec, [
          _field(s.loreTextField, vm.loreCtrl, maxLines: 3),
        ]),
        const SizedBox(height: 14),
        _buildExportButtons(s),
      ],
    );
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  Widget _imagePicker(S s) {
    final img = spell.spellImage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (img != null) ...[
          ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.memory(img, height: 65, fit: BoxFit.cover)),
          const SizedBox(height: 7),
        ],
        OutlinedButton.icon(
          onPressed: vm.pickImage,
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
            onPressed: vm.clearImage,
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
        onPressed: vm.isExporting ? null : onTap,
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
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
        ],
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          onChanged: (_) => vm.syncFromForm(),
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

// ── Inline widgets ────────────────────────────────────────────────────────────

class _LevelPicker extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChange;
  final String label;
  const _LevelPicker({required this.current, required this.onChange, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: GoogleFonts.cinzel(color: kTextMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: List.generate(10, (i) => Expanded(
              child: GestureDetector(
                onTap: () => onChange(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  height: 22,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: current == i ? kAccentBlue : kBgField,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: current == i ? kAccentBlue : kBorderStrong),
                  ),
                  child: Center(
                    child: Text('$i', style: TextStyle(color: current == i ? Colors.white : kTextMuted, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            )),
          ),
        ),
      ],
    );
  }
}

class _SchoolDropdown extends StatelessWidget {
  final SpellSchool current;
  final ValueChanged<SpellSchool> onChange;
  final String label;
  const _SchoolDropdown({required this.current, required this.onChange, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: kBgField,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kBorderStrong),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: DropdownButton<SpellSchool>(
            value: current,
            isExpanded: true,
            dropdownColor: kBgPanel,
            underline: const SizedBox.shrink(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
            onChanged: (v) { if (v != null) onChange(v); },
            items: SpellSchool.values.map((s) => DropdownMenuItem(
              value: s,
              child: Row(children: [
                Image.asset(s.iconPath, width: 16, height: 16, color: kTextMuted),
                const SizedBox(width: 8),
                Text(s.label, style: const TextStyle(color: Colors.white, fontSize: 11)),
              ]),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _DamageTypeDropdown extends StatelessWidget {
  final DamageType? current;
  final ValueChanged<DamageType?> onChange;
  final String label;
  final String noneLabel;
  const _DamageTypeDropdown({required this.current, required this.onChange, required this.label, required this.noneLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: kBgField,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kBorderStrong),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: DropdownButton<DamageType?>(
            value: current,
            isExpanded: true,
            dropdownColor: kBgPanel,
            underline: const SizedBox.shrink(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
            onChanged: onChange,
            items: [
              DropdownMenuItem<DamageType?>(
                value: null,
                child: Text(noneLabel, style: const TextStyle(color: kTextDim, fontSize: 11)),
              ),
              ...DamageType.values.map((d) => DropdownMenuItem<DamageType?>(
                value: d,
                child: Row(children: [
                  Image.asset(d.iconPath, width: 16, height: 16, color: kTextMuted),
                  const SizedBox(width: 8),
                  Text(d.label, style: const TextStyle(color: Colors.white, fontSize: 11)),
                ]),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class _BoolField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChange;
  const _BoolField({required this.label, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: kTextMuted, fontSize: 10, fontWeight: FontWeight.w500)),
        const Spacer(),
        GestureDetector(
          onTap: () => onChange(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44, height: 24,
            decoration: BoxDecoration(
              color: value ? kAccentBlue : kBgField,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: value ? kAccentBlue : kBorderStrong),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 18, height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScalingEditor extends StatelessWidget {
  final SpellCardViewModel vm;
  final S s;
  const _ScalingEditor({required this.vm, required this.s});

  @override
  Widget build(BuildContext context) {
    final entries = vm.current.scalingEntries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...List.generate(entries.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: vm.scalingLevelCtrls[i],
                style: const TextStyle(color: Colors.white, fontSize: 11),
                onChanged: (_) => vm.syncScalingEntry(i),
                decoration: _dec(s.levelExample),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: vm.scalingValueCtrls[i],
                style: const TextStyle(color: Colors.white, fontSize: 11),
                onChanged: (_) => vm.syncScalingEntry(i),
                decoration: _dec(s.valueExample),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => vm.removeScalingEntry(i),
              child: const Icon(Icons.close, size: 16, color: Color(0xFF885544)),
            ),
          ]),
        )),
        OutlinedButton.icon(
          onPressed: entries.length < 5 ? vm.addScalingEntry : null,
          icon: const Icon(Icons.add, size: 13),
          label: Text(s.addLevel, style: const TextStyle(fontSize: 10)),
          style: OutlinedButton.styleFrom(
            foregroundColor: kTextMuted,
            side: const BorderSide(color: kBorderLight),
            padding: const EdgeInsets.symmetric(vertical: 7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
      ],
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
    filled: true, fillColor: kBgField, hintText: hint,
    hintStyle: const TextStyle(color: kTextDim, fontSize: 10),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    border:        OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: kBorderStrong)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: kBorderStrong)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: kAccentBlue, width: 1.5)),
  );
}

