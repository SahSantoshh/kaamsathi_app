class PayPeriod {
  const PayPeriod({
    required this.id,
    required this.orgId,
    required this.startDate,
    required this.endDate,
    this.status = 'open',
    this.totalAmount = 0.0,
    this.workerCount = 0,
  });

  final String id;
  final String orgId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double totalAmount;
  final int workerCount;

  bool get isLocked => status == 'locked';
}
