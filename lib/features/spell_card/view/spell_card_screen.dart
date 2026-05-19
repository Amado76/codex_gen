import 'package:flutter/material.dart';
import '../view_model/spell_card_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import 'panels/spell_list_panel.dart';
import 'panels/spell_form_panel.dart';
import 'panels/spell_preview_panel.dart';
import '../../../services/export_service.dart';

class SpellCardScreen extends StatefulWidget {
  const SpellCardScreen({super.key});

  @override
  State<SpellCardScreen> createState() => _SpellCardScreenState();
}

class _SpellCardScreenState extends State<SpellCardScreen> {
  final _vm       = SpellCardViewModel();
  final _frontKey = GlobalKey();
  final _backKey  = GlobalKey();

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _handleExportFront() async {
    final name = _vm.current.name.toLowerCase().replaceAll(' ', '_');
    await _vm.exportSinglePng(
      capture: () => captureWidget(_frontKey),
      filename: '${name}_front.png',
    );
  }

  Future<void> _handleExportBack() async {
    final name = _vm.current.name.toLowerCase().replaceAll(' ', '_');
    await _vm.exportSinglePng(
      capture: () => captureWidget(_backKey),
      filename: '${name}_back.png',
    );
  }

  Future<void> _handleExportPdf() async {
    try {
      await _vm.exportPdf(
        captureFront: () => captureWidget(_frontKey),
        captureBack:  () => captureWidget(_backKey),
        goToIndex: (i) async {
          _vm.selectSpell(i);
          await WidgetsBinding.instance.endOfFrame;
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red.shade800),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          return Row(
            children: [
              SpellListPanel(
                spells:          _vm.spells,
                selectedIndex:   _vm.selectedIndex,
                pdfLandscape:    _vm.pdfLandscape,
                isExportingPdf:  _vm.isExportingPdf,
                pdfStatus:       _vm.pdfStatus,
                vm:              _vm,
                onSelectSpell:   _vm.selectSpell,
                onAddSpell:      _vm.addSpell,
                onDuplicateSpell: _vm.duplicateSpell,
                onDeleteSpell:   _vm.deleteSpell,
                onSetLandscape:  _vm.setPdfLandscape,
                onExportPdf:     _handleExportPdf,
              ),
              SpellFormPanel(
                spell: _vm.current,
                vm: _vm,
                onExportFront: _handleExportFront,
                onExportBack:  _handleExportBack,
              ),
              Expanded(
                child: SpellPreviewPanel(
                  spell:       _vm.current,
                  totalSpells: _vm.spells.length,
                  frontKey:    _frontKey,
                  backKey:     _backKey,
                  vm:          _vm,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
