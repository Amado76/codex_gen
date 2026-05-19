import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/spell_data.dart';
import '../../view_model/spell_card_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';

class SpellListPanel extends StatelessWidget {
  final List<SpellData> spells;
  final int selectedIndex;
  final bool pdfLandscape;
  final bool isExportingPdf;
  final String pdfStatus;
  final SpellCardViewModel vm;
  final ValueChanged<int> onSelectSpell;
  final VoidCallback onAddSpell;
  final VoidCallback onDuplicateSpell;
  final VoidCallback onDeleteSpell;
  final ValueChanged<bool> onSetLandscape;
  final VoidCallback onExportPdf;

  const SpellListPanel({
    super.key,
    required this.spells,
    required this.selectedIndex,
    required this.pdfLandscape,
    required this.isExportingPdf,
    required this.pdfStatus,
    required this.vm,
    required this.onSelectSpell,
    required this.onAddSpell,
    required this.onDuplicateSpell,
    required this.onDeleteSpell,
    required this.onSetLandscape,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      width: 180,
      color: kBgSidebar,
      child: Column(
        children: [
          _buildHeader(s),
          Expanded(child: _buildList(s)),
          _buildFooter(s),
        ],
      ),
    );
  }

  Widget _buildHeader(S s) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF06101A),
        border: Border(bottom: BorderSide(color: kBorderLight, width: 1)),
      ),
      child: Text(s.spells, style: GoogleFonts.cinzel(color: kAccentGold, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
    );
  }

  Future<void> _handleSelect(BuildContext context, int index) async {
    if (index == selectedIndex) return;
    if (vm.isDirty) {
      final s = S.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0D1F40),
          title: Text(s.spellEdited, style: const TextStyle(color: Colors.white, fontSize: 14)),
          content: Text(s.switchSpellWarning, style: const TextStyle(color: Color(0xFFAABBCC), fontSize: 12)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel,         style: const TextStyle(color: Color(0xFF6688AA)))),
            TextButton(onPressed: () => Navigator.pop(ctx, true),  child: Text(s.continueAction, style: const TextStyle(color: Color(0xFF4488FF)))),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    onSelectSpell(index);
  }

  Widget _buildList(S s) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: spells.length,
      itemBuilder: (context, i) {
        final sel = i == selectedIndex;
        final sp = spells[i];
        return GestureDetector(
          onTap: () => _handleSelect(context, i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? kBgSelected : kBgCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: sel ? kAccentBlue : kBorderLight, width: 1),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: sp.accentColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Image.asset(sp.school.iconPath, width: 10, height: 10, color: sel ? Colors.white : kTextMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    sp.name.isEmpty ? s.noName : sp.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: sel ? Colors.white : kTextMuted, fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(S s) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _btn(Icons.add,            s.newSpell,  onAddSpell),
          const SizedBox(height: 4),
          _btn(Icons.copy_rounded,   s.duplicate, onDuplicateSpell),
          const SizedBox(height: 4),
          _btn(Icons.delete_outline, s.delete,    onDeleteSpell, danger: true),
          const SizedBox(height: 8),
          Row(children: [
            _orientBtn(Icons.crop_portrait,  s.portrait,  !pdfLandscape, () => onSetLandscape(false)),
            const SizedBox(width: 4),
            _orientBtn(Icons.crop_landscape, s.landscape, pdfLandscape,  () => onSetLandscape(true)),
          ]),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isExportingPdf ? null : onExportPdf,
              icon: isExportingPdf
                  ? const SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.picture_as_pdf, size: 14),
              label: Text(isExportingPdf ? pdfStatus : s.letterPdf, style: GoogleFonts.cinzel(fontSize: 9, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 13),
        label: Text(label, style: const TextStyle(fontSize: 10)),
        style: OutlinedButton.styleFrom(
          foregroundColor: danger ? const Color(0xFFAA5544) : kTextMuted,
          side: BorderSide(color: danger ? const Color(0xFF6A2A1A) : kBorderLight),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }

  Widget _orientBtn(IconData icon, String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF5A1A1A) : const Color(0xFF0D1A30),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: active ? const Color(0xFFAA4444) : kBorderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: active ? Colors.white : kTextDim),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: active ? Colors.white : kTextDim, fontSize: 9, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
