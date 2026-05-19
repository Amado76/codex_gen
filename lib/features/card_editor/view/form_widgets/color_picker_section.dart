import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class ColorSwatchPicker extends StatelessWidget {
  final Color selected;
  final List<Color> presets;
  final ValueChanged<Color> onColorSelected;

  const ColorSwatchPicker({
    super.key,
    required this.selected,
    required this.presets,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: presets.map((c) {
        final sel = selected == c;
        return GestureDetector(
          onTap: () => onColorSelected(c),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: sel ? Colors.white : Colors.white.withValues(alpha: 0.15),
                width: sel ? 2.5 : 1,
              ),
            ),
            child: sel ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
        );
      }).toList(),
    );
  }
}

class HexColorInput extends StatelessWidget {
  final Color preview;
  final TextEditingController controller;
  final ValueChanged<String> onHexChanged;

  const HexColorInput({
    super.key,
    required this.preview,
    required this.controller,
    required this.onHexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: preview,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          ),
        ),
        const SizedBox(width: 6),
        const Text('#', style: TextStyle(color: kTextMuted, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]'))],
            onChanged: onHexChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: kBgField,
              counterText: '',
              hintText: 'RRGGBB',
              hintStyle: const TextStyle(color: Color(0xFF445566)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              border:        OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: kBorderStrong)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: kBorderStrong)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: kAccentBlue, width: 1.5)),
            ),
          ),
        ),
      ],
    );
  }
}
