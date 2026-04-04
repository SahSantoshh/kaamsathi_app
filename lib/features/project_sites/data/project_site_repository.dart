import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/project_site_models.dart';
import 'project_sites_mock_data.dart';

class ProjectSiteRepository {
  ProjectSiteRepository();

  final List<ProjectSite> _sites = [];

  Future<List<ProjectSite>> fetchSites(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Initialize with mock data if empty for this demo
    if (_sites.isEmpty) {
      _sites.addAll(ProjectSitesMockData.sitesForOrg(orgId));
    }
    return _sites.where((site) => site.orgId == orgId).toList();
  }

  Future<ProjectSite?> fetchSite(String orgId, String siteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _sites.firstWhere((site) => site.orgId == orgId && site.id == siteId);
    } catch (_) {
      // Fallback to mock data if not in memory yet
      return ProjectSitesMockData.getSiteById(orgId, siteId);
    }
  }

  Future<void> addSite(ProjectSite site) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _sites.add(site);
  }

  Future<void> updateSite(ProjectSite site) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _sites.indexWhere((s) => s.id == site.id);
    if (index != -1) {
      _sites[index] = site;
    }
  }
}

final projectSiteRepositoryProvider = Provider<ProjectSiteRepository>((ref) {
  return ProjectSiteRepository();
});

final projectSitesProvider = FutureProvider.family<List<ProjectSite>, String>((ref, orgId) {
  final repository = ref.watch(projectSiteRepositoryProvider);
  return repository.fetchSites(orgId);
});

final projectSiteProvider = FutureProvider.family<ProjectSite?, ({String orgId, String siteId})>((ref, args) {
  final repository = ref.watch(projectSiteRepositoryProvider);
  return repository.fetchSite(args.orgId, args.siteId);
});
