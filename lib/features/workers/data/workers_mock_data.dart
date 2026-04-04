import '../../../core/router/route_placeholders.dart';
import '../domain/worker_models.dart';

/// Replace with [WorkersRepository] + Pagy when the API is wired.
abstract final class WorkersMockData {
  static final List<WorkerDetail> _all = <WorkerDetail>[
    WorkerDetail(
      id: RoutePlaceholders.workerId,
      displayName: 'Sita Gurung',
      phoneE164: '+9779811122334',
      skillsSummary: 'Masonry, site helper',
      statusLabel: 'Active',
      email: 'sita.g@example.com',
      bankMasked: '•••• 4521 (Nabil Bank)',
      joinedOn: DateTime.utc(2024, 3, 12),
      notes: 'Prefers morning shifts; certified for heights.',
    ),
    const WorkerDetail(
      id: 'a1000000-0000-4000-8000-000000000001',
      displayName: 'Ram Thapa',
      phoneE164: '+9779822233445',
      skillsSummary: 'Electrical assist',
      statusLabel: 'Active',
      email: 'ram.t@example.com',
      bankMasked: '•••• 8890',
      joinedOn: null,
      notes: null,
    ),
    const WorkerDetail(
      id: 'a1000000-0000-4000-8000-000000000002',
      displayName: 'Mina Shrestha',
      phoneE164: '+9779833344556',
      skillsSummary: 'Painting, finishing',
      statusLabel: 'On leave',
      email: null,
      bankMasked: '•••• 1022',
      joinedOn: null,
      notes: 'Returns next month.',
    ),
    const WorkerDetail(
      id: 'a1000000-0000-4000-8000-000000000003',
      displayName: 'Kiran Magar',
      phoneE164: '+9779844455667',
      skillsSummary: 'General labour',
      statusLabel: 'Active',
      email: 'kiran.m@example.com',
      bankMasked: null,
      joinedOn: null,
      notes: null,
    ),
  ];

  static List<WorkerSummary> summariesForOrg(String _) {
    return List<WorkerSummary>.from(_all);
  }

  static WorkerDetail? detailById(String workerId) {
    for (final WorkerDetail w in _all) {
      if (w.id == workerId) {
        return w;
      }
    }
    return null;
  }

  /// Simulates `GET /workers/search?phone_e164=` — returns one match or null.
  static WorkerDetail? searchByPhone(String raw) {
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) {
      return null;
    }
    return _all.first;
  }
}
