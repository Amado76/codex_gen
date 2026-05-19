import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/spell_data.dart';
import '../../view_model/spell_card_viewmodel.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/painters/line_painter.dart';
import '../../../../core/painters/elegant_painter.dart';
import '../../../../core/models/card_background.dart';
import '../../../../core/l10n/app_localizations.dart';

class SpellFrontWidget extends StatelessWidget {
  final SpellData spell;
  final SpellCardViewModel? vm;

  static const double cardWidth = 252.0;
  static const double cardHeight = 352.0;

  const SpellFrontWidget({super.key, required this.spell, this.vm});

  bool get _editable => vm != null;

  Color get _frame => spell.accentColor;
  Color get _frameDark => darkenColor(_frame, 0.20);
  Color get _frameLight => lightenColor(_frame, 0.10);
  Color get _textColor => spell.textColorOverride ?? contrastTextColor(_frame);

  void _sync() => vm?.syncFromForm();

  Widget _text({
    required String value,
    required TextStyle style,
    TextEditingController? ctrl,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    String hint = '',
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    if (ctrl == null || !_editable) {
      return Text(value, style: style, maxLines: maxLines, overflow: overflow, textAlign: textAlign);
    }
    return TextField(
      controller: ctrl,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      onChanged: (_) => _sync(),
      decoration: InputDecoration.collapsed(
        hintText: hint,
        hintStyle: style.copyWith(color: style.color?.withValues(alpha: 0.35)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_frameLight, _frame, _frameDark],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
                child: CustomPaint(
              painter:
                  spell.background == CardBackground.elegant ? ElegantPainter(color: _textColor) : const LinePainter(),
            )),
            Positioned.fill(
              child: Builder(builder: (ctx) {
                final s = S.of(ctx);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildHeader(s),
                    Expanded(child: _buildBody(s)),
                  ],
                );
              }),
            ),
            Positioned(
              top: 0,
              right: 18,
              child:
                  _LevelBadge(school: spell.school, level: spell.level, frameLight: _frameLight, textColor: _textColor),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _headerIcon({required String path, required bool zoom}) {
    if (!zoom) {
      return Image.asset(
        path,
        width: 50,
        height: 50,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
      );
    }
    return ClipRect(
      child: SizedBox(
        width: 50,
        height: 50,
        child: Transform.scale(
          scale: 1.10,
          child: Image.asset(
            path,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(S s) {
    final nameStyle = GoogleFonts.cinzel(
      color: _textColor,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      shadows: [Shadow(color: _frameDark.withValues(alpha: 0.6), blurRadius: 3, offset: const Offset(0, 1))],
    );
    final subtitleStyle =
        GoogleFonts.lora(color: _textColor.withValues(alpha: 0.72), fontSize: 6, fontStyle: FontStyle.italic);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 1, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _headerIcon(
            path: spell.damageType != null ? spell.damageType!.iconPath : spell.school.iconPath,
            zoom: spell.damageType == null,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _text(value: spell.name, style: nameStyle, ctrl: vm?.nameCtrl, hint: s.spellName),
                if (spell.subtitle.isNotEmpty)
                  _text(
                      value: spell.subtitle.toUpperCase(),
                      style: subtitleStyle,
                      ctrl: vm?.subtitleCtrl,
                      hint: s.subtitleHint),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Body — image + stats bar + effect/scaling content ────────────────────

  Widget _buildBody(S s) {
    final hasScaling = spell.scalingEntries.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: Container(
        decoration: BoxDecoration(
          color: _frameDark.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _textColor.withValues(alpha: 0.18), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Spell image
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _editable ? vm!.pickImage : null,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9),
                  ),
                  child: spell.spellImage != null
                      ? Stack(
                          children: [
                            Image.memory(spell.spellImage!, fit: BoxFit.cover, width: double.infinity, filterQuality: FilterQuality.high, isAntiAlias: true),
                            if (_editable)
                              Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.0))),
                          ],
                        )
                      : _ImagePlaceholder(textColor: _textColor, frameDark: _frameDark, editable: _editable),
                ),
              ),
            ),
            // Stats bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: _textColor.withValues(alpha: 0.15), width: 1)),
              ),
              child: Row(
                children: [
                  _StatCell(label: s.statTime, value: spell.castingTime, textColor: _textColor),
                  _StatDivider(color: _textColor),
                  _StatCell(label: s.statRange, value: spell.range, textColor: _textColor),
                  _StatDivider(color: _textColor),
                  _StatCell(label: s.statDuration, value: spell.duration, textColor: _textColor),
                  _StatDivider(color: _textColor),
                  _StatCell(label: s.statComp, value: spell.components, textColor: _textColor),
                  _StatDivider(color: _textColor),
                  _StatCell(label: s.statConc, value: spell.concentration ? s.yes : s.no, textColor: _textColor),
                  _StatDivider(color: _textColor),
                  _StatCell(label: s.statRitual, value: spell.isRitual ? s.yes : s.no, textColor: _textColor),
                ],
              ),
            ),
            // Effect + scaling + bottom row
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: s.cardEffect, textColor: _textColor),
                    const SizedBox(height: 2),
                    _text(
                      value: spell.effect.isEmpty ? s.describeEffect : spell.effect,
                      style: GoogleFonts.lora(
                        color: spell.effect.isEmpty
                            ? _textColor.withValues(alpha: 0.35)
                            : _textColor.withValues(alpha: 0.92),
                        fontSize: 6.5,
                        height: 1.35,
                      ),
                      ctrl: vm?.effectCtrl,
                      maxLines: hasScaling ? 3 : 5,
                      hint: s.describeEffect,
                    ),
                    if (spell.hitEffect.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      _HitEffectRow(text: spell.hitEffect, textColor: _textColor),
                    ],
                    if (hasScaling) ...[
                      const SizedBox(height: 4),
                      _ScalingTable(
                          entries: spell.scalingEntries, textColor: _textColor, frameDark: _frameDark, vm: vm),
                    ],
                    const Spacer(),
                    _buildBottomRow(s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom row ────────────────────────────────────────────────────────────

  Widget _buildBottomRow(S s) {
    final hasSave = spell.savingThrow.isNotEmpty && spell.savingThrow != '—';
    final hasDamage = spell.damageType != null;
    final hasAtk = spell.hasAttack;

    if (!hasSave && !hasDamage && !hasAtk) return const SizedBox.shrink();

    final stats = <Widget>[];

    if (hasSave) {
      stats.add(Expanded(
          child: _BottomStat(
              label: s.cardSave,
              value: spell.savingThrow,
              textColor: _textColor,
              ctrl: vm?.savingThrowCtrl,
              onSync: _sync)));
    }
    if (hasDamage) {
      if (stats.isNotEmpty) stats.add(_BottomDivider(color: _textColor));
      stats.add(Expanded(child: _BottomStat(label: s.cardType, value: spell.damageType!.label, textColor: _textColor)));
    }
    if (hasAtk) {
      if (stats.isNotEmpty) stats.add(_BottomDivider(color: _textColor));
      stats.add(Expanded(
          child: _BottomStat(label: s.cardAttack, value: spell.hasAttack ? s.yes : s.no, textColor: _textColor)));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _textColor.withValues(alpha: 0.2), width: 1)),
      ),
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: stats),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  final SpellSchool school;
  final int level;
  final Color frameLight;
  final Color textColor;
  const _LevelBadge({required this.school, required this.level, required this.frameLight, required this.textColor});

  static const double _w = 30.0;
  static const double _h = 36.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(_w / 2),
        bottomRight: Radius.circular(_w / 2),
      ),
      child: Container(
        width: _w,
        height: _h,
        color: frameLight.withValues(alpha: 0.92),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              school.label.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(color: textColor, fontSize: 3, fontWeight: FontWeight.w700, letterSpacing: 0.2),
            ),
            const SizedBox(height: 6),
            Text(
              '$level',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(color: textColor, fontSize: 12, fontWeight: FontWeight.w700, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  const _StatCell({required this.label, required this.value, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final valueStyle = GoogleFonts.lora(color: textColor, fontSize: 5.5, fontWeight: FontWeight.w700);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 4.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(value, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: valueStyle),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final Color color;
  const _StatDivider({required this.color});
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 20, color: color.withValues(alpha: 0.2));
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textColor;
  const _SectionLabel({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.cinzel(
            color: textColor.withValues(alpha: 0.75), fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 1.5));
  }
}

class _HitEffectRow extends StatelessWidget {
  final String text;
  final Color textColor;
  const _HitEffectRow({required this.text, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.lora(color: textColor, fontSize: 6.5, height: 1.3);
    final labelStyle = GoogleFonts.cinzel(
        color: textColor.withValues(alpha: 0.75), fontSize: 6, fontWeight: FontWeight.w700, letterSpacing: 0.5);
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(children: [
          TextSpan(text: 'ACERTO ', style: labelStyle),
          TextSpan(text: '— ', style: bodyStyle.copyWith(color: textColor.withValues(alpha: 0.5))),
          TextSpan(text: text, style: bodyStyle),
        ]),
      ),
    );
  }
}

class _ScalingTable extends StatelessWidget {
  final List<ScalingEntry> entries;
  final Color textColor;
  final Color frameDark;
  final SpellCardViewModel? vm;
  const _ScalingTable({required this.entries, required this.textColor, required this.frameDark, this.vm});

  @override
  Widget build(BuildContext context) {
    final levelStyle = GoogleFonts.cinzel(
        color: textColor.withValues(alpha: 0.55), fontSize: 6, fontWeight: FontWeight.w700, letterSpacing: 0.5);
    final valueStyle = GoogleFonts.lora(color: textColor, fontSize: 9, fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('ESCALONAMENTO',
                style: GoogleFonts.cinzel(
                    color: textColor.withValues(alpha: 0.75),
                    fontSize: 6.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
            const SizedBox(width: 5),
            Expanded(child: Container(height: 1, color: textColor.withValues(alpha: 0.2))),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 4),
            for (int i = 0; i < entries.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Container(width: 1, height: 26, color: textColor.withValues(alpha: 0.18)),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      vm != null
                          ? TextField(
                              controller: vm!.scalingLevelCtrls[i],
                              style: levelStyle,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              onChanged: (_) => vm!.syncScalingEntry(i),
                              decoration: InputDecoration.collapsed(
                                  hintText: 'Nível',
                                  hintStyle: levelStyle.copyWith(color: textColor.withValues(alpha: 0.3))),
                            )
                          : Text(entries[i].level, textAlign: TextAlign.center, style: levelStyle),
                      const SizedBox(height: 2),
                      vm != null
                          ? TextField(
                              controller: vm!.scalingValueCtrls[i],
                              style: valueStyle,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              onChanged: (_) => vm!.syncScalingEntry(i),
                              decoration: InputDecoration.collapsed(
                                  hintText: '—',
                                  hintStyle: valueStyle.copyWith(color: textColor.withValues(alpha: 0.3))),
                            )
                          : Text(entries[i].value, textAlign: TextAlign.center, style: valueStyle),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _BottomStat extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final TextEditingController? ctrl;
  final VoidCallback? onSync;
  const _BottomStat({required this.label, required this.value, required this.textColor, this.ctrl, this.onSync});

  @override
  Widget build(BuildContext context) {
    final valueStyle = GoogleFonts.lora(color: textColor, fontSize: 8.5, fontWeight: FontWeight.w600);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
                color: textColor.withValues(alpha: 0.6),
                fontSize: 4.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3)),
        const SizedBox(height: 2),
        ctrl != null
            ? TextField(
                controller: ctrl,
                style: valueStyle,
                textAlign: TextAlign.center,
                onChanged: (_) => onSync?.call(),
                decoration: InputDecoration.collapsed(
                    hintText: '—', hintStyle: valueStyle.copyWith(color: textColor.withValues(alpha: 0.3))),
              )
            : Text(value, textAlign: TextAlign.center, style: valueStyle),
      ],
    );
  }
}

class _BottomDivider extends StatelessWidget {
  final Color color;
  const _BottomDivider({required this.color});
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 24, color: color.withValues(alpha: 0.25));
}

class _ImagePlaceholder extends StatelessWidget {
  final Color textColor;
  final Color frameDark;
  final bool editable;
  const _ImagePlaceholder({required this.textColor, required this.frameDark, this.editable = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: frameDark.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(editable ? Icons.add_photo_alternate_outlined : Icons.auto_fix_high_outlined,
                color: textColor.withValues(alpha: 0.3), size: 32),
            if (editable)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Builder(
                    builder: (ctx) => Text(
                          S.of(ctx).tapToAddImage,
                          style: TextStyle(color: textColor.withValues(alpha: 0.25), fontSize: 7),
                        )),
              ),
          ],
        ),
      ),
    );
  }
}
