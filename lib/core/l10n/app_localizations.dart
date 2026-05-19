import 'package:flutter/material.dart';
import 'locale_notifier.dart';

class AppLocaleInherited extends InheritedNotifier<LocaleNotifier> {
  const AppLocaleInherited({super.key, required LocaleNotifier super.notifier, required super.child});
}

class S {
  final bool _pt;
  S(String code) : _pt = code == 'pt';

  static S of(BuildContext context) {
    final n = context.dependOnInheritedWidgetOfExactType<AppLocaleInherited>()?.notifier;
    return S(n?.value ?? 'en');
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  String get spells       => _pt ? 'MAGIAS'       : 'SPELLS';
  String get cards        => _pt ? 'CARTAS'       : 'CARDS';
  String get front        => _pt ? 'FRENTE'       : 'FRONT';
  String get back         => _pt ? 'VERSO'        : 'BACK';
  String get equipment    => _pt ? 'Equipamentos' : 'Equipment';
  String get spellsNav    => _pt ? 'Magias'       : 'Spells';

  // ── Actions ───────────────────────────────────────────────────────────────
  String get newSpell     => _pt ? 'Nova Magia'       : 'New Spell';
  String get newCard      => _pt ? 'Nova Carta'       : 'New Card';
  String get duplicate    => _pt ? 'Duplicar'         : 'Duplicate';
  String get delete       => _pt ? 'Apagar'           : 'Delete';
  String get portrait     => _pt ? 'Retrato'          : 'Portrait';
  String get landscape    => _pt ? 'Paisagem'         : 'Landscape';
  String get letterPdf    => _pt ? 'PDF Ofício'       : 'Letter PDF';
  String get frontPng     => _pt ? 'Frente PNG'       : 'Front PNG';
  String get backPng      => _pt ? 'Verso PNG'        : 'Back PNG';
  String get changeImage  => _pt ? 'Trocar'           : 'Change';
  String get selectImage  => _pt ? 'Selecionar Imagem': 'Select Image';
  String get removeImage  => _pt ? 'Remover'          : 'Remove';
  String get auto         => 'Auto';
  String get addLevel     => _pt ? 'Adicionar nível'  : 'Add level';
  String get generating   => _pt ? 'Gerando PDF...'   : 'Generating PDF...';
  String get starting     => _pt ? 'Iniciando...'     : 'Starting...';
  String capturing(int i, int n) => _pt ? 'Capturando $i/$n...' : 'Capturing $i/$n...';

  // ── Placeholders ──────────────────────────────────────────────────────────
  String get noName       => _pt ? '(sem nome)'   : '(no name)';
  String get noTitle      => _pt ? '(sem título)' : '(no title)';

  // ── Dialogs ───────────────────────────────────────────────────────────────
  String get spellEdited          => _pt ? 'Magia editada' : 'Spell edited';
  String get cardEdited           => _pt ? 'Carta editada' : 'Card edited';
  String get switchSpellWarning   => _pt
      ? 'Você tem alterações nesta magia. Deseja ir para outra mesmo assim?'
      : 'You have changes to this spell. Continue anyway?';
  String get switchCardWarning    => _pt
      ? 'Você tem alterações nesta carta. Deseja ir para outra mesmo assim?'
      : 'You have changes to this card. Continue anyway?';
  String get switchTab            => _pt ? 'Trocar de aba'  : 'Switch tab';
  String get switchTabMessage     => _pt
      ? 'Seu trabalho está preservado — as cartas e magias ficam salvas ao trocar de aba.'
      : 'Your work is preserved — cards and spells are saved when switching tabs.';
  String get cancel               => _pt ? 'Cancelar'  : 'Cancel';
  String get continueAction       => _pt ? 'Continuar' : 'Continue';
  String get switchAction         => _pt ? 'Trocar'    : 'Switch';

  // ── Counts ────────────────────────────────────────────────────────────────
  String spellCount(int n) => _pt ? '$n magia${n != 1 ? 's' : ''}' : '$n spell${n != 1 ? 's' : ''}';
  String cardCount(int n)  => _pt ? '$n carta${n != 1 ? 's' : ''}' : '$n card${n != 1 ? 's' : ''}';

  // ── Tooltips ──────────────────────────────────────────────────────────────
  String get landscapeTooltip => _pt
      ? 'Ofício Paisagem: 4 cartas/página (2×2)'
      : 'Landscape Letter: 4 cards/page (2×2)';
  String get portraitTooltip  => _pt
      ? 'Ofício Retrato: 3 cartas/página (1×3)'
      : 'Portrait Letter: 3 cards/page (1×3)';

  // ── Form sections ─────────────────────────────────────────────────────────
  String get identity         => _pt ? 'IDENTIDADE'              : 'IDENTITY';
  String get statsTopRow      => _pt ? 'STATS (linha de cima)'   : 'STATS (top row)';
  String get effectSection    => _pt ? 'EFEITO'                  : 'EFFECT';
  String get scalingOptional  => _pt ? 'ESCALONAMENTO (opcional)': 'SCALING (optional)';
  String get statsBottomRow   => _pt ? 'STATS (linha de baixo)'  : 'STATS (bottom row)';
  String get imageSection     => _pt ? 'IMAGEM'                  : 'IMAGE';
  String get frameColorSec    => _pt ? 'COR DO FRAME'            : 'FRAME COLOR';
  String get backgroundSec    => _pt ? 'FUNDO'                   : 'BACKGROUND';
  String get iconColorSec     => _pt ? 'COR DOS ÍCONES'          : 'ICON COLOR';
  String get textColorSec     => _pt ? 'COR DO TEXTO'            : 'TEXT COLOR';
  String get levelLabel       => _pt ? 'NÍVEL'                   : 'LEVEL';
  String get descriptionSec   => _pt ? 'DESCRIÇÃO'               : 'DESCRIPTION';
  String get scalingBack      => _pt ? 'ESCALONAMENTO (opcional)': 'SCALING (optional)';
  String get howToUseSec      => _pt ? 'COMO USAR (opcional)'    : 'HOW TO USE (optional)';
  String get tacticalTipsSec  => _pt ? 'DICAS TÁTICAS (opcional)': 'TACTICAL TIPS (optional)';
  String get informationSec   => _pt ? 'INFORMAÇÕES'             : 'INFORMATION';
  String get loreSec          => _pt ? 'LORE (opcional)'         : 'LORE (optional)';
  String get typeSec          => _pt ? 'TIPO'                    : 'TYPE';

  // ── Spell form fields ─────────────────────────────────────────────────────
  String get spellSchool      => _pt ? 'Escola de Magia'              : 'Spell School';
  String get spellName        => _pt ? 'Nome da Magia'                : 'Spell Name';
  String get subtitleHint     => _pt ? 'Subtítulo (ex: Truque)'       : 'Subtitle (e.g. Cantrip)';
  String get castingTime      => _pt ? 'Tempo de Conjuração'          : 'Casting Time';
  String get rangeField       => _pt ? 'Alcance'                      : 'Range';
  String get durationField    => _pt ? 'Duração'                      : 'Duration';
  String get componentsField  => _pt ? 'Componentes'                  : 'Components';
  String get concentration    => _pt ? 'Concentração'                 : 'Concentration';
  String get effectText       => _pt ? 'Efeito (texto principal)'     : 'Effect (main text)';
  String get hitEffectField   => _pt ? 'Acerto (opcional)'            : 'Hit effect (optional)';
  String get savingThrow      => _pt ? 'Salvaguarda'                  : 'Saving Throw';
  String get damageTypeField  => _pt ? 'Tipo de Dano'                 : 'Damage Type';
  String get magicAttack      => _pt ? 'Ataque Mágico'                : 'Magic Attack';
  String get ritual           => 'Ritual';
  String get classesHint      => _pt ? 'Classes (ex: Feiticeiro, Mago)': 'Classes (e.g. Sorcerer, Wizard)';
  String get additionalInfo   => _pt ? 'Informações adicionais (opcional)': 'Additional info (optional)';
  String get loreTextField    => _pt ? 'Texto de lore'                : 'Lore text';
  String get contentHtml      => _pt ? 'Conteúdo (HTML)'             : 'Content (HTML)';
  String get scalingTextHtml  => _pt ? 'Texto (HTML, opcional)'       : 'Text (HTML, optional)';
  String get tipPerLine       => _pt ? 'Uma dica por linha'           : 'One tip per line';
  String get levelExample     => _pt ? 'Nível (ex: 5º Nível)'        : 'Level (e.g. 5th Level)';
  String get valueExample     => _pt ? 'Valor (ex: 2d10)'            : 'Value (e.g. 2d10)';
  String get noneLabel        => _pt ? '— Nenhum —'                  : '— None —';

  // ── Card editor fields ────────────────────────────────────────────────────
  String get weapon           => _pt ? 'Arma'          : 'Weapon';
  String get armor            => _pt ? 'Armadura'      : 'Armor';
  String get cardName         => _pt ? 'Nome'          : 'Name';
  String get cardSubtype      => _pt ? 'Subtipo (ex: Arma Marcial)' : 'Subtype (e.g. Martial Weapon)';
  String get goldValueHint    => _pt ? 'Valor (ex: 10 gp)'          : 'Value (e.g. 10 gp)';
  String get weightHint       => _pt ? 'Peso (ex: 4 lb.)'           : 'Weight (e.g. 4 lb.)';
  String get mastery          => _pt ? 'Maestria'      : 'Mastery';
  String get damageCA         => _pt ? 'Dano / CA'     : 'Damage / AC';
  String get requirementHint  => _pt ? 'Requisito (ex: Força 15)'   : 'Requirement (e.g. Strength 15)';
  String get backTextLabel    => _pt ? 'Texto do verso (HTML)'       : 'Card back text (HTML)';

  // ── Background names ──────────────────────────────────────────────────────
  String get bgLines          => _pt ? 'Linhas'    : 'Lines';
  String get bgElegant        => _pt ? 'Elegante'  : 'Elegant';

  // ── Card widget labels (inside the card itself) ───────────────────────────
  String get statTime         => _pt ? 'TEMPO'        : 'TIME';
  String get statRange        => _pt ? 'ALCANCE'      : 'RANGE';
  String get statDuration     => _pt ? 'DURAÇÃO'      : 'DURATION';
  String get statComp         => 'COMP.';
  String get statConc         => 'Conc.';
  String get statRitual       => 'Ritual';
  String get yes              => _pt ? 'Sim'          : 'Yes';
  String get no               => _pt ? 'Não'          : 'No';

  String get cardEffect       => _pt ? 'EFEITO'       : 'EFFECT';
  String get cardScaling      => _pt ? 'ESCALONAMENTO': 'SCALING';
  String get cardHit          => _pt ? 'ACERTO'       : 'HIT';
  String get cardSave         => _pt ? 'SALVAGUARDA'  : 'SAVE';
  String get cardType         => _pt ? 'TIPO'         : 'TYPE';
  String get cardAttack       => _pt ? 'ATAQUE'       : 'ATTACK';

  String get cardDesc         => _pt ? 'DESCRIÇÃO'    : 'DESCRIPTION';
  String get cardInfo         => _pt ? 'INFORMAÇÕES'  : 'INFORMATION';
  String get cardSchool       => _pt ? 'ESCOLA'       : 'SCHOOL';
  String get cardComponents   => _pt ? 'COMPONENTES'  : 'COMPONENTS';
  String get cardConc         => _pt ? 'CONCENTRAÇÃO' : 'CONCENTRATION';
  String get cardClass        => _pt ? 'CLASSE'       : 'CLASS';
  String get cardHowToUse     => _pt ? 'COMO USAR'    : 'HOW TO USE';
  String get cardTips         => _pt ? 'DICAS TÁTICAS': 'TACTICAL TIPS';
  String get cardLore         => 'LORE';

  String get tapToAddImage    => _pt ? 'Toque para adicionar imagem'  : 'Tap to add image';
  String get describeEffect   => _pt ? 'Descreva o efeito da magia aqui.' : 'Describe the spell effect here.';
  String get descPlaceholder  => _pt ? 'Descrição da magia...'        : 'Spell description...';

  // ── ViewModel defaults (used without BuildContext) ─────────────────────────
  String get duplicateSuffix      => _pt ? '(cópia)'        : '(copy)';
  String get defaultSubtitle      => _pt ? 'Truque'          : 'Cantrip';
  String get defaultCastingTime   => _pt ? '1 Ação'          : '1 Action';
  String get defaultRange         => _pt ? '18 m'            : '60 ft.';
  String get defaultDuration      => _pt ? 'Instantânea'     : 'Instantaneous';
  String get defaultWeaponSubtype => _pt ? 'Arma Marcial'    : 'Martial Weapon';
  String get defaultArmorSubtype  => _pt ? 'Armadura Média'  : 'Medium Armor';
}
