import 'package:beedle/foundation/interfaces/future.usecases.dart';

/// Contrat : wipe complet des données locales (fiches, screenshots, préférences, abonnement cache).
abstract interface class DataWipeService {
  Future<void> wipeAll();
}

final class WipeAllDataUseCase extends FutureUseCase<void> {
  WipeAllDataUseCase({required DataWipeService dataWipeService})
      : _service = dataWipeService;

  final DataWipeService _service;

  @override
  Future<void> invoke() => _service.wipeAll();
}
