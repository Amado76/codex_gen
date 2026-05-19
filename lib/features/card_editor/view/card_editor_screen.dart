import 'package:flutter/material.dart';
import '../view_model/card_editor_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import 'panels/card_list_panel.dart';
import 'panels/editor_form_panel.dart';
import 'panels/preview_panel.dart';
import '../../../services/export_service.dart';

class CardEditorScreen extends StatefulWidget {
  const CardEditorScreen({super.key});

  @override
  State<CardEditorScreen> createState() => _CardEditorScreenState();
}

// StatefulWidget only to own GlobalKeys and ViewModel lifecycle.
// No business logic or card state lives here.
class _CardEditorScreenState extends State<CardEditorScreen> {
  final _vm       = CardEditorViewModel();
  final _frontKey = GlobalKey();
  final _backKey  = GlobalKey();

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  // ── Export orchestration (needs RenderObject access — stays in View layer) ──

  Future<void> _handleExportFront() async {
    final name = _vm.current.title.toLowerCase().replaceAll(' ', '_');
    await _vm.exportSinglePng(
      capture: () => captureWidget(_frontKey),
      filename: '${name}_front.png',
    );
  }

  Future<void> _handleExportBack() async {
    final name = _vm.current.title.toLowerCase().replaceAll(' ', '_');
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
          _vm.selectCard(i);
          await WidgetsBinding.instance.endOfFrame;
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red.shade800),
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
              CardListPanel(
                cards:           _vm.cards,
                selectedIndex:   _vm.selectedIndex,
                pdfLandscape:    _vm.pdfLandscape,
                isExportingPdf:  _vm.isExportingPdf,
                pdfStatus:       _vm.pdfStatus,
                vm:              _vm,
                onSelectCard:    _vm.selectCard,
                onAddCard:       _vm.addCard,
                onDuplicateCard: _vm.duplicateCard,
                onDeleteCard:    _vm.deleteCard,
                onSetLandscape:  _vm.setPdfLandscape,
                onExportPdf:     _handleExportPdf,
              ),
              EditorFormPanel(
                card:             _vm.current,
                showFrontFields:  _vm.showFrontFields,
                isExporting:      _vm.isExporting,
                titleCtrl:        _vm.titleCtrl,
                subtypeCtrl:      _vm.subtypeCtrl,
                descCtrl:         _vm.descCtrl,
                goldCtrl:         _vm.goldCtrl,
                weightCtrl:       _vm.weightCtrl,
                maestriaCtrl:     _vm.maestriaCtrl,
                damageCtrl:       _vm.damageCtrl,
                requirementCtrl:  _vm.requirementCtrl,
                backTextCtrl:     _vm.backTextCtrl,
                frameHexCtrl:     _vm.frameHexCtrl,
                iconHexCtrl:      _vm.iconHexCtrl,
                textHexCtrl:      _vm.textHexCtrl,
                onFormChanged:    _vm.syncFromForm,
                onToggleSide:     _vm.setShowFrontFields,
                onSetType:        _vm.setCardType,
                onSetFrameColor:  _vm.setFrameColor,
                onApplyFrameHex:  _vm.applyFrameHex,
                onSetIconColor:   _vm.setIconColor,
                onApplyIconHex:   _vm.applyIconHex,
                onClearIconColor: _vm.clearIconColor,
                onSetTextColor:   _vm.setTextColor,
                onApplyTextHex:   _vm.applyTextHex,
                onClearTextColor: _vm.clearTextColor,
                onPickImage:      _vm.pickImage,
                onClearImage:     _vm.clearImage,
                onExportFront:    _handleExportFront,
                onExportBack:     _handleExportBack,
                onSetBackground:  _vm.setBackground,
              ),
              Expanded(
                child: PreviewPanel(
                  card:       _vm.current,
                  totalCards: _vm.cards.length,
                  frontKey:   _frontKey,
                  backKey:    _backKey,
                  vm:         _vm,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
