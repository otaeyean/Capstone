class StockPrice {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  StockPrice({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory StockPrice.fromJson(Map<String, dynamic> json) {
    return StockPrice(
      date: DateTime.parse(json['date']),
      open: json['openPrice'].toDouble(),
      high: json['highPrice'].toDouble(),
      low: json['lowPrice'].toDouble(),
      close: json['closePrice'].toDouble(),
      volume: json['volume'],
    );
  }
}
