import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/card_data.dart';
import '../../model/card_type.dart';
import '../../view_model/card_editor_viewmodel.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/painters/line_painter.dart';
import '../../../../core/painters/elegant_painter.dart';
import '../../../../core/models/card_background.dart';
import '../../../../core/widgets/stat_icon_widget.dart';
import '../../../../core/widgets/html_text_widget.dart';

class CardBackWidget extends StatelessWidget {
  final CardData cardData;
  final CardEditorViewModel? vm;

  static const double cardWidth  = 252.0;
  static const double cardHeight = 352.0;

  const CardBackWidget({super.key, required this.cardData, this.vm});

  bool get _editable => vm != null;

  Color get _frame      => cardData.frameColor;
  Color get _frameDark  => darkenColor(_frame, 0.20);
  Color get _frameLight => lightenColor(_frame, 0.10);
  Color get _textColor  => cardData.textColorOverride ?? contrastTextColor(_frame);
  Color? get _iconColor => cardData.iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
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
            Positioned.fill(child: CustomPaint(
              painter: cardData.background == CardBackground.elegant
                  ? ElegantPainter(color: _textColor)
                  : const LinePainter(),
            )),
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  _buildStatsRow(),
                  _buildTextArea(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titleStyle = GoogleFonts.cinzel(
      color: _textColor, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 1.2,
      shadows: [Shadow(color: _frameDark.withValues(alpha: 0.7), blurRadius: 4, offset: const Offset(0, 1))],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _editable
              ? TextField(
                  controller: vm!.titleCtrl,
                  style: titleStyle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  onChanged: (_) => vm!.syncFromForm(),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Nome da carta',
                    hintStyle: titleStyle.copyWith(color: _textColor.withValues(alpha: 0.35)),
                  ),
                )
              : Text(cardData.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: titleStyle),
          if (cardData.subtype.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              cardData.subtype,
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(color: _textColor.withValues(alpha: 0.75), fontSize: 8, fontStyle: FontStyle.italic, letterSpacing: 0.8),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final isArmor = cardData.cardType == CardType.armor;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: _frameDark.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _textColor.withValues(alpha: 0.15), width: 1),
          ),
          child: Row(
            children: [
              _BackStatCell(icon: StatIconType.coin,    label: 'Custo', value: cardData.goldValue, textColor: _textColor, iconColor: _iconColor),
              _RowDivider(color: _textColor),
              _BackStatCell(icon: StatIconType.backpack, label: 'Peso',  value: cardData.weight,   textColor: _textColor, iconColor: _iconColor),
              _RowDivider(color: _textColor),
              _BackStatCell(
                icon: isArmor ? StatIconType.shield : StatIconType.damage,
                label: isArmor ? 'CA' : 'Dano',
                value: cardData.damage,
                textColor: _textColor,
                iconColor: _iconColor,
              ),
            ],
          ),
        ),
        if (isArmor && cardData.requirement.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _frameDark.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _textColor.withValues(alpha: 0.12), width: 1),
            ),
            child: Row(
              children: [
                StatIconWidget(type: StatIconType.disadvantage, color: _iconColor, size: 11),
                const SizedBox(width: 6),
                Text('Requisito  ', style: GoogleFonts.cinzel(color: _textColor.withValues(alpha: 0.65), fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                Expanded(
                  child: Text(cardData.requirement,
                      style: GoogleFonts.lora(color: _textColor, fontSize: 8.5, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTextArea() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 4, 10, 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _frameDark.withValues(alpha: 0.5), width: 2),
          boxShadow: [BoxShadow(color: _frameDark.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: SingleChildScrollView(
          child: cardData.backText.isEmpty
              ? Text('Texto da carta...', style: GoogleFonts.lora(color: Colors.black38, fontSize: 9, fontStyle: FontStyle.italic))
              : HtmlTextWidget(
                  html: cardData.backText,
                  baseStyle: GoogleFonts.lora(color: const Color(0xFF1A1A1A), fontSize: 9.5, height: 1.5),
                ),
        ),
      ),
    );
  }
}

// ─── Internal widgets ─────────────────────────────────────────────────────────

class _BackStatCell extends StatelessWidget {
  final StatIconType icon;
  final String label;
  final String value;
  final Color textColor;
  final Color? iconColor;

  const _BackStatCell({required this.icon, required this.label, required this.value, required this.textColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatIconWidget(type: icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(label, style: GoogleFonts.cinzel(color: textColor.withValues(alpha: 0.7), fontSize: 6, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value.isEmpty ? '—' : value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lora(color: textColor, fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  final Color color;
  const _RowDivider({required this.color});
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: color.withValues(alpha: 0.2), margin: const EdgeInsets.symmetric(horizontal: 4));
}
