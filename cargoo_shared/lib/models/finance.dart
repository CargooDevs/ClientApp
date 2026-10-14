class Payment {
  final String paymentId;
  final double amount;
  final String method; // cash, multicaixa, transfer, card
  final bool receivedByPlatform;
  final String type; // ride, hire, cash_ledger

  const Payment({required this.paymentId, required this.amount, this.method = 'cash', this.receivedByPlatform = false, this.type = 'ride'});

  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
        paymentId: map['payment_id'] as String,
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        method: map['method'] as String? ?? 'cash',
        receivedByPlatform: map['received_by_platform'] as bool? ?? false,
        type: map['type'] as String? ?? 'ride',
      );
}

class DriverCashLedgerEntry {
  final String ledgerId;
  final String driverId;
  final double amount;
  final double balanceAfter;
  final DateTime? date;

  const DriverCashLedgerEntry({required this.ledgerId, required this.driverId, required this.amount, required this.balanceAfter, this.date});

  factory DriverCashLedgerEntry.fromMap(Map<String, dynamic> map) => DriverCashLedgerEntry(
        ledgerId: map['ledger_id'] as String,
        driverId: map['driver_id'] as String,
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        balanceAfter: (map['balance_after'] as num?)?.toDouble() ?? 0,
        date: map['date'] != null ? DateTime.tryParse(map['date'] as String) : null,
      );
}

class Rating {
  final String ratingId;
  final String userId;
  final String driverId;
  final String rideId;
  final int? ratingToUser;
  final int? ratingToDriver;

  const Rating({required this.ratingId, required this.userId, required this.driverId, required this.rideId, this.ratingToUser, this.ratingToDriver});
}
