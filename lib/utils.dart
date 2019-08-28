String formatQuotePrice(String price) {
  final quotePrice = double.parse(price);
  return quotePrice < 1.0
      ? quotePrice.toStringAsFixed(8)
      : quotePrice.toStringAsFixed(2);
}
