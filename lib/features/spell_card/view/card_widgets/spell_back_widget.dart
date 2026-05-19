import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/spell_data.dart';
import '../../view_model/spell_card_viewmodel.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/painters/line_painter.dart';
import '../../../../core/painters/elegant_painter.dart';
import '../../../../core/models/card_background.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/html_text_widget.dart';

class SpellBackWidget extends StatelessWidget {
  final SpellData spell;
  final SpellCardViewModel? vm;

  static const double cardWidth = 252.0;
  static const double cardHeight = 352.0;

  const SpellBackWidget({super.key, required this.spell, this.vm});

  bool get _editable => vm != null;

  Color get _frame => spell.accentColor;
  Color get _frameDark => darkenColor(_frame, 0.20);
  Color get _frameLight => lightenColor(_frame, 0.10);
  Color get _textColor => spell.textColorOverride ?? contrastTextColor(_frame);

  void _sync() => vm?.syncFromForm();

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
                  children: [
                    _buildHeader(s),
                    _buildDivider(),
                    Expanded(child: _buildBody(s)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(S s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 1, 10, 0),
      child: Row(
        children: [
          ClipRect(
            child: SizedBox(
              width: 50,
              height: 50,
              child: Transform.scale(
                scale: 1.10,
                child: Image.asset(
                  spell.school.iconPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _editable
                    ? TextField(
                        controller: vm!.nameCtrl,
                        style: GoogleFonts.cinzel(
                          color: _textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(color: _frameDark.withValues(alpha: 0.6), blurRadius: 3, offset: const Offset(0, 1))
                          ],
                        ),
                        maxLines: 1,
                        onChanged: (_) => _sync(),
                        decoration: InputDecoration.collapsed(hintText: s.spellName),
                      )
                    : Text(spell.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cinzel(
                          color: _textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(color: _frameDark.withValues(alpha: 0.6), blurRadius: 3, offset: const Offset(0, 1))
                          ],
                        )),
                if (spell.subtitle.isNotEmpty)
                  _editable
                      ? TextField(
                          controller: vm!.subtitleCtrl,
                          style: GoogleFonts.lora(
                              color: _textColor.withValues(alpha: 0.72), fontSize: 6, fontStyle: FontStyle.italic),
                          onChanged: (_) => _sync(),
                          decoration: InputDecoration.collapsed(hintText: s.subtitleHint),
                        )
                      : Text(spell.subtitle.toUpperCase(),
                          style: GoogleFonts.lora(
                              color: _textColor.withValues(alpha: 0.72), fontSize: 6, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
      height: 1, margin: const EdgeInsets.symmetric(horizontal: 10), color: _textColor.withValues(alpha: 0.25));

  Widget _buildBody(S s) {
    final bodyStyle = GoogleFonts.lora(color: _textColor.withValues(alpha: 0.92), fontSize: 6.5, height: 1.4);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(label: s.cardDesc, textColor: _textColor),
          const SizedBox(height: 3),
          _editable
              ? TextField(
                  controller: vm!.descriptionCtrl,
                  style: bodyStyle,
                  maxLines: null,
                  onChanged: (_) => _sync(),
                  decoration: InputDecoration.collapsed(
                    hintText: s.descPlaceholder,
                    hintStyle: bodyStyle.copyWith(color: _textColor.withValues(alpha: 0.4)),
                  ),
                )
              : HtmlTextWidget(
                  html: spell.description.isEmpty ? s.descPlaceholder : spell.description,
                  baseStyle:
                      bodyStyle.copyWith(color: spell.description.isEmpty ? _textColor.withValues(alpha: 0.4) : null),
                ),
          if (spell.backScaling.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildDivider(),
            const SizedBox(height: 5),
            _SectionTitle(label: s.cardScaling, textColor: _textColor),
            const SizedBox(height: 3),
            _editable
                ? TextField(
                    controller: vm!.backScalingCtrl,
                    style: bodyStyle,
                    maxLines: null,
                    onChanged: (_) => _sync(),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Texto de escalonamento...',
                      hintStyle: bodyStyle.copyWith(color: _textColor.withValues(alpha: 0.4)),
                    ),
                  )
                : HtmlTextWidget(html: spell.backScaling, baseStyle: bodyStyle),
          ],
          if (spell.howToUse.isNotEmpty || spell.tacticalTips.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildDivider(),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (spell.howToUse.isNotEmpty)
                  Expanded(
                      child: _HowToUseBlock(
                          text: spell.howToUse, textColor: _textColor, ctrl: vm?.howToUseCtrl, onSync: _sync)),
                if (spell.howToUse.isNotEmpty && spell.tacticalTips.isNotEmpty)
                  Container(
                      width: 1,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: _textColor.withValues(alpha: 0.2)),
                if (spell.tacticalTips.isNotEmpty)
                  Expanded(
                      child: _TacticalTipsBlock(
                          text: spell.tacticalTips, textColor: _textColor, ctrl: vm?.tacticalTipsCtrl, onSync: _sync)),
              ],
            ),
          ],
          const SizedBox(height: 6),
          _buildDivider(),
          const SizedBox(height: 5),
          _SectionTitle(label: s.cardInfo, textColor: _textColor),
          const SizedBox(height: 4),
          _InfoRow(spell: spell, textColor: _textColor, classesCtrl: vm?.classesCtrl, onSync: _sync),
          if (spell.lore.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildDivider(),
            const SizedBox(height: 5),
            _LoreBlock(text: spell.lore, textColor: _textColor, ctrl: vm?.loreCtrl, onSync: _sync),
          ],
        ],
      ),
    );
  }
}

// ── Section widgets ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String label;
  final Color textColor;
  const _SectionTitle({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.cinzel(
            color: textColor.withValues(alpha: 0.8), fontSize: 6.5, fontWeight: FontWeight.w700, letterSpacing: 1.2));
  }
}

class _HowToUseBlock extends StatelessWidget {
  final String text;
  final Color textColor;
  final TextEditingController? ctrl;
  final VoidCallback? onSync;
  const _HowToUseBlock({required this.text, required this.textColor, this.ctrl, this.onSync});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final style = GoogleFonts.lora(color: textColor.withValues(alpha: 0.9), fontSize: 6.5, height: 1.35);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(s.cardHowToUse,
          style: GoogleFonts.cinzel(
              color: textColor.withValues(alpha: 0.75), fontSize: 6, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      const SizedBox(height: 3),
      ctrl != null
          ? TextField(
              controller: ctrl,
              style: style,
              maxLines: null,
              onChanged: (_) => onSync?.call(),
              decoration: InputDecoration.collapsed(
                  hintText: s.howToUseSec, hintStyle: style.copyWith(color: textColor.withValues(alpha: 0.35))),
            )
          : Text(text, style: style),
    ]);
  }
}

class _TacticalTipsBlock extends StatelessWidget {
  final String text;
  final Color textColor;
  final TextEditingController? ctrl;
  final VoidCallback? onSync;
  const _TacticalTipsBlock({required this.text, required this.textColor, this.ctrl, this.onSync});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final style = GoogleFonts.lora(color: textColor.withValues(alpha: 0.9), fontSize: 6.5, height: 1.3);
    if (ctrl != null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.cardTips,
            style: GoogleFonts.cinzel(
                color: textColor.withValues(alpha: 0.75),
                fontSize: 6,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
        const SizedBox(height: 3),
        TextField(
          controller: ctrl,
          style: style,
          maxLines: null,
          onChanged: (_) => onSync?.call(),
          decoration: InputDecoration.collapsed(
              hintText: s.tipPerLine, hintStyle: style.copyWith(color: textColor.withValues(alpha: 0.35))),
        ),
      ]);
    }
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(s.cardTips,
          style: GoogleFonts.cinzel(
              color: textColor.withValues(alpha: 0.75), fontSize: 6, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      const SizedBox(height: 3),
      ...lines.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('• ', style: GoogleFonts.lora(color: textColor, fontSize: 6.5, fontWeight: FontWeight.w700)),
              Expanded(child: Text(l.trim(), style: style)),
            ]),
          )),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final SpellData spell;
  final Color textColor;
  final TextEditingController? classesCtrl;
  final VoidCallback? onSync;
  const _InfoRow({required this.spell, required this.textColor, this.classesCtrl, this.onSync});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final labelStyle = GoogleFonts.cinzel(
        color: textColor.withValues(alpha: 0.6), fontSize: 5, fontWeight: FontWeight.w700, letterSpacing: 0.5);
    final valueStyle = GoogleFonts.lora(color: textColor, fontSize: 6.5, fontWeight: FontWeight.w600);

    final cells = <Widget>[
      _infoCell(s.cardSchool, spell.school.label, labelStyle, valueStyle),
      _infoCell(s.cardComponents, spell.components, labelStyle, valueStyle),
      _infoCell(s.cardConc, spell.concentration ? s.yes : s.no, labelStyle, valueStyle),
    ];

    if (spell.classes.isNotEmpty) {
      cells.add(Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.cardClass, style: labelStyle),
          const SizedBox(height: 2),
          classesCtrl != null
              ? TextField(
                  controller: classesCtrl,
                  style: valueStyle,
                  maxLines: 1,
                  onChanged: (_) => onSync?.call(),
                  decoration: InputDecoration.collapsed(
                      hintText: s.classesHint, hintStyle: valueStyle.copyWith(color: textColor.withValues(alpha: 0.3))),
                )
              : Text(spell.classes, style: valueStyle),
        ]),
      ));
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: cells);
  }

  Widget _infoCell(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 2),
        Text(value, style: valueStyle),
      ],
    ));
  }
}

class _LoreBlock extends StatelessWidget {
  final String text;
  final Color textColor;
  final TextEditingController? ctrl;
  final VoidCallback? onSync;
  const _LoreBlock({required this.text, required this.textColor, this.ctrl, this.onSync});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final style = GoogleFonts.lora(
        color: textColor.withValues(alpha: 0.85), fontSize: 6.5, fontStyle: FontStyle.italic, height: 1.3);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(s.cardLore,
          style: GoogleFonts.cinzel(
              color: textColor.withValues(alpha: 0.75), fontSize: 6, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      const SizedBox(height: 2),
      ctrl != null
          ? TextField(
              controller: ctrl,
              style: style,
              maxLines: null,
              onChanged: (_) => onSync?.call(),
              decoration: InputDecoration.collapsed(
                  hintText: s.loreTextField, hintStyle: style.copyWith(color: textColor.withValues(alpha: 0.35))),
            )
          : Text(text, style: style),
    ]);
  }
}
