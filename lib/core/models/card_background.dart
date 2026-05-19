enum CardBackground { lines, elegant }

extension CardBackgroundX on CardBackground {
  String get label {
    switch (this) {
      case CardBackground.lines:   return 'Linhas';
      case CardBackground.elegant: return 'Elegante';
    }
  }
}
