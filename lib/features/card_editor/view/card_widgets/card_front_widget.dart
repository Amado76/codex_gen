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

class CardFrontWidget extends StatelessWidget {
  final CardData cardData;
  final CardEditorViewModel? vm;

  static const double cardWidth = 252.0;
  static const double cardHeight = 352.0;

  const CardFrontWidget({super.key, required this.cardData, this.vm});

  bool get _editable => vm != null;

  Color get _frame => cardData.frameColor;
  Color get _frameDark => darkenColor(_frame, 0.20);
  Color get _frameLight => lightenColor(_frame, 0.10);
  Color get _textColor => cardData.textColorOverride ?? contrastTextColor(_frame);
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
            Positioned.fill(
                child: CustomPaint(
              painter: cardData.background == CardBackground.elegant
                  ? ElegantPainter(color: _textColor)
                  : const LinePainter(),
            )),
            Positioned.fill(
              child: Column(
                children: [
                  _buildTitle(),
                  _buildImageArea(),
                  if (cardData.description.isNotEmpty) _buildDescription(),
                  _buildStats(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final style = GoogleFonts.cinzel(
      color: _textColor,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      shadows: [Shadow(color: _frameDark.withValues(alpha: 0.7), blurRadius: 4, offset: const Offset(0, 1))],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: _editable
          ? TextField(
              controller: vm!.titleCtrl,
              style: style,
              textAlign: TextAlign.center,
              maxLines: 1,
              onChanged: (_) => vm!.syncFromForm(),
              decoration: InputDecoration.collapsed(
                hintText: 'Nome da carta',
                hintStyle: style.copyWith(color: _textColor.withValues(alpha: 0.35)),
              ),
            )
          : Text(cardData.title,
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: style),
    );
  }

  Widget _buildImageArea() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GestureDetector(
          onTap: _editable ? vm!.pickImage : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _frameDark.withValues(alpha: 0.55), width: 2),
              boxShadow: [
                BoxShadow(color: _frameDark.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 3))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: cardData.cardImage != null
                  ? Image.memory(cardData.cardImage!, fit: BoxFit.cover, filterQuality: FilterQuality.high, isAntiAlias: true)
                  : _CardPlaceholder(isArmor: cardData.cardType == CardType.armor, editable: _editable),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 3),
      child: Text(
        cardData.description,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.lora(
            color: _textColor.withValues(alpha: 0.92), fontSize: 9.5, letterSpacing: 0.8, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStats() {
    final isArmor = cardData.cardType == CardType.armor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
      child: Row(
        children: [
          Expanded(
              child: _StatCell(
                  icon: StatIconType.coin, label: cardData.goldValue, textColor: _textColor, iconColor: _iconColor)),
          _Divider(color: _textColor.withValues(alpha: 0.3)),
          Expanded(
              child: _StatCell(
                  icon: isArmor ? StatIconType.disadvantage : StatIconType.target,
                  label: cardData.maestria,
                  textColor: _textColor,
                  iconColor: _iconColor)),
          _Divider(color: _textColor.withValues(alpha: 0.3)),
          Expanded(
              child: _StatCell(
                  icon: isArmor ? StatIconType.shield : StatIconType.damage,
                  label: cardData.damage,
                  textColor: _textColor,
                  iconColor: _iconColor)),
        ],
      ),
    );
  }
}

// ─── Internal widgets ─────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final StatIconType icon;
  final String label;
  final Color textColor;
  final Color? iconColor;

  const _StatCell({required this.icon, required this.label, required this.textColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatIconWidget(type: icon, color: iconColor, size: 17),
        const SizedBox(width: 5),
        Flexible(
          child: Text(label,
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  GoogleFonts.lora(color: textColor, fontSize: 8.5, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 22, color: color);
}

class _CardPlaceholder extends StatelessWidget {
  final bool isArmor;
  final bool editable;
  const _CardPlaceholder({required this.isArmor, this.editable = false});

  @override
  Widget build(BuildContext context) {
    const grey = Color(0xFFBBBBBB);
    const darkGrey = Color(0xFF888888);

    final rows = isArmor
        ? const [
            _Row(StatIconType.coin, 'Custo', '10 gp'),
            _Row(StatIconType.backpack, 'Peso', '6 lb.'),
            _Row(StatIconType.shield, 'CA', '16'),
            _Row(StatIconType.disadvantage, 'Desvantagem', 'Sim/Não'),
          ]
        : const [
            _Row(StatIconType.coin, 'Custo', '10 gp'),
            _Row(StatIconType.backpack, 'Peso', '4 lb.'),
            _Row(StatIconType.damage, 'Dano', '1d8, cortante'),
            _Row(StatIconType.target, 'Maestria', 'Empurrar'),
          ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isArmor ? 'Armadura' : 'Arma',
              style: GoogleFonts.cinzel(color: grey, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Container(height: 1, color: const Color(0xFFE0E0E0)),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  StatIconWidget(type: r.icon, size: 16),
                  const SizedBox(width: 8),
                  Text('${r.label}:',
                      style: GoogleFonts.lora(color: darkGrey, fontSize: 9, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  Text(r.example, style: GoogleFonts.lora(color: grey, fontSize: 9)),
                ]),
              )),
          const Spacer(),
          Text(
            editable ? 'Toque para adicionar imagem' : 'Selecione uma imagem\npara preencher esta área.',
            style: GoogleFonts.lora(color: const Color(0xFFCCCCCC), fontSize: 7.5, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _Row {
  final StatIconType icon;
  final String label;
  final String example;
  const _Row(this.icon, this.label, this.example);
}
