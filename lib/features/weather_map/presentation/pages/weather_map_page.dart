import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:windify_v2/core/widgets/app_brand_logo.dart';

import '../../domain/entities/weather_layer.dart';
import '../../domain/entities/location.dart';
import '../controllers/weather_map_controller.dart';
import '../map/weather_map_camera.dart';
import '../map/weather_map_debug_log.dart';
import '../states/weather_map_state.dart';
import 'package:windify_v2/core/config/env_config.dart';
import 'package:windify_v2/features/auth/presentation/controllers/auth_controller.dart';
import 'package:windify_v2/features/saved_locations/domain/entities/saved_location.dart';
import 'package:windify_v2/features/saved_locations/presentation/pages/saved_locations_page.dart';
import 'package:windify_v2/features/saved_locations/presentation/providers/saved_locations_providers.dart';

class WeatherMapPage extends ConsumerStatefulWidget {
  const WeatherMapPage({super.key});

  @override
  ConsumerState<WeatherMapPage> createState() => _WeatherMapPageState();
}

class _WeatherMapPageState extends ConsumerState<WeatherMapPage> {
  final MapController _mapController = MapController();
  static const double _defaultZoom = 5.0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    try {
      final camera = _mapController.camera;
      _mapController.move(camera.center, camera.zoom + 1);
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      final camera = _mapController.camera;
      _mapController.move(camera.center, camera.zoom - 1);
    } catch (_) {}
  }

  void _onMapTapped(LatLng point) {
    double? zoomBefore;
    try {
      zoomBefore = _mapController.camera.zoom;
    } catch (_) {}
    WeatherMapDebugLog.mapTapped(point, zoomBefore);
    ref.read(weatherMapNotifierProvider.notifier).pinLocation(point);
  }

  void _maybeMoveMapCamera(WeatherMapState? prev, WeatherMapState next) {
    if (!mounted || prev == null) return;
    final nextSel = next.selectedLocation;
    final prevSel = prev.selectedLocation;
    if (nextSel != null &&
        (prevSel == null ||
            prevSel.latitude != nextSel.latitude ||
            prevSel.longitude != nextSel.longitude)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        WeatherMapCamera.panToPreserveZoom(
          _mapController,
          nextSel,
          fallbackZoom: _defaultZoom,
          reason: 'selected_pin_moved',
          onlyIfOutsideView: true,
        );
      });
      return;
    }
    final nextUser = next.userLocation;
    final prevUser = prev.userLocation;
    if (next.selectedLocation == null &&
        nextUser != null &&
        (prevUser == null ||
            prevUser.latitude != nextUser.latitude ||
            prevUser.longitude != nextUser.longitude)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        WeatherMapCamera.panToPreserveZoom(
          _mapController,
          nextUser,
          fallbackZoom: _defaultZoom,
          reason: 'user_location_updated',
          onlyIfOutsideView: true,
        );
      });
    }
  }

  Future<void> _savePinnedLocation(BuildContext context) async {
    final mapState = ref.read(weatherMapNotifierProvider);
    final coords = mapState.selectedLocation;
    if (coords == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pin a location on the map first.')),
        );
      }
      return;
    }
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to save locations.')),
        );
      }
      return;
    }
    final name = mapState.selectedLocationLabel ?? 'Saved place';
    try {
      await ref.read(savedLocationsRepositoryProvider).save(
            userId: user.id,
            locationName: name,
            latitude: coords.latitude,
            longitude: coords.longitude,
          );
      ref.invalidate(savedLocationsListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location saved')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    }
  }

  Future<void> _openSavedLocations(BuildContext context) async {
    final result = await Navigator.of(context).push<SavedLocation>(
      MaterialPageRoute(
        builder: (_) => const SavedLocationsPage(),
      ),
    );
    if (!mounted || result == null) return;
    await ref.read(weatherMapNotifierProvider.notifier).visitSavedLocation(
          LatLng(result.latitude, result.longitude),
          result.locationName,
        );
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WeatherMapCamera.panToPreserveZoom(
        _mapController,
        LatLng(result.latitude, result.longitude),
        fallbackZoom: _defaultZoom,
        reason: 'visit_saved_location',
        onlyIfOutsideView: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<WeatherMapState>(
      weatherMapNotifierProvider,
      _maybeMoveMapCamera,
    );
    final state = ref.watch(weatherMapNotifierProvider);
    final notifier = ref.read(weatherMapNotifierProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const AppBrandLogo(
                logoSize: 20,
                borderRadius: 6,
                showAppName: false,
                showShadow: false,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Windify',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  state.activeLocationLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search, color: Colors.white, size: 22),
            onPressed: () => _showSearchDialog(context, notifier),
          ),
          IconButton(
            tooltip: state.selectedLocation != null
                ? 'Save this location'
                : 'Pin a location on the map to save',
            icon: Icon(
              state.selectedLocation != null
                  ? Icons.bookmark_add
                  : Icons.bookmark_border,
              color: Colors.white,
              size: 22,
            ),
            onPressed: state.selectedLocation != null
                ? () => unawaited(_savePinnedLocation(context))
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pin a location on the map (tap the map), then save.',
                        ),
                      ),
                    );
                  },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings, color: Colors.white, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Map base
          Positioned.fill(child: _buildMap(state)),
          // Gradient overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                    ],
                    stops: const [0.0, 0.3, 0.7],
                  ),
                ),
              ),
            ),
          ),
          // Radar tint (replaces a second TileLayer inside FlutterMap — fewer
          // tile viewports / layout issues with flutter_map on web; see 6.txt).
          if (state.selectedLayer == WeatherLayer.radar)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _getLayerColor(WeatherLayer.radar).withOpacity(0.09),
                  ),
                ),
              ),
            ),
          // Content — avoid Column + Spacer in a non-positioned Stack child
          // (flex inside loose stack constraints contributed to layout asserts).
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  _ExpandableWeatherCard(state: state, notifier: notifier),
                ],
              ),
            ),
          ),
          // Live indicator
          Positioned(
            left: 20,
            bottom: MediaQuery.of(context).padding.bottom + 140,
            child: _buildLiveIndicator(state),
          ),
          // Map controls
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 140,
            child: _buildMapControls(notifier),
          ),
          if (state.isRequestingLocation)
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Getting your location...',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (state.isLoadingWeather)
            Positioned(
              left: 24,
              right: 24,
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 56,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.75),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Loading weather...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (state.error != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: MediaQuery.of(context).padding.bottom + 108,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(14),
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Retry',
                        icon: const Icon(Icons.refresh),
                        onPressed: () => ref
                            .read(weatherMapNotifierProvider.notifier)
                            .reloadWeatherOnly(),
                      ),
                      IconButton(
                        tooltip: 'Dismiss',
                        icon: const Icon(Icons.close),
                        onPressed: () => ref
                            .read(weatherMapNotifierProvider.notifier)
                            .dismissError(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, state, notifier),
      // AI recommendation FAB
      floatingActionButton: _AIFab(
        onPressed: () => _showAIRecommendationSheet(context, state),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMap(WeatherMapState state) {
    final mapboxToken = EnvConfig.mapboxAccessToken;
    if (mapboxToken == null || mapboxToken.isEmpty) {
      return _buildMapFallback(state);
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        // Stable initial values; camera is driven by [MapController], not by rebuilding options.
        initialCenter: WeatherMapState.fallbackCoordinates,
        initialZoom: _defaultZoom,
        minZoom: 2,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onTap: (_, point) => _onMapTapped(point),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v12/tiles/{z}/{x}/{y}?access_token={accessToken}',
          additionalOptions: {'accessToken': mapboxToken},
          userAgentPackageName: 'com.windify.app',
        ),
        MarkerLayer(
          markers: [
            if (state.userLocation != null)
              Marker(
                width: 30,
                height: 30,
                point: state.userLocation!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.95),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.45),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_pin_circle,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            if (state.selectedLocation != null)
              Marker(
                width: 36,
                height: 44,
                point: state.selectedLocation!,
                child: Icon(
                  Icons.location_on,
                  color: Colors.amber.shade700,
                  size: 44,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapFallback(WeatherMapState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getBackgroundColors(state.selectedLayer),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.15),
            ),
            const SizedBox(height: 16),
            Text(
              'Map unavailable',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveIndicator(WeatherMapState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getLayerColor(state.selectedLayer),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getLayerColor(state.selectedLayer).withOpacity(0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Live',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls(WeatherMapNotifier notifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapControlButton(
          icon: Icons.add,
          tooltip: 'Zoom in',
          onPressed: _zoomIn,
        ),
        const SizedBox(height: 10),
        _MapControlButton(
          icon: Icons.remove,
          tooltip: 'Zoom out',
          onPressed: _zoomOut,
        ),
        const SizedBox(height: 10),
        _MapControlButton(
          icon: Icons.my_location,
          tooltip: 'My location',
          onPressed: () => notifier.fetchCurrentLocation(),
        ),
        const SizedBox(height: 10),
        _MapControlButton(
          icon: Icons.refresh,
          tooltip: 'Refresh',
          onPressed: notifier.refresh,
        ),
      ],
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    WeatherMapState state,
    WeatherMapNotifier notifier,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            _buildLayerSegmentedControl(context, state, notifier),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
            const SizedBox(height: 12),
            _buildBottomActions(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerSegmentedControl(
    BuildContext context,
    WeatherMapState state,
    WeatherMapNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildSegment(
            context,
            'Radar',
            Icons.radar,
            WeatherLayer.radar,
            state.selectedLayer == WeatherLayer.radar,
            () => notifier.selectLayer(WeatherLayer.radar),
          ),
          const SizedBox(width: 12),
          _buildSegment(
            context,
            'Wind',
            Icons.air,
            WeatherLayer.wind,
            state.selectedLayer == WeatherLayer.wind,
            () => notifier.selectLayer(WeatherLayer.wind),
          ),
          const SizedBox(width: 12),
          _buildSegment(
            context,
            'Wave',
            Icons.waves,
            WeatherLayer.wave,
            state.selectedLayer == WeatherLayer.wave,
            () => notifier.selectLayer(WeatherLayer.wave),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context,
    String label,
    IconData icon,
    WeatherLayer layer,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final color = _getLayerColor(layer);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _BottomNavAction(
              icon: Icons.star_border,
              label: 'Saved',
              onPressed: () => unawaited(_openSavedLocations(context)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BottomNavAction(
              icon: Icons.layers,
              label: 'Layers',
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BottomNavAction(
              icon: Icons.timeline,
              label: 'Timeline',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WeatherMapNotifier notifier) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => _LocationSearchPage(notifier: notifier),
      ),
    );
  }

  void _showAIRecommendationSheet(BuildContext context, WeatherMapState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AIRecommendationSheet(state: state),
    );
  }

  Widget _ExpandableWeatherCard({
    required WeatherMapState state,
    required WeatherMapNotifier notifier,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (always visible)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => notifier.toggleInfoExpanded(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getLayerColor(
                            state.selectedLayer,
                          ).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _getLayerColor(
                              state.selectedLayer,
                            ).withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _getLayerIcon(state.selectedLayer),
                          size: 22,
                          color: _getLayerColor(state.selectedLayer),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.currentMap?.title ??
                                  state.selectedLayer.displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              state.activeLocationLabel,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: state.isInfoExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.expand_more,
                          size: 24,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (state.isInfoExpanded) ...[
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),
              _buildDataCards(state),
              const SizedBox(height: 12),
              Container(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 12),
              _buildMetaInfo(state),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataCards(WeatherMapState state) {
    final weather = state.currentMap?.currentWeather;
    final wind = state.currentMap?.windInfo;
    final wave = state.currentMap?.waveInfo;

    if (state.selectedLayer == WeatherLayer.radar && weather != null) {
      return Row(
        children: [
          Expanded(
            child: _DataCard(
              icon: Icons.water_drop,
              label: 'Precipitation',
              value: '${weather.precipitation ?? 0} mm',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DataCard(
              icon: Icons.thermostat,
              label: 'Temperature',
              value: '${weather.temperature.toStringAsFixed(1)}°C',
              color: Colors.orange,
            ),
          ),
        ],
      );
    } else if (state.selectedLayer == WeatherLayer.wind && wind != null) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DataCard(
                  icon: Icons.air,
                  label: 'Wind Speed',
                  value: '${wind.speed.toStringAsFixed(1)} m/s',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DataCard(
                  icon: Icons.explore,
                  label: 'Direction',
                  value: wind.directionName,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          if (wind.gust != null) ...[
            const SizedBox(height: 12),
            _DataCard(
              icon: Icons.bolt,
              label: 'Wind Gust',
              value: '${wind.gust!.toStringAsFixed(1)} m/s',
              color: Colors.orange,
              fullWidth: true,
            ),
          ],
        ],
      );
    } else if (state.selectedLayer == WeatherLayer.wave && wave != null) {
      return Row(
        children: [
          Expanded(
            child: _DataCard(
              icon: Icons.waves,
              label: 'Wave Height',
              value: '${wave.swellHeight?.toStringAsFixed(1) ?? "N/A"} m',
              color: Colors.cyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DataCard(
              icon: Icons.info,
              label: 'Condition',
              value: wave.description,
              color: Colors.teal,
            ),
          ),
        ],
      );
    } else if (weather != null) {
      // Fallback
      return Row(
        children: [
          Expanded(
            child: _DataCard(
              icon: Icons.thermostat,
              label: 'Temperature',
              value: '${weather.temperature.toStringAsFixed(1)}°C',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DataCard(
              icon: Icons.water_drop,
              label: 'Humidity',
              value: '${weather.humidity}%',
              color: Colors.blue,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMetaInfo(WeatherMapState state) {
    final updatedAt = state.currentMap?.updatedAt;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _InfoField(
              icon: Icons.update,
              label: 'Last Update',
              value: updatedAt != null
                  ? _formatTime(updatedAt)
                  : 'Waiting for data…',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _InfoField(
              icon: Icons.public,
              label: 'Coverage',
              value: 'Worldwide',
            ),
          ),
        ],
      ),
    );
  }

  Color _getLayerColor(WeatherLayer layer) {
    switch (layer) {
      case WeatherLayer.radar:
        return const Color(0xFF00B4D8);
      case WeatherLayer.wind:
        return const Color(0xFF00F5D4);
      case WeatherLayer.wave:
        return const Color(0xFF4CC9F0);
    }
  }

  IconData _getLayerIcon(WeatherLayer layer) {
    switch (layer) {
      case WeatherLayer.radar:
        return Icons.radar;
      case WeatherLayer.wind:
        return Icons.air;
      case WeatherLayer.wave:
        return Icons.waves;
    }
  }

  List<Color> _getBackgroundColors(WeatherLayer layer) {
    switch (layer) {
      case WeatherLayer.radar:
        return [
          const Color(0xFF0A1628),
          const Color(0xFF0D1B2A),
          const Color(0xFF1B263B),
          const Color(0xFF415A77),
        ];
      case WeatherLayer.wind:
        return [
          const Color(0xFF0A1A1A),
          const Color(0xFF0D2A2A),
          const Color(0xFF1A3A3A),
          const Color(0xFF2A4A4A),
        ];
      case WeatherLayer.wave:
        return [
          const Color(0xFF0A1A2A),
          const Color(0xFF0D263A),
          const Color(0xFF1A364A),
          const Color(0xFF4A6A8A),
        ];
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _DataCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  const _DataCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    if (fullWidth) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Callers wrap in [Expanded]; do not nest another [Expanded] here (ParentDataWidget error).
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

class _BottomNavAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _BottomNavAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF4A4A5A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.25),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: const Color(0xFF0D1B2A)),
          ),
        ),
      ),
    );
  }
}

/// Full-screen route so [Scaffold] gives a bounded body; avoids
/// `showModalBottomSheet` + viewport intrinsic layout crashes (see 6.txt ~952–998).
class _LocationSearchPage extends StatefulWidget {
  final WeatherMapNotifier notifier;

  const _LocationSearchPage({required this.notifier});

  @override
  State<_LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<_LocationSearchPage> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  List<Location> _results = [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleSearch(String raw) {
    _debounce?.cancel();
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _error = null;
        _loading = false;
      });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _runSearch(trimmed),
    );
  }

  Future<void> _runSearch(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.notifier.searchPlaces(q);
      if (!mounted) return;
      setState(() {
        _results = list;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString()
          .replaceFirst('StateError: ', '')
          .replaceFirst('Exception: ', '');
      setState(() {
        _results = [];
        _loading = false;
        _error = msg;
      });
    }
  }

  Widget _resultsBody(ThemeData theme) {
    final q = _controller.text.trim();
    if (q.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Type a city, place, or address to search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }
    if (_loading && _results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'Searching…',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }
    if (!_loading && _results.isEmpty && _error == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No locations found. Try different words.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ),
      );
    }
    final locs = _results.take(24).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < locs.length; i++) ...[
            if (i > 0) Divider(height: 1, color: Colors.grey.shade200),
            ListTile(
              leading: Icon(
                Icons.location_on_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                locs[i].name ?? 'Place',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: (locs[i].address != null && locs[i].address!.isNotEmpty)
                  ? Text(
                      locs[i].address!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                widget.notifier.selectSearchResult(locs[i]);
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'City, place, or address',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : (_controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                _debounce?.cancel();
                                _scheduleSearch('');
                                setState(() {});
                              },
                            )
                          : null),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.4),
                ),
                onChanged: (v) {
                  setState(() {});
                  _scheduleSearch(v);
                },
                onSubmitted: (v) {
                  _debounce?.cancel();
                  final t = v.trim();
                  if (t.isEmpty) {
                    _scheduleSearch('');
                  } else {
                    _runSearch(t);
                  }
                },
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Material(
                  color: theme.colorScheme.errorContainer.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: theme.colorScheme.error,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: _resultsBody(theme)),
          ],
        ),
      ),
    );
  }
}

class _AIRecommendationSheet extends StatelessWidget {
  final WeatherMapState state;

  const _AIRecommendationSheet({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B4D8), Color(0xFF00F5D4)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on current weather at ${state.activeLocationLabel}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          // Recommendations
          ..._generateRecommendations(state).map((rec) {
            return _RecommendationCard(
              icon: rec['icon'] as IconData,
              title: rec['title'] as String,
              items: rec['items'] as List<String>,
              color: rec['color'] as Color,
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateRecommendations(WeatherMapState state) {
    final weather = state.currentMap?.currentWeather;
    if (weather == null) {
      return [
        {
          'icon': Icons.info,
          'title': 'No Data',
          'items': ['Weather data unavailable'],
          'color': Colors.grey,
        },
      ];
    }

    final temp = weather.temperature;
    final wind = weather.windSpeed;
    final precip = weather.precipitation ?? 0;
    final desc = weather.description.toLowerCase();

    final canDo = <String>[];
    final avoid = <String>[];

    // Temperature-based
    if (temp > 25) {
      canDo.addAll(['swimming', 'beach visit', 'sunscreen essential']);
      avoid.addAll(['intense midday sun exposure']);
    } else if (temp > 15) {
      canDo.addAll(['walking', 'jogging', 'cycling', 'outdoor dining']);
    } else if (temp > 5) {
      canDo.addAll(['light outdoor activities', 'sightseeing']);
      avoid.addAll(['extended outdoor exposure without jacket']);
    } else {
      canDo.addAll(['indoor activities', 'museums', 'cafes']);
      avoid.addAll(['long outdoor stays']);
    }

    // Wind-based
    if (wind > 15) {
      avoid.addAll(['boating', 'drone flying', 'cycling (high profile)']);
      canDo.addAll(['wind-protected hiking']);
    } else if (wind > 8) {
      canDo.addAll(['kite flying', 'sailing (experienced)']);
    } else {
      canDo.addAll(['drone flying', 'picnics']);
    }

    // Precipitation-based
    if (precip > 2) {
      avoid.addAll(['picnics', 'hiking (risk of flash floods)']);
      canDo.addAll(['cozy indoor time']);
    } else if (precip > 0) {
      avoid.addAll(['beach day']);
      canDo.addAll(['short walks with umbrella']);
    } else {
      canDo.addAll(['stargazing', 'outdoor events']);
    }

    // Weather condition keywords
    if (desc.contains('storm') || desc.contains('thunder')) {
      avoid.addAll(['outdoor activities', 'swimming', 'climbing']);
      canDo.addAll(['indoor safety']);
    }

    if (desc.contains('clear') || desc.contains('sunny')) {
      canDo.addAll(['photography', 'sunrise/sunset viewing']);
    }

    // Always good
    if (temp > 10 && wind < 10 && precip == 0) {
      canDo.addAll(['road trip', 'park visit', 'outdoor sports']);
    }

    // Remove duplicates, limit lists
    final uniqueCanDo = canDo.toSet().take(5).toList();
    final uniqueAvoid = avoid.toSet().take(5).toList();

    return [
      {
        'icon': Icons.check_circle,
        'title': 'Good For',
        'items': uniqueCanDo.isEmpty
            ? ['general outdoor activities']
            : uniqueCanDo,
        'color': Colors.green,
      },
      {
        'icon': Icons.cancel,
        'title': 'Avoid',
        'items': uniqueAvoid.isEmpty ? ['no major concerns'] : uniqueAvoid,
        'color': Colors.red,
      },
    ];
  }
}

class _RecommendationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;
  final Color color;

  const _RecommendationCard({
    required this.icon,
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.grey.shade600)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D2D3A),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AIFab extends StatelessWidget {
  final VoidCallback onPressed;

  const _AIFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF00B4D8),
      icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
      label: const Text(
        'AI Recommendations',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
    );
  }
}
