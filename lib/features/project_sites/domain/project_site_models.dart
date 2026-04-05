// Domain types for GET/POST/PATCH/DELETE /project_sites (org header). JSON is snake_case.

class ProjectSiteStaffingSummary {
  const ProjectSiteStaffingSummary({
    required this.workersScheduledToday,
    required this.assignmentsToday,
    required this.defaultHomeWorkersCount,
  });

  final int workersScheduledToday;
  final int assignmentsToday;
  final int defaultHomeWorkersCount;

  factory ProjectSiteStaffingSummary.fromJson(Map<String, dynamic> json) {
    return ProjectSiteStaffingSummary(
      workersScheduledToday: _asInt(json['workers_scheduled_today']),
      assignmentsToday: _asInt(json['assignments_today']),
      defaultHomeWorkersCount: _asInt(json['default_home_workers_count']),
    );
  }
}

class ProjectSiteImage {
  const ProjectSiteImage({required this.id, required this.url});

  final String id;
  final String url;

  factory ProjectSiteImage.fromJson(Map<String, dynamic> json) {
    return ProjectSiteImage(
      id: json['id'] as String,
      url: (json['url'] as String?)?.trim() ?? '',
    );
  }
}

class ProjectSiteContractee {
  const ProjectSiteContractee({
    required this.id,
    this.email,
    this.firstName,
    this.middleName,
    this.lastName,
    this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String? email;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? fullName;
  final String? avatarUrl;

  String get displayName {
    final String? f = fullName?.trim();
    if (f != null && f.isNotEmpty) {
      return f;
    }
    final List<String> parts = <String>[
      firstName ?? '',
      middleName ?? '',
      lastName ?? '',
    ].map((String s) => s.trim()).where((String s) => s.isNotEmpty).toList();
    if (parts.isEmpty && email != null && email!.isNotEmpty) {
      return email!;
    }
    return parts.join(' ');
  }

  factory ProjectSiteContractee.fromJson(Map<String, dynamic> json) {
    final String? av = json['avatar_url'] as String?;
    return ProjectSiteContractee(
      id: json['id'] as String,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: av != null && av.trim().isNotEmpty ? av.trim() : null,
    );
  }
}

class ProjectSiteAddress {
  const ProjectSiteAddress({
    this.id,
    this.line1,
    this.line2,
    this.city,
    this.region,
    this.postalCode,
    this.countryCode,
    this.label,
    this.singleLine,
  });

  final String? id;
  final String? line1;
  final String? line2;
  final String? city;
  final String? region;
  final String? postalCode;
  final String? countryCode;
  final String? label;
  final String? singleLine;

  String get displayLine {
    final String? s = singleLine?.trim();
    if (s != null && s.isNotEmpty) {
      return s;
    }
    final List<String> parts = <String>[
      line1 ?? '',
      line2 ?? '',
      city ?? '',
      region ?? '',
      postalCode ?? '',
      countryCode ?? '',
    ].map((String x) => x.trim()).where((String x) => x.isNotEmpty).toList();
    return parts.join(', ');
  }

  factory ProjectSiteAddress.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProjectSiteAddress();
    }
    return ProjectSiteAddress(
      id: json['id'] as String?,
      line1: json['line1'] as String?,
      line2: json['line2'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      postalCode: json['postal_code'] as String?,
      countryCode: json['country_code'] as String?,
      label: json['label'] as String?,
      singleLine: json['single_line'] as String?,
    );
  }
}

class ProjectSite {
  /// [imageList] may be null (e.g. older JSON or hot-reload); stored as a non-null list.
  ProjectSite({
    required this.id,
    required this.organizationId,
    required this.name,
    this.contracteeId,
    this.contractee,
    this.address,
    List<ProjectSiteImage>? imageList,
    this.payScheduleOverride,
    this.createdAt,
    this.updatedAt,
    this.staffingSummary,
  }) : images = imageList ?? const <ProjectSiteImage>[];

  final String id;
  final String organizationId;
  final String name;
  final String? contracteeId;
  final ProjectSiteContractee? contractee;
  final ProjectSiteAddress? address;
  final List<ProjectSiteImage> images;
  final Map<String, dynamic>? payScheduleOverride;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProjectSiteStaffingSummary? staffingSummary;

  String? get firstImageUrl {
    if (images.isEmpty) {
      return null;
    }
    final String u = images.first.url.trim();
    return u.isEmpty ? null : u;
  }

  /// Single-line location for lists and subtitles.
  String get addressLine => address?.displayLine ?? '';

  factory ProjectSite.fromJson(Map<String, dynamic> json) {
    final Object? addr = json['address'];
    final Object? contr = json['contractee'];
    final Object? imgs = json['images'];
    final Object? ps = json['pay_schedule_override'];
    final Object? sum = json['staffing_summary'];

    final List<ProjectSiteImage> imageList = <ProjectSiteImage>[];
    if (imgs is List<dynamic>) {
      for (final Object? item in imgs) {
        if (item is Map<String, dynamic>) {
          imageList.add(ProjectSiteImage.fromJson(item));
        }
      }
    }

    return ProjectSite(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      name: (json['name'] as String?)?.trim() ?? '',
      contracteeId: json['contractee_id'] as String?,
      contractee: contr is Map<String, dynamic>
          ? ProjectSiteContractee.fromJson(contr)
          : null,
      address: addr is Map<String, dynamic>
          ? ProjectSiteAddress.fromJson(addr)
          : null,
      imageList: imageList,
      payScheduleOverride: _jsonMap(ps),
      createdAt: _parseDate(json['created_at'] as String?),
      updatedAt: _parseDate(json['updated_at'] as String?),
      staffingSummary: sum is Map<String, dynamic>
          ? ProjectSiteStaffingSummary.fromJson(sum)
          : null,
    );
  }

  ProjectSite copyWith({
    String? name,
    ProjectSiteAddress? address,
    List<ProjectSiteImage>? images,
    Map<String, dynamic>? payScheduleOverride,
    ProjectSiteStaffingSummary? staffingSummary,
    ProjectSiteContractee? contractee,
    String? contracteeId,
  }) {
    return ProjectSite(
      id: id,
      organizationId: organizationId,
      name: name ?? this.name,
      contracteeId: contracteeId ?? this.contracteeId,
      contractee: contractee ?? this.contractee,
      address: address ?? this.address,
      imageList: images ?? this.images,
      payScheduleOverride: payScheduleOverride ?? this.payScheduleOverride,
      createdAt: createdAt,
      updatedAt: updatedAt,
      staffingSummary: staffingSummary ?? this.staffingSummary,
    );
  }
}

int _asInt(Object? v) {
  if (v is int) {
    return v;
  }
  if (v is num) {
    return v.toInt();
  }
  return 0;
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  try {
    return DateTime.parse(raw);
  } on Object {
    return null;
  }
}

Map<String, dynamic>? _jsonMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.from(value);
  }
  if (value is Map) {
    return value.map((Object? k, Object? v) => MapEntry(k.toString(), v));
  }
  return null;
}
