import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for fetching exchange rates
/// Uses free fawazahmed0/currency-api (no API key required)
/// Fallback to Open Exchange Rates API if needed
class ExchangeRateService {
  // Free API (no key required) - primary source
  static const String _freeApiUrl =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json';
  static const String _freeApiFallbackUrl =
      'https://latest.currency-api.pages.dev/v1/currencies/usd.json';

  // Open Exchange Rates API - requires API key
  static const String _openExchangeUrl = 'https://openexchangerates.org/api';

  /// Fetch the current USD to BDT exchange rate using FREE API (no key required)
  /// Returns the rate (1 USD = X BDT)
  /// Throws exception on failure
  Future<double> fetchUsdToBdtRateFree() async {
    try {
      // Try primary CDN first
      var response = await http.get(Uri.parse(_freeApiUrl));

      // If primary fails, try fallback
      if (response.statusCode != 200) {
        response = await http.get(Uri.parse(_freeApiFallbackUrl));
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final usdRates = data['usd'] as Map<String, dynamic>?;

        if (usdRates != null && usdRates.containsKey('bdt')) {
          return (usdRates['bdt'] as num).toDouble();
        } else {
          throw ExchangeRateException('BDT rate not found in response');
        }
      } else {
        throw ExchangeRateException(
          'Failed to fetch rate: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw ExchangeRateException('Network error: ${e.message}');
    } catch (e) {
      if (e is ExchangeRateException) rethrow;
      throw ExchangeRateException('Unexpected error: $e');
    }
  }

  /// Fetch the current USD to BDT exchange rate using Open Exchange Rates API
  /// Requires API key
  /// Returns the rate (1 USD = X BDT)
  /// Throws exception on failure
  Future<double> fetchUsdToBdtRate(String apiKey) async {
    // If no API key provided, use free API
    if (apiKey.isEmpty) {
      return fetchUsdToBdtRateFree();
    }

    try {
      final url = Uri.parse('$_openExchangeUrl/latest.json?app_id=$apiKey&symbols=BDT');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>?;

        if (rates != null && rates.containsKey('BDT')) {
          return (rates['BDT'] as num).toDouble();
        } else {
          throw ExchangeRateException('BDT rate not found in response');
        }
      } else if (response.statusCode == 401) {
        throw ExchangeRateException('Invalid API key');
      } else if (response.statusCode == 429) {
        throw ExchangeRateException('API rate limit exceeded');
      } else {
        throw ExchangeRateException(
          'Failed to fetch rate: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw ExchangeRateException('Network error: ${e.message}');
    } catch (e) {
      if (e is ExchangeRateException) rethrow;
      throw ExchangeRateException('Unexpected error: $e');
    }
  }

  /// Validate an API key by making a test request
  Future<bool> validateApiKey(String apiKey) async {
    try {
      await fetchUsdToBdtRate(apiKey);
      return true;
    } on ExchangeRateException {
      return false;
    }
  }
}

/// Custom exception for exchange rate errors
class ExchangeRateException implements Exception {
  final String message;
  ExchangeRateException(this.message);

  @override
  String toString() => 'ExchangeRateException: $message';
}
