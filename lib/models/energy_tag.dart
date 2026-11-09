/// Brainpower required for a routine block.
enum EnergyTag {
  low,
  high;

  static EnergyTag fromSheet(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'high':
        return EnergyTag.high;
      case 'low':
      default:
        return EnergyTag.low;
    }
  }

  String toSheet() => name;
}
