import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'card_type.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/card_background.dart';

class CardData {
  final String id;
  final String title;
  final String description;
  final String subtype;
  final String goldValue;
  final String weight;
  final String maestria;
  final String damage;
  final String requirement;
  final String backText;
  final Uint8List? cardImage;
  final Color frameColor;
  final CardType cardType;
  final Color? iconColor;
  final Color? textColorOverride;
  final CardBackground background;

  CardData({
    String? id,
    required this.title,
    this.description = '',
    this.subtype = '',
    this.goldValue = '',
    this.weight = '',
    this.maestria = '',
    this.damage = '',
    this.requirement = '',
    this.backText = '',
    this.cardImage,
    this.frameColor = kDefaultFrameColor,
    this.cardType = CardType.weapon,
    this.iconColor,
    this.textColorOverride,
    this.background = CardBackground.lines,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  CardData copyWith({
    String? title,
    String? description,
    String? subtype,
    String? goldValue,
    String? weight,
    String? maestria,
    String? damage,
    String? requirement,
    String? backText,
    Uint8List? cardImage,
    bool clearImage = false,
    Color? frameColor,
    CardType? cardType,
    Color? iconColor,
    bool clearIconColor = false,
    Color? textColorOverride,
    bool clearTextColor = false,
    CardBackground? background,
  }) {
    return CardData(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      subtype: subtype ?? this.subtype,
      goldValue: goldValue ?? this.goldValue,
      weight: weight ?? this.weight,
      maestria: maestria ?? this.maestria,
      damage: damage ?? this.damage,
      requirement: requirement ?? this.requirement,
      backText: backText ?? this.backText,
      cardImage: clearImage ? null : (cardImage ?? this.cardImage),
      frameColor: frameColor ?? this.frameColor,
      cardType: cardType ?? this.cardType,
      iconColor: clearIconColor ? null : (iconColor ?? this.iconColor),
      textColorOverride: clearTextColor ? null : (textColorOverride ?? this.textColorOverride),
      background: background ?? this.background,
    );
  }
}
