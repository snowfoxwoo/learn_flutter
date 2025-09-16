/// Model class representing a water intake entry
class WaterEntry {
  /// Amount of water consumed in milliliters
  final double amount;

  /// Timestamp when the water was consumed
  final DateTime timestamp;

  /// Creates a new water entry
  const WaterEntry({required this.amount, required this.timestamp});

  /// Creates a water entry from JSON
  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts the water entry to JSON
  Map<String, dynamic> toJson() {
    return {'amount': amount, 'timestamp': timestamp.toIso8601String()};
  }

  /// Creates a copy of this water entry with the given fields replaced
  WaterEntry copyWith({double? amount, DateTime? timestamp}) {
    return WaterEntry(
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WaterEntry &&
        other.amount == amount &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => amount.hashCode ^ timestamp.hashCode;

  @override
  String toString() {
    return 'WaterEntry(amount: $amount, timestamp: $timestamp)';
  }
}
