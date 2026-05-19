import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/models/card_background.dart';
// ── Enums ─────────────────────────────────────────────────────────────────────

enum SpellSchool {
  abjuracao,
  advinhacao,
  encantamento,
  evocacao,
  ilusao,
  invocacao,
  necromancia,
  transmutacao,
}

extension SpellSchoolX on SpellSchool {
  String get label {
    switch (this) {
      case SpellSchool.abjuracao:    return 'Abjuração';
      case SpellSchool.advinhacao:   return 'Adivinhação';
      case SpellSchool.encantamento: return 'Encantamento';
      case SpellSchool.evocacao:     return 'Evocação';
      case SpellSchool.ilusao:       return 'Ilusão';
      case SpellSchool.invocacao:    return 'Invocação';
      case SpellSchool.necromancia:  return 'Necromancia';
      case SpellSchool.transmutacao: return 'Transmutação';
    }
  }

  String get iconPath {
    switch (this) {
      case SpellSchool.abjuracao:    return 'assets/icons/schools/abjuration.png';
      case SpellSchool.advinhacao:   return 'assets/icons/schools/divination.png';
      case SpellSchool.encantamento: return 'assets/icons/schools/enchantment.png';
      case SpellSchool.evocacao:     return 'assets/icons/schools/evocation.png';
      case SpellSchool.ilusao:       return 'assets/icons/schools/illusion.png';
      case SpellSchool.invocacao:    return 'assets/icons/schools/conjuration.png';
      case SpellSchool.necromancia:  return 'assets/icons/schools/necromancy.png';
      case SpellSchool.transmutacao: return 'assets/icons/schools/transmutation.png';
    }
  }
}

enum DamageType {
  acid, cold, fire, force, lightning, necrotic, psychic, radiant, thunder, poison,
  bludgeoning, piercing, slashing,
}

extension DamageTypeX on DamageType {
  String get label {
    switch (this) {
      case DamageType.acid:        return 'Ácido';
      case DamageType.cold:        return 'Frio';
      case DamageType.fire:        return 'Fogo';
      case DamageType.force:       return 'Força';
      case DamageType.lightning:   return 'Elétrico';
      case DamageType.necrotic:    return 'Necrótico';
      case DamageType.psychic:     return 'Psíquico';
      case DamageType.radiant:     return 'Radiante';
      case DamageType.thunder:     return 'Trovão';
      case DamageType.poison:      return 'Veneno';
      case DamageType.bludgeoning: return 'Contundente';
      case DamageType.piercing:    return 'Perfurante';
      case DamageType.slashing:    return 'Cortante';
    }
  }

  String get iconPath {
    switch (this) {
      case DamageType.acid:        return 'assets/icons/damage/acid.png';
      case DamageType.cold:        return 'assets/icons/damage/ice.png';
      case DamageType.fire:        return 'assets/icons/damage/fire.png';
      case DamageType.force:       return 'assets/icons/damage/force.png';
      case DamageType.lightning:   return 'assets/icons/damage/lightning.png';
      case DamageType.necrotic:    return 'assets/icons/damage/necrotic.png';
      case DamageType.psychic:     return 'assets/icons/damage/psychic.png';
      case DamageType.radiant:     return 'assets/icons/damage/radiant.png';
      case DamageType.thunder:     return 'assets/icons/damage/thunder.png';
      case DamageType.poison:      return 'assets/icons/damage/poison.png';
      default:                     return 'assets/icons/damage/physical.png';
    }
  }
}

// ── Supporting types ──────────────────────────────────────────────────────────

class ScalingEntry {
  final String level;
  final String value;
  const ScalingEntry({required this.level, required this.value});
  ScalingEntry copyWith({String? level, String? value}) =>
      ScalingEntry(level: level ?? this.level, value: value ?? this.value);
}

// ── SpellData ─────────────────────────────────────────────────────────────────

class SpellData {
  final String id;

  // Identity
  final String name;
  final String subtitle;
  final SpellSchool school;
  final int level;
  final Uint8List? spellImage;

  // Front — stats row (plain text, no icons on card)
  final String castingTime;
  final String range;
  final String duration;
  final String components;
  final bool concentration;

  // Front — effect section
  final String effect;
  final String hitEffect;       // optional; empty = hidden

  // Front — scaling table (optional)
  final List<ScalingEntry> scalingEntries;

  // Front — bottom row
  final String savingThrow;     // "—" or save type text
  final DamageType? damageType; // null = "—"
  final bool hasAttack;
  final bool isRitual;

  // Styling
  final Color accentColor;
  final Color? iconColorOverride;
  final Color? textColorOverride;

  // Back content
  final String description;     // HTML
  final String backScaling;     // optional HTML
  final String howToUse;        // optional plain text
  final String tacticalTips;    // optional, one tip per line → bullets
  final String additionalInfo;  // optional plain text
  final String lore;            // optional italic text
  final String classes;         // e.g. "Sorcerer, Warlock, Wizard"
  final CardBackground background;

  SpellData({
    String? id,
    required this.name,
    this.subtitle    = 'Truque',
    this.school      = SpellSchool.evocacao,
    this.level       = 0,
    this.spellImage,
    this.castingTime = '1 Ação',
    this.range       = '18 m',
    this.duration    = 'Instantânea',
    this.components  = 'V, S',
    this.concentration = false,
    this.effect      = '',
    this.hitEffect   = '',
    this.scalingEntries = const [],
    this.savingThrow = '—',
    this.damageType,
    this.hasAttack   = false,
    this.isRitual    = false,
    this.accentColor = kDefaultSpellAccent,
    this.iconColorOverride,
    this.textColorOverride,
    this.description  = '',
    this.backScaling  = '',
    this.howToUse     = '',
    this.tacticalTips = '',
    this.additionalInfo = '',
    this.lore         = '',
    this.classes      = '',
    this.background   = CardBackground.lines,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  SpellData copyWith({
    String? name,
    String? subtitle,
    SpellSchool? school,
    int? level,
    Uint8List? spellImage,
    bool clearImage = false,
    String? castingTime,
    String? range,
    String? duration,
    String? components,
    bool? concentration,
    String? effect,
    String? hitEffect,
    List<ScalingEntry>? scalingEntries,
    String? savingThrow,
    DamageType? damageType,
    bool clearDamageType = false,
    bool? hasAttack,
    bool? isRitual,
    Color? accentColor,
    Color? iconColorOverride,
    bool clearIconColor = false,
    Color? textColorOverride,
    bool clearTextColor = false,
    String? description,
    String? backScaling,
    String? howToUse,
    String? tacticalTips,
    String? additionalInfo,
    String? lore,
    String? classes,
    CardBackground? background,
  }) {
    return SpellData(
      id: id,
      name:         name         ?? this.name,
      subtitle:     subtitle     ?? this.subtitle,
      school:       school       ?? this.school,
      level:        level        ?? this.level,
      spellImage:   clearImage   ? null : (spellImage ?? this.spellImage),
      castingTime:  castingTime  ?? this.castingTime,
      range:        range        ?? this.range,
      duration:     duration     ?? this.duration,
      components:   components   ?? this.components,
      concentration: concentration ?? this.concentration,
      effect:       effect       ?? this.effect,
      hitEffect:    hitEffect    ?? this.hitEffect,
      scalingEntries: scalingEntries ?? this.scalingEntries,
      savingThrow:  savingThrow  ?? this.savingThrow,
      damageType:   clearDamageType ? null : (damageType ?? this.damageType),
      hasAttack:    hasAttack    ?? this.hasAttack,
      isRitual:     isRitual     ?? this.isRitual,
      accentColor:  accentColor  ?? this.accentColor,
      iconColorOverride: clearIconColor ? null : (iconColorOverride ?? this.iconColorOverride),
      textColorOverride: clearTextColor ? null : (textColorOverride ?? this.textColorOverride),
      description:  description  ?? this.description,
      backScaling:  backScaling  ?? this.backScaling,
      howToUse:     howToUse     ?? this.howToUse,
      tacticalTips: tacticalTips ?? this.tacticalTips,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      lore:         lore         ?? this.lore,
      classes:      classes      ?? this.classes,
      background:   background   ?? this.background,
    );
  }
}

const kDefaultSpellAccent = Color(0xFF1B3A6E);
