class AppSettings {
  final double premiumMonthlyTry;
  final double standardRideFeeShort;
  final double standardRideFeeLong;
  final double premiumRideFeeLong;
  final double premiumRideThresholdKm;
  final bool adsEnabled;
  final String currency;

  const AppSettings({
    this.premiumMonthlyTry = 250,
    this.standardRideFeeShort = 20,
    this.standardRideFeeLong = 25,
    this.premiumRideFeeLong = 10,
    this.premiumRideThresholdKm = 4,
    this.adsEnabled = true,
    this.currency = 'TRY',
  });

  factory AppSettings.fromMap(Map<String, dynamic> m) => AppSettings(
    premiumMonthlyTry: (m['premiumMonthlyTry'] ?? 250).toDouble(),
    standardRideFeeShort: (m['standardRideFeeShort'] ?? 20).toDouble(),
    standardRideFeeLong: (m['standardRideFeeLong'] ?? 25).toDouble(),
    premiumRideFeeLong: (m['premiumRideFeeLong'] ?? 10).toDouble(),
    premiumRideThresholdKm: (m['premiumRideThresholdKm'] ?? 4).toDouble(),
    adsEnabled: m['adsEnabled'] ?? true,
    currency: m['currency'] ?? 'TRY',
  );
}
