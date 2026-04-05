import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'project_sites_api.dart';

final Provider<ProjectSitesApi> projectSitesApiProvider =
    Provider<ProjectSitesApi>((Ref ref) {
  return ProjectSitesApi(ref.watch(dioProvider));
});
