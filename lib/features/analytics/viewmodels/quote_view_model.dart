import 'package:flutter/foundation.dart';

import 'package:habit_control/features/analytics/data/stoic_quote_service.dart';

/// Loads a short stoic quote on demand and notifies when ready.
class QuoteViewModel extends ChangeNotifier {
  QuoteViewModel({StoicQuoteService? service})
    : _service = service ?? StoicQuoteService();

  final StoicQuoteService _service;

  String _text = '';
  String _author = '';

  String get text => _text;
  String get author => _author;
  bool get hasQuote => _text.isNotEmpty && _author.isNotEmpty;

  /// Fetches a new quote. On failure leaves text/author empty.
  Future<void> load({int maxWords = 20}) async {
    try {
      final quote = await _service.fetchShortRandomQuote(maxWords: maxWords);
      _text = quote.text.toUpperCase();
      _author = quote.author.toUpperCase();
    } catch (_) {
      _text = '';
      _author = '';
    }
    notifyListeners();
  }
}
