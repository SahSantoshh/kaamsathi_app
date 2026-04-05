import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/attendance_models.dart';

class AttendanceRepository {
  AttendanceRepository();

  final List<AttendanceDay> _attendanceDays = [
    AttendanceDay(
      id: 'day_1',
      orgId: 'org_1',
      engagementId: 'site_1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'locked',
      totalWorkers: 15,
      presentWorkers: 12,
    ),
    AttendanceDay(
      id: 'day_2',
      orgId: 'org_1',
      engagementId: 'site_1',
      date: DateTime.now(),
      status: 'open',
      totalWorkers: 15,
      presentWorkers: 10,
    ),
  ];

  final List<TimePunch> _timePunches = [
    TimePunch(
      id: 'punch_1',
      workerId: 'worker_1',
      attendanceDayId: 'day_1',
      checkIn: DateTime.now().subtract(const Duration(days: 1, hours: 9)),
      checkOut: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      status: 'present',
    ),
    TimePunch(
      id: 'punch_2',
      workerId: 'worker_2',
      attendanceDayId: 'day_1',
      checkIn: DateTime.now().subtract(const Duration(days: 1, hours: 8, minutes: 30)),
      checkOut: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 15)),
      status: 'present',
    ),
  ];

  Future<List<AttendanceDay>> fetchAttendanceDays(String orgId, String engagementId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _attendanceDays
        .where((day) => day.orgId == orgId && day.engagementId == engagementId)
        .toList();
  }

  Future<AttendanceDay?> fetchAttendanceDay(String dayId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    try {
      return _attendanceDays.firstWhere((day) => day.id == dayId);
    } catch (_) {
      return null;
    }
  }

  Future<List<TimePunch>> fetchTimePunches(String dayId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _timePunches.where((punch) => punch.attendanceDayId == dayId).toList();
  }

  Future<void> addAttendanceDay(AttendanceDay day) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _attendanceDays.add(day);
  }

  Future<void> updateTimePunch(TimePunch punch) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _timePunches.indexWhere((p) => p.id == punch.id);
    if (index != -1) {
      _timePunches[index] = punch;
    } else {
      _timePunches.add(punch);
    }
  }

  Future<void> lockAttendanceDay(String dayId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _attendanceDays.indexWhere((day) => day.id == dayId);
    if (index != -1) {
      _attendanceDays[index] = _attendanceDays[index].copyWith(status: 'locked');
    }
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final attendanceDaysProvider = FutureProvider.family<List<AttendanceDay>, ({String orgId, String engagementId})>((ref, args) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.fetchAttendanceDays(args.orgId, args.engagementId);
});

final attendanceDayProvider = FutureProvider.family<AttendanceDay?, String>((ref, dayId) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.fetchAttendanceDay(dayId);
});

final timePunchesProvider = FutureProvider.family<List<TimePunch>, String>((ref, dayId) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.fetchTimePunches(dayId);
});
