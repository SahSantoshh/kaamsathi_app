import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/engagement_models.dart';
import 'engagements_api.dart';
import 'engagements_api_provider.dart';

class EngagementsRepository {
  EngagementsRepository(this._api);

  final EngagementsApi _api;

  Future<List<OrgEngagement>> fetchEngagements(String orgId, {String? status}) {
    return _api.listAllEngagements(status: status);
  }

  Future<OrgEngagement> fetchEngagement(String orgId, String engagementId) {
    return _api.getEngagement(engagementId);
  }

  Future<OrgEngagement> updateEngagement(
    String orgId,
    String engagementId,
    Map<String, dynamic> patch,
  ) {
    return _api.updateEngagement(engagementId, patch);
  }
}

final Provider<EngagementsRepository> engagementsRepositoryProvider =
    Provider<EngagementsRepository>((Ref ref) {
  return EngagementsRepository(ref.watch(engagementsApiProvider));
});

final engagementsListProvider =
    FutureProvider.family<List<OrgEngagement>, String>(
        (Ref ref, String orgId) {
  final EngagementsRepository r = ref.watch(engagementsRepositoryProvider);
  return r.fetchEngagements(orgId);
});

final engagementDetailProvider =
    FutureProvider.family<OrgEngagement, ({String orgId, String engagementId})>(
  (Ref ref, ({String orgId, String engagementId}) args) {
    final EngagementsRepository r = ref.watch(engagementsRepositoryProvider);
    return r.fetchEngagement(args.orgId, args.engagementId);
  },
);
