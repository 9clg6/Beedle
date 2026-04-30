import 'package:beedle/data/mappers/auth_user.mapper.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/enum/auth_provider.enum.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUser extends Mock implements User {}

class _MockUserMetadata extends Mock implements UserMetadata {}

class _MockUserInfo extends Mock implements UserInfo {}

void main() {
  group('FirebaseUserMapperX.toEntity', () {
    test('mappe tous les champs (uid, email, displayName, photoUrl)', () {
      final _MockUser user = _MockUser();
      final _MockUserMetadata meta = _MockUserMetadata();
      final DateTime created = DateTime.utc(2026, 1, 15, 12);

      when(() => user.uid).thenReturn('abc123');
      when(() => user.email).thenReturn('user@example.com');
      when(() => user.displayName).thenReturn('Jane Doe');
      when(() => user.photoURL).thenReturn('https://cdn/p.jpg');
      when(() => user.metadata).thenReturn(meta);
      when(() => meta.creationTime).thenReturn(created);

      final AuthUserEntity entity = user.toEntity(
        provider: AuthProvider.google,
      );

      expect(entity.uid, 'abc123');
      expect(entity.provider, AuthProvider.google);
      expect(entity.createdAt, created);
      expect(entity.email, 'user@example.com');
      expect(entity.displayName, 'Jane Doe');
      expect(entity.photoUrl, 'https://cdn/p.jpg');
    });

    test('utilise DateTime.now() si metadata.creationTime est null', () {
      final _MockUser user = _MockUser();
      final _MockUserMetadata meta = _MockUserMetadata();

      when(() => user.uid).thenReturn('abc');
      when(() => user.email).thenReturn(null);
      when(() => user.displayName).thenReturn(null);
      when(() => user.photoURL).thenReturn(null);
      when(() => user.metadata).thenReturn(meta);
      when(() => meta.creationTime).thenReturn(null);

      final DateTime before = DateTime.now();
      final AuthUserEntity entity = user.toEntity(provider: AuthProvider.apple);
      final DateTime after = DateTime.now();

      expect(
        entity.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        entity.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });

  group('authProviderOf', () {
    test('mappe "google.com" vers AuthProvider.google', () {
      final _MockUser user = _MockUser();
      final _MockUserInfo info = _MockUserInfo();
      when(() => info.providerId).thenReturn('google.com');
      when(() => user.providerData).thenReturn(<UserInfo>[info]);

      expect(authProviderOf(user), AuthProvider.google);
    });

    test('mappe "apple.com" vers AuthProvider.apple', () {
      final _MockUser user = _MockUser();
      final _MockUserInfo info = _MockUserInfo();
      when(() => info.providerId).thenReturn('apple.com');
      when(() => user.providerData).thenReturn(<UserInfo>[info]);

      expect(authProviderOf(user), AuthProvider.apple);
    });

    test('fallback sur AuthProvider.google si providerData est vide', () {
      final _MockUser user = _MockUser();
      when(() => user.providerData).thenReturn(<UserInfo>[]);

      expect(authProviderOf(user), AuthProvider.google);
    });

    test('fallback sur AuthProvider.google pour un providerId inconnu', () {
      final _MockUser user = _MockUser();
      final _MockUserInfo info = _MockUserInfo();
      when(() => info.providerId).thenReturn('password');
      when(() => user.providerData).thenReturn(<UserInfo>[info]);

      expect(authProviderOf(user), AuthProvider.google);
    });
  });

  group('AuthUserEntity JSON roundtrip', () {
    test('fromJson(toJson()) == original', () {
      final AuthUserEntity original = AuthUserEntity(
        uid: 'uid-1',
        provider: AuthProvider.apple,
        createdAt: DateTime.utc(2026, 4, 16, 10, 30),
        email: 'a@b.c',
        displayName: 'X',
        photoUrl: 'https://x.y/z.png',
      );

      final Map<String, dynamic> json = original.toJson();
      final AuthUserEntity restored = AuthUserEntity.fromJson(json);

      expect(restored, original);
    });

    test('roundtrip avec champs nullables à null', () {
      final AuthUserEntity original = AuthUserEntity(
        uid: 'uid-1',
        provider: AuthProvider.google,
        createdAt: DateTime.utc(2026),
      );

      final AuthUserEntity restored = AuthUserEntity.fromJson(
        original.toJson(),
      );

      expect(restored, original);
    });
  });
}
