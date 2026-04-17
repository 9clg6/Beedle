import 'package:beedle/domain/enum/auth_provider.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.entity.freezed.dart';
part 'auth_user.entity.g.dart';

/// Représentation domain d'un utilisateur authentifié.
///
/// Dérivée à la volée de `firebase_auth.User` via le mapper `auth_user.mapper`.
/// Aucune persistance ObjectBox : Firebase Auth gère lui-même la session
/// (Keychain iOS / EncryptedSharedPreferences Android).
@freezed
abstract class AuthUserEntity with _$AuthUserEntity {
  const factory AuthUserEntity({
    required String uid,
    required AuthProvider provider,
    required DateTime createdAt,
    String? email,
    String? displayName,
    String? photoUrl,
  }) = _AuthUserEntity;

  factory AuthUserEntity.fromJson(Map<String, dynamic> json) =>
      _$AuthUserEntityFromJson(json);
}
