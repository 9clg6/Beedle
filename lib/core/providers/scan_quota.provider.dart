import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/data/services/scan_quota.service.impl.dart';
import 'package:beedle/domain/services/scan_quota.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour [ScanQuotaService]. Singleton app-scoped.
///
/// À consommer dans tous les call sites qui déclenchent un scan IA
/// (ingestion pipeline, "rescan this card", bulk enrich, etc.).
final Provider<ScanQuotaService> scanQuotaServiceProvider =
    Provider<ScanQuotaService>((Ref ref) {
  return ScanQuotaServiceImpl(
    subscriptionRepo: ref.watch(subscriptionRepositoryProvider),
  );
});
