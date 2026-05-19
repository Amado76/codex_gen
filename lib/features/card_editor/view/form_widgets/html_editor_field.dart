import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class HtmlEditorField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback? onChanged;

  const HtmlEditorField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
  });

  @override
  State<HtmlEditorField> createState() => _HtmlEditorFieldState();
}

class _HtmlEditorFieldState extends State<HtmlEditorField> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final ctrl = HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed;
        if (!ctrl) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.keyB) {
          _wrap(HardwareKeyboard.instance.isShiftPressed ? 'bi' : 'b');
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyI) {
          _wrap('i');
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _wrap(String tag) {
    final ctrl = widget.controller;
    final sel  = ctrl.selection;
    if (!sel.isValid) return;
    final text     = ctrl.text;
    final before   = text.substring(0, sel.start);
    final selected = text.substring(sel.start, sel.end);
    final after    = text.substring(sel.end);
    final open = '<$tag>';
    final close = '</$tag>';
    ctrl.value = TextEditingValue(
      text: '$before$open$selected$close$after',
      selection: TextSelection.collapsed(
        offset: selected.isEmpty ? sel.start + open.length : sel.end + open.length + close.length,
      ),
    );
    widget.onChanged?.call();
  }

  void _insertBr() {
    final ctrl = widget.controller;
    final sel  = ctrl.selection;
    if (!sel.isValid) return;
    const ins = '<br>\n';
    ctrl.value = TextEditingValue(
      text: ctrl.text.substring(0, sel.start) + ins + ctrl.text.substring(sel.end),
      selection: TextSelection.collapsed(offset: sel.start + ins.length),
    );
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(color: kTextMuted, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1525),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            border: Border.all(color: kBorderStrong, width: 1),
          ),
          child: Row(
            children: [
              _ToolBtn(label: 'B',  tooltip: 'Negrito  Ctrl+B',             bold: true,                  onTap: () => _wrap('b')),
              _ToolBtn(label: 'I',  tooltip: 'Itálico  Ctrl+I',             italic: true,                onTap: () => _wrap('i')),
              _ToolBtn(label: 'BI', tooltip: 'Negrito+Itálico  Ctrl+Shift+B', bold: true, italic: true,  onTap: () => _wrap('bi')),
              const SizedBox(width: 4),
              _ToolBtn(label: '↵', tooltip: 'Quebra de linha <br>', onTap: _insertBr),
              const Spacer(),
              const Text('<b> <i> <bi> <br>', style: TextStyle(color: Color(0xFF3A5A7A), fontSize: 9, fontFamily: 'monospace')),
            ],
          ),
        ),
        TextField(
          controller: widget.controller,
          focusNode: _focus,
          maxLines: 10,
          style: GoogleFonts.sourceCodePro(color: Colors.white, fontSize: 11),
          onChanged: (_) => widget.onChanged?.call(),
          decoration: InputDecoration(
            filled: true,
            fillColor: kBgField,
            contentPadding: const EdgeInsets.all(10),
            border:        OutlineInputBorder(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)), borderSide: const BorderSide(color: kBorderStrong)),
            enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)), borderSide: const BorderSide(color: kBorderStrong)),
            focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)), borderSide: const BorderSide(color: kAccentBlue, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool bold;
  final bool italic;
  final VoidCallback onTap;

  const _ToolBtn({required this.label, required this.tooltip, required this.onTap, this.bold = false, this.italic = false});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          child: Text(label, style: TextStyle(color: kTextMuted, fontSize: 11, fontWeight: bold ? FontWeight.w900 : FontWeight.w400, fontStyle: italic ? FontStyle.italic : FontStyle.normal)),
        ),
      ),
    );
  }
}
