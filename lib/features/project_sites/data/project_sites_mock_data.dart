import '../domain/project_site_models.dart';

abstract final class ProjectSitesMockData {
  static List<ProjectSite> sitesForOrg(String orgId) {
    return <ProjectSite>[
      ProjectSite(
        id: 'site-1',
        orgId: orgId,
        name: 'Skyline Towers',
        address: '123 Main St, Kathmandu',
        description: 'Commercial high-rise construction site.',
      ),
      ProjectSite(
        id: 'site-2',
        orgId: orgId,
        name: 'River Side Villas',
        address: 'Lalitpur, Ward 4',
        description: 'Residential housing project near the Bagmati river.',
      ),
      ProjectSite(
        id: 'site-3',
        orgId: orgId,
        name: 'Tech Park B1',
        address: 'Baneshwor, Kathmandu',
        status: 'inactive',
        description: 'Upcoming IT park development.',
      ),
      ProjectSite(
        id: 'site-4',
        orgId: orgId,
        name: 'Everest Mall',
        address: 'Chabahil, Kathmandu',
        description: 'Shopping mall renovation and expansion.',
      ),
    ];
  }

  static ProjectSite? getSiteById(String orgId, String siteId) {
    try {
      return sitesForOrg(orgId).firstWhere((ProjectSite s) => s.id == siteId);
    } catch (_) {
      return null;
    }
  }
}
