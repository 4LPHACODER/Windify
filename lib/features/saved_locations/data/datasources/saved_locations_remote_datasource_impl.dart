import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/saved_location.dart';
import 'saved_locations_remote_datasource.dart';

class SavedLocationsRemoteDatasourceImpl implements SavedLocationsRemoteDatasource {
  SavedLocationsRemoteDatasourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _table = 'saved_locations';

  @override
  Future<List<SavedLocation>> fetchForUser(String userId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final list = rows as List<dynamic>;
    return list
        .map((e) => SavedLocation.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<SavedLocation> insert({
    required String userId,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    final row = await _client
        .from(_table)
        .insert({
          'user_id': userId,
          'location_name': locationName,
          'latitude': latitude,
          'longitude': longitude,
        })
        .select()
        .single();
    return SavedLocation.fromJson(Map<String, dynamic>.from(row));
  }

  @override
  Future<void> delete({required int id, required String userId}) async {
    await _client.from(_table).delete().eq('id', id).eq('user_id', userId);
  }
}
