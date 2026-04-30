import 'dart:async';

import 'package:beedle/core/providers/auth.provider.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/enum/auth_provider.enum.dart';
import 'package:beedle/domain/services/auth.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthService extends Mock implements AuthService {}

void main() {
  group('currentUserProvider', () {
    test('reflète la dernière valeur émise par authStateProvider', () async {
      final _MockAuthService auth = _MockAuthService();
      final StreamController<AuthUserEntity?> controller =
          StreamController<AuthUserEntity?>();
      when(auth.authStateChanges).thenAnswer((_) => controller.stream);

      final ProviderContainer c = ProviderContainer(
        overrides: <Override>[authServiceProvider.overrideWithValue(auth)],
      );
      addTearDown(c.dispose);
      addTearDown(controller.close);

      // Démarre l'écoute pour activer le stream.
      c.listen(authStateProvider, (_, AsyncValue<AuthUserEntity?> z) {});

      // État initial : null (stream pas encore émis).
      expect(c.read(currentUserProvider), isNull);

      // Émet une entity → currentUserProvider doit refléter.
      final AuthUserEntity entity = AuthUserEntity(
        uid: 'uid-1',
        provider: AuthProvider.google,
        createdAt: DateTime.utc(2026),
      );
      controller.add(entity);
      await Future<void>.delayed(Duration.zero);

      expect(c.read(currentUserProvider), entity);

      // Émet null (logout) → reset.
      controller.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(c.read(currentUserProvider), isNull);
    });

    test('reflète une transition entity1 → entity2 (re-login)', () async {
      final _MockAuthService auth = _MockAuthService();
      final StreamController<AuthUserEntity?> controller =
          StreamController<AuthUserEntity?>();
      when(auth.authStateChanges).thenAnswer((_) => controller.stream);

      final ProviderContainer c = ProviderContainer(
        overrides: <Override>[authServiceProvider.overrideWithValue(auth)],
      );
      addTearDown(c.dispose);
      addTearDown(controller.close);

      c.listen(authStateProvider, (_, __) {});

      final AuthUserEntity e1 = AuthUserEntity(
        uid: 'uid-1',
        provider: AuthProvider.google,
        createdAt: DateTime.utc(2026),
      );
      final AuthUserEntity e2 = AuthUserEntity(
        uid: 'uid-2',
        provider: AuthProvider.apple,
        createdAt: DateTime.utc(2026, 2),
      );

      controller.add(e1);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(currentUserProvider), e1);

      controller.add(e2);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(currentUserProvider), e2);
    });
  });
}
