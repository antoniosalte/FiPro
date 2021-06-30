class Settings {
  String rateType;
  String currency;

  Settings({
    required this.rateType,
    required this.currency,
  });

  factory Settings.init(
      [String rateType = "Efectiva", currency = "Soles PEN"]) {
    return Settings(rateType: rateType, currency: currency);
  }
}
