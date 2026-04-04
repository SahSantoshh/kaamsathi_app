class ProjectSite {
  const ProjectSite({
    required this.id,
    required this.orgId,
    required this.name,
    required this.address,
    this.description,
    this.status = 'active',
  });

  final String id;
  final String orgId;
  final String name;
  final String address;
  final String? description;
  final String status;

  bool get isActive => status == 'active';
}
