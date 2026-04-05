import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/project_site_models.dart';
import 'project_sites_api.dart';
import 'project_sites_api_provider.dart';

class ProjectSiteRepository {
  ProjectSiteRepository(this._api);

  final ProjectSitesApi _api;

  Future<List<ProjectSite>> fetchSites(String orgId) {
    // `orgId` keys Riverpod cache; tenant is `X-Organization-Id` on [Dio].
    return _api.listAllProjectSites();
  }

  Future<ProjectSite?> fetchSite(String orgId, String siteId) async {
    try {
      return await _api.getProjectSite(siteId);
    } on ProjectSitesApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<ProjectSite> createSite({
    required String orgId,
    required String name,
    required bool forSelf,
    Map<String, dynamic>? contractee,
    String? addressString,
    Uint8List? contracteeAvatarBytes,
  }) {
    return _api.createProjectSite(
      name: name,
      forSelf: forSelf,
      contractee: contractee,
      addressString: addressString,
      contracteeAvatarBytes: contracteeAvatarBytes,
    );
  }

  Future<ProjectSite> updateSite({
    required String orgId,
    required ProjectSite site,
    String? name,
    String? addressString,
  }) {
    return _api.updateProjectSite(
      site.id,
      name: name,
      addressString: addressString,
    );
  }

  Future<void> deleteSite(String orgId, String siteId) {
    return _api.deleteProjectSite(siteId);
  }
}

final projectSiteRepositoryProvider = Provider<ProjectSiteRepository>((ref) {
  return ProjectSiteRepository(ref.watch(projectSitesApiProvider));
});

final projectSitesProvider =
    FutureProvider.family<List<ProjectSite>, String>((ref, orgId) {
  final repository = ref.watch(projectSiteRepositoryProvider);
  return repository.fetchSites(orgId);
});

final projectSiteProvider = FutureProvider.family<ProjectSite?,
    ({String orgId, String siteId})>((ref, args) {
  final repository = ref.watch(projectSiteRepositoryProvider);
  return repository.fetchSite(args.orgId, args.siteId);
});
