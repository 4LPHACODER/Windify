import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/saved_locations_repository.dart';
import '../datasources/saved_locations_remote_datasource.dart';

class SavedLocationsRepositoryImpl implements SavedLocationsRepository {
  SavedLocationsRepositoryImpl(
    this._datasource, {
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SavedLocationsRemoteDatasource _datasource;
  final SupabaseClient _client;

  @override
  Future<List<SavedLocation>> fetchForCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    return _datasource.fetchForUser(user.id);
  }

  @override
  Future<SavedLocation> save({
    required String userId,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    final sessionUser = _client.auth.currentUser;
    if (sessionUser == null || sessionUser.id != userId) {
      throw StateError('Not signed in');
    }
    return _datasource.insert(
      userId: userId,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<void> delete({required int id, required String userId}) async {
    final sessionUser = _client.auth.currentUser;
    if (sessionUser == null || sessionUser.id != userId) {
      throw StateError('Not signed in');
    }
    await _datasource.delete(id: id, userId: userId);
  }
}
