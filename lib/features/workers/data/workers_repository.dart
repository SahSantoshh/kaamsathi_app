import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/worker_models.dart';
import 'workers_api.dart';
import 'workers_api_provider.dart';

class WorkersRepository {
  WorkersRepository(this._api);

  final WorkersApi _api;

  Future<List<Worker>> fetchWorkers(String orgId) {
    return _api.listAllWorkers();
  }

  Future<Worker> fetchWorker(String orgId, String workerId) {
    return _api.getWorker(workerId);
  }

  Future<WorkerSearchOutcome> searchWorker(
    String orgId, {
    String? phoneE164,
    String? email,
  }) {
    return _api.searchWorker(phoneE164: phoneE164, email: email);
  }

  Future<Worker> linkWorker(
    String orgId,
    String workerId, {
    Map<String, dynamic>? engagement,
  }) {
    return _api.linkExistingWorker(workerId, engagement: engagement);
  }

  Future<Worker> createWorker(
    String orgId, {
    required Map<String, dynamic> worker,
    Map<String, dynamic>? engagement,
  }) {
    return _api.createWorker(worker: worker, engagement: engagement);
  }

  Future<Worker> updateWorker(
    String orgId,
    String workerId, {
    required Map<String, dynamic> worker,
    Map<String, dynamic>? engagement,
  }) {
    return _api.updateWorker(
      workerId,
      workerPatch: worker,
      engagementPatch: engagement,
    );
  }

  Future<void> deleteWorker(String orgId, String workerId) {
    return _api.deleteWorker(workerId);
  }
}

final Provider<WorkersRepository> workersRepositoryProvider =
    Provider<WorkersRepository>((Ref ref) {
  return WorkersRepository(ref.watch(workersApiProvider));
});

final workersListProvider =
    FutureProvider.family<List<Worker>, String>((Ref ref, String orgId) {
  final WorkersRepository r = ref.watch(workersRepositoryProvider);
  return r.fetchWorkers(orgId);
});

final workerDetailProvider =
    FutureProvider.family<Worker, ({String orgId, String workerId})>(
        (Ref ref, ({String orgId, String workerId}) args) {
  final WorkersRepository r = ref.watch(workersRepositoryProvider);
  return r.fetchWorker(args.orgId, args.workerId);
});
