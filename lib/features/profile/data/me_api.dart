import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../auth/data/auth_api.dart';
import '../../organization/data/organizations_api.dart';

/// Authenticated `PATCH /me` (JSON or multipart with `user[avatar]` file).
///
/// See KaamSathi_web/docs/flutter_app.md §8 `PATCH /me`.
class MeApi {
  MeApi(this._dio);

  final Dio _dio;

  /// Text-only name/address updates as JSON. Use [patchMeWithAvatar] when uploading an image.
  Future<MeResponse> patchMeJson({
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    final Map<String, dynamic> user = <String, dynamic>{};
    if (firstName != null) {
      user['first_name'] = firstName;
    }
    if (middleName != null) {
      user['middle_name'] = middleName;
    }
    if (lastName != null) {
      user['last_name'] = lastName;
    }
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.patch<Map<String, dynamic>>(
        '/me',
        data: <String, dynamic>{'user': user},
      );
      final Map<String, dynamic>? data = res.data;
      if (data == null) {
        throw AuthApiException('Invalid response from server');
      }
      return MeResponse.fromJson(data);
    } on DioException catch (e) {
      throw AuthApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not update profile',
      );
    }
  }

  /// Multipart update: optional name fields + avatar file and/or [removeAvatar].
  Future<MeResponse> patchMeWithAvatar({
    String? firstName,
    String? middleName,
    String? lastName,
    Uint8List? avatarBytes,
    bool removeAvatar = false,
  }) async {
    if (removeAvatar && (avatarBytes != null && avatarBytes.isNotEmpty)) {
      throw AuthApiException('Choose either a new avatar or remove, not both.');
    }
    final Map<String, dynamic> fields = <String, dynamic>{};
    if (firstName != null) {
      fields['user[first_name]'] = firstName;
    }
    if (middleName != null) {
      fields['user[middle_name]'] = middleName;
    }
    if (lastName != null) {
      fields['user[last_name]'] = lastName;
    }
    if (removeAvatar) {
      fields['user[remove_avatar]'] = 'true';
    }
    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      fields['user[avatar]'] = MultipartFile.fromBytes(
        avatarBytes,
        filename: 'avatar.jpg',
      );
    }
    try {
      final Response<Map<String, dynamic>> res =
          await _dio.patch<Map<String, dynamic>>(
        '/me',
        data: FormData.fromMap(fields),
      );
      final Map<String, dynamic>? data = res.data;
      if (data == null) {
        throw AuthApiException('Invalid response from server');
      }
      return MeResponse.fromJson(data);
    } on DioException catch (e) {
      throw AuthApiException(
        OrganizationsApi.userMessageFromDio(e) ?? 'Could not update profile',
      );
    }
  }
}
