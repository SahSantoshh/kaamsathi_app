import 'package:flutter/foundation.dart';

@immutable
class AttendanceDay {
  const AttendanceDay({
    required this.id,
    required this.orgId,
    required this.engagementId,
    required this.date,
    this.status = 'open',
    this.totalWorkers = 0,
    this.presentWorkers = 0,
  });

  final String id;
  final String orgId;
  final String engagementId; // Refers to a specific project or engagement
  final DateTime date;
  final String status;
  final int totalWorkers;
  final int presentWorkers;

  bool get isLocked => status == 'locked';

  AttendanceDay copyWith({
    String? status,
    int? totalWorkers,
    int? presentWorkers,
  }) {
    return AttendanceDay(
      id: id,
      orgId: orgId,
      engagementId: engagementId,
      date: date,
      status: status ?? this.status,
      totalWorkers: totalWorkers ?? this.totalWorkers,
      presentWorkers: presentWorkers ?? this.presentWorkers,
    );
  }
}

@immutable
class TimePunch {
  const TimePunch({
    required this.id,
    required this.workerId,
    required this.attendanceDayId,
    this.checkIn,
    this.checkOut,
    this.status = 'pending',
    this.note,
  });

  final String id;
  final String workerId;
  final String attendanceDayId;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status; // e.g., 'present', 'absent', 'half_day'
  final String? note;

  bool get isPresent => status == 'present';

  TimePunch copyWith({
    DateTime? checkIn,
    DateTime? checkOut,
    String? status,
    String? note,
  }) {
    return TimePunch(
      id: id,
      workerId: workerId,
      attendanceDayId: attendanceDayId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}
