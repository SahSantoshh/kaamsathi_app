import '../domain/payroll_models.dart';

abstract final class PayrollMockData {
  static List<PayPeriod> periodsForOrg(String orgId) {
    return <PayPeriod>[
      PayPeriod(
        id: 'pp-1',
        orgId: orgId,
        startDate: DateTime(2023, 10, 1),
        endDate: DateTime(2023, 10, 31),
        status: 'locked',
        totalAmount: 450000.0,
        workerCount: 12,
      ),
      PayPeriod(
        id: 'pp-2',
        orgId: orgId,
        startDate: DateTime(2023, 11, 1),
        endDate: DateTime(2023, 11, 30),
        status: 'open',
        totalAmount: 120000.0,
        workerCount: 8,
      ),
      PayPeriod(
        id: 'pp-3',
        orgId: orgId,
        startDate: DateTime(2023, 12, 1),
        endDate: DateTime(2023, 12, 31),
        status: 'open',
        totalAmount: 0.0,
        workerCount: 0,
      ),
    ];
  }

  static PayPeriod? getPeriodById(String orgId, String periodId) {
    try {
      return periodsForOrg(orgId).firstWhere((PayPeriod p) => p.id == periodId);
    } catch (_) {
      return null;
    }
  }
}
