class AppConfig {
  static const appName = 'UNIGO';
  static const passengerRole = 'passenger';
  // Vision: route < 2km => ₺20, route >= 2km => ₺25. Premium monthly ₺250.
  static const defaultServiceFeeShort = 20.0;
  static const defaultServiceFeeLong = 25.0;
  static const longRouteThresholdKm = 2.0;
  static const defaultPremiumPrice = 250.0;
  static const premiumLongRideFee = 10.0;
  static const defaultCurrency = 'TRY';
  static const defaultProximityKm = 5.0;
}
