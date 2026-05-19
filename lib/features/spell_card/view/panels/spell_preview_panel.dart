import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/spell_data.dart';
import '../../view_model/spell_card_viewmodel.dart';
import '../card_widgets/spell_front_widget.dart';
import '../card_widgets/spell_back_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';

class SpellPreviewPanel extends StatelessWidget {
  final SpellData spell;
  final int totalSpells;
  final GlobalKey frontKey;
  final GlobalKey backKey;
  final SpellCardViewModel vm;

  const SpellPreviewPanel({
    super.key,
    required this.spell,
    required this.totalSpells,
    required this.frontKey,
    required this.backKey,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    const nativeW = SpellFrontWidget.cardWidth * 2 + 20.0;
    const nativeH = SpellFrontWidget.cardHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availW = constraints.maxWidth - 40;
        final availH = constraints.maxHeight - 64;
        final scale  = (availW / nativeW).clamp(0.4, availH / nativeH);
        final s = S.of(context);

        return Stack(
          children: [
            // Off-screen read-only cards used exclusively for PNG/PDF export.
            // vm=null ensures no TextFields or cursors appear in the capture.
            Positioned(
              left: -9999,
              top: 0,
              child: Row(
                children: [
                  RepaintBoundary(key: frontKey, child: SpellFrontWidget(spell: spell)),
                  const SizedBox(width: 20),
                  RepaintBoundary(key: backKey,  child: SpellBackWidget(spell: spell)),
                ],
              ),
            ),

            // Interactive cards shown to the user.
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                  child: SizedBox(
                    width: nativeW * scale,
                    child: Row(
                      children: [
                        SizedBox(width: SpellFrontWidget.cardWidth * scale, child: Text(s.front, textAlign: TextAlign.center, style: GoogleFonts.cinzel(color: kAccentBlue, fontSize: 9, letterSpacing: 3))),
                        SizedBox(width: 20 * scale),
                        SizedBox(width: SpellFrontWidget.cardWidth * scale, child: Text(s.back,  textAlign: TextAlign.center, style: GoogleFonts.cinzel(color: kAccentBlue, fontSize: 9, letterSpacing: 3))),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: nativeW * scale,
                      height: nativeH * scale,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: nativeW,
                          height: nativeH,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SpellFrontWidget(spell: spell, vm: vm),
                              const SizedBox(width: 20),
                              SpellBackWidget(spell: spell, vm: vm),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '63.5 × 88.9 mm  •  300 DPI  •  ${s.spellCount(totalSpells)}',
                    style: TextStyle(color: kAccentBlue.withValues(alpha: 0.55), fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
