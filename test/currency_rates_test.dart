import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/core/utils/formatters.dart';
import 'package:yemen_real_estate_portal/models/currency_rates.dart';

void main() {
  group('CurrencyRates', () {
    test('uses YER as the base and applies user-entered rates both ways', () {
      const rates = CurrencyRates(usdToYer: 250, sarToYer: 66.7);

      expect(rates.convert(100, AppConstants.currencyYer, AppConstants.currencyYer),
          100);
      expect(rates.convert(2, AppConstants.currencyUsd, AppConstants.currencyYer),
          500);
      expect(rates.convert(500, AppConstants.currencyYer, AppConstants.currencyUsd),
          2);
      expect(
        rates.convert(250 / 66.7, AppConstants.currencySar,
            AppConstants.currencyYer),
        closeTo(250, 0.00001),
      );
      expect(rates.convert(250, AppConstants.currencyUsd, AppConstants.currencySar),
          closeTo(250 / 66.7 * 250, 0.00001));
    });

    test('sanitize rejects non-finite, zero and extreme values', () {
      expect(
        CurrencyRates.sanitize(0, CurrencyRates.defaultUsdToYer),
        CurrencyRates.defaultUsdToYer,
      );
      expect(
        CurrencyRates.sanitize(double.nan, CurrencyRates.defaultUsdToYer),
        CurrencyRates.defaultUsdToYer,
      );
      expect(
        CurrencyRates.sanitize(1e9, CurrencyRates.defaultSarToYer),
        CurrencyRates.defaultSarToYer,
      );
      expect(CurrencyRates.sanitize(275.5, 250), 275.5);
    });
  });

  group('Formatters.formatDisplayPrice', () {
    const rates = CurrencyRates(usdToYer: 250, sarToYer: 50);

    test('leaves prices unchanged when the preferred currency matches', () {
      expect(
        Formatters.formatDisplayPrice(100000, 'YER', 'YER', rates),
        Formatters.formatCurrency(100000, 'YER'),
      );
    });

    test('prefixes estimates with ≈ and uses the preferred currency', () {
      final label = Formatters.formatDisplayPrice(100000, 'YER', 'USD', rates);
      expect(label.startsWith('≈ '), isTrue);
      expect(label, contains('دولار أمريكي'));

      final sar = Formatters.formatDisplayPrice(20, 'USD', 'SAR', rates);
      expect(sar, startsWith('≈ '));
      expect(sar, contains('ريال سعودي'));
    });

    test('unknown codes fall back to YER without crashing', () {
      final label = Formatters.formatDisplayPrice(1000, 'XXX', 'YER', rates);
      expect(label, Formatters.formatCurrency(1000, 'XXX'));
    });
  });
}
