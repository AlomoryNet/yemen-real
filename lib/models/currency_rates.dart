import '../core/constants/app_constants.dart';

/// User-entered reference rates used for *display-only* price estimates.
///
/// All amounts are stored in their original currency. YER is the base, so a
/// conversion multiplies by the source rate and divides by the target rate.
/// The defaults are only a starting point; Settings lets owners replace them
/// with rates they trust. No rate is fetched at runtime.
class CurrencyRates {
  const CurrencyRates({
    this.usdToYer = defaultUsdToYer,
    this.sarToYer = defaultSarToYer,
  });

  static const double defaultUsdToYer = 250;
  static const double defaultSarToYer = 66.7;

  /// Keeps user input usable without allowing zero/negative/NaN divisors.
  static double sanitize(double value, double fallback) {
    if (!value.isFinite || value <= 0 || value > 1000000) return fallback;
    return value;
  }

  final double usdToYer;
  final double sarToYer;

  CurrencyRates copyWith({double? usdToYer, double? sarToYer}) => CurrencyRates(
    usdToYer: usdToYer ?? this.usdToYer,
    sarToYer: sarToYer ?? this.sarToYer,
  );

  double _toYerFactor(String code) => switch (code.toUpperCase()) {
    AppConstants.currencyUsd => usdToYer,
    AppConstants.currencySar => sarToYer,
    _ => 1.0,
  };

  double convert(num amount, String from, String to) {
    final source = _toYerFactor(from);
    final target = _toYerFactor(to);
    if (source <= 0 || target <= 0) return amount.toDouble();
    return amount * source / target;
  }
}
