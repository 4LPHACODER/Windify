import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/saved_locations_remote_datasource_impl.dart';
import '../../data/repositories/saved_locations_repository_impl.dart';
import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/saved_locations_repository.dart';
import '../requests/list_saved_locations_request.dart';
import '../services/saved_locations_service.dart';
import '../usecases/delete_saved_location_usecase.dart';
import '../usecases/list_saved_locations_usecase.dart';
import '../usecases/save_saved_location_usecase.dart';

final savedLocationsRepositoryProvider = Provider<SavedLocationsRepository>((ref) {
  return SavedLocationsRepositoryImpl(SavedLocationsRemoteDatasourceImpl());
});

final listSavedLocationsUsecaseProvider = Provider<ListSavedLocationsUsecase>((
  ref,
) {
  final repository = ref.watch(savedLocationsRepositoryProvider);
  return ListSavedLocationsUsecase(repository);
});

final saveSavedLocationUsecaseProvider = Provider<SaveSavedLocationUsecase>((ref) {
  final repository = ref.watch(savedLocationsRepositoryProvider);
  return SaveSavedLocationUsecase(repository);
});

final deleteSavedLocationUsecaseProvider = Provider<DeleteSavedLocationUsecase>((
  ref,
) {
  final repository = ref.watch(savedLocationsRepositoryProvider);
  return DeleteSavedLocationUsecase(repository);
});

final savedLocationsServiceProvider = Provider<SavedLocationsService>((ref) {
  final listUsecase = ref.watch(listSavedLocationsUsecaseProvider);
  final saveUsecase = ref.watch(saveSavedLocationUsecaseProvider);
  final deleteUsecase = ref.watch(deleteSavedLocationUsecaseProvider);
  return SavedLocationsService(listUsecase, saveUsecase, deleteUsecase);
});

/// Loads saved places for the signed-in user; invalidate to refresh.
final savedLocationsListProvider =
    FutureProvider.autoDispose<List<SavedLocation>>((ref) async {
      final service = ref.watch(savedLocationsServiceProvider);
      return service.list(const ListSavedLocationsRequest());
    });
