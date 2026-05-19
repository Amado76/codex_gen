import 'package:flutter/material.dart';

enum StatIconType { coin, backpack, target, disadvantage, damage, shield }

class StatIconWidget extends StatelessWidget {
  final StatIconType type;
  final Color? color;
  final double size;

  const StatIconWidget({
    super.key,
    required this.type,
    this.color,
    this.size = 18,
  });

  String get _path {
    switch (type) {
      case StatIconType.coin:         return 'assets/icons/bag.png';
      case StatIconType.backpack:     return 'assets/icons/backpack.png';
      case StatIconType.target:       return 'assets/icons/target.png';
      case StatIconType.disadvantage: return 'assets/icons/x.png';
      case StatIconType.damage:       return 'assets/icons/attack.png';
      case StatIconType.shield:       return 'assets/icons/shield.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _path,
      width: size,
      height: size,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
    );
  }
}
