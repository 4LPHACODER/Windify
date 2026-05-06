import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/saved_locations_remote_datasource_impl.dart';
import '../../data/repositories/saved_locations_repository_impl.dart';
import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/saved_locations_repository.dart';

final savedLocationsRepositoryProvider = Provider<SavedLocationsRepository>((ref) {
  return SavedLocationsRepositoryImpl(
    SavedLocationsRemoteDatasourceImpl(),
  );
});

/// Loads saved places for the signed-in user; invalidate to refresh.
final savedLocationsListProvider =
    FutureProvider.autoDispose<List<SavedLocation>>((ref) async {
  final repo = ref.watch(savedLocationsRepositoryProvider);
  return repo.fetchForCurrentUser();
});
