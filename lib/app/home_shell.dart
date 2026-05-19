import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/l10n/locale_notifier.dart';
import '../core/l10n/app_localizations.dart';
import '../features/card_editor/view/card_editor_screen.dart';
import '../features/spell_card/view/spell_card_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  final _screens = const [
    CardEditorScreen(),
    SpellCardScreen(),
  ];

  Future<void> _handleTabSwitch(int index) async {
    if (index == _tab) return;
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F40),
        title: Text(s.switchTab, style: const TextStyle(color: Colors.white, fontSize: 14)),
        content: Text(s.switchTabMessage, style: const TextStyle(color: Color(0xFFAABBCC), fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel,       style: const TextStyle(color: Color(0xFF6688AA)))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),  child: Text(s.switchAction, style: const TextStyle(color: Color(0xFF4488FF)))),
        ],
      ),
    );
    if (confirmed == true) setState(() => _tab = index);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: kBgDeep,
      body: Row(
        children: [
          _ActivityBar(selected: _tab, onSelect: _handleTabSwitch, s: s),
          Expanded(child: IndexedStack(index: _tab, children: _screens)),
        ],
      ),
    );
  }
}

class _ActivityBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final S s;

  const _ActivityBar({required this.selected, required this.onSelect, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      color: const Color(0xFF060E18),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _Tab(index: 0, selected: selected, onSelect: onSelect, icon: Icons.shield_outlined,       tooltip: s.equipment),
          const SizedBox(height: 4),
          _Tab(index: 1, selected: selected, onSelect: onSelect, icon: Icons.auto_fix_high_outlined, tooltip: s.spellsNav),
          const Spacer(),
          _LangToggle(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, _) {
        return GestureDetector(
          onTap: localeNotifier.toggle,
          child: Tooltip(
            message: lang == 'pt' ? 'Switch to English' : 'Mudar para Português',
            preferBelow: false,
            child: Container(
              width: 36, height: 28,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: kBgSelected.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: kBorderLight),
              ),
              child: Center(
                child: Text(
                  lang.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  final int index;
  final int selected;
  final ValueChanged<int> onSelect;
  final IconData icon;
  final String tooltip;

  const _Tab({required this.index, required this.selected, required this.onSelect, required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    final active = index == selected;
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: GestureDetector(
        onTap: () => onSelect(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: active ? kBgSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: active ? kAccentBlue : Colors.transparent, width: 1),
          ),
          child: Icon(icon, size: 18, color: active ? Colors.white : kTextDim),
        ),
      ),
    );
  }
}
