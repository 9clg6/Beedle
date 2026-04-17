import 'package:beedle/domain/services/auth.service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.state.freezed.dart';

/// Statut courant du flow d'auth (idle, signin en cours, succès).
enum AuthScreenStatus { idle, signingInGoogle, signingInApple, success }

@Freezed(copyWith: true)
abstract class AuthScreenState with _$AuthScreenState {
  const factory AuthScreenState({
    @Default(AuthScreenStatus.idle) AuthScreenStatus status,
    AuthFailure? error,
  }) = _AuthScreenState;

  factory AuthScreenState.initial() => const AuthScreenState();
}
