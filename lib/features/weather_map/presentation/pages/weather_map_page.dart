import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/weather_layer.dart';
import '../../domain/entities/location.dart';
import '../controllers/weather_map_controller.dart';
import '../states/weather_map_state.dart';
import 'package:windify_v2/core/config/env_config.dart';

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
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom + 1);
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom - 1);
  }

  void _onMapTapped(LatLng point) {
    ref.read(weatherMapNotifierProvider.notifier).pinLocation(point);
  }

  @override
  Widget build(BuildContext context) {
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
              child: Icon(
                Icons.waves,
                size: 20,
                color: _getLayerColor(state.selectedLayer),
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
                  state.locationName ?? state.selectedLayer.displayName,
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
            icon: const Icon(Icons.search, color: Colors.white, size: 22),
            onPressed: () => _showSearchDialog(context, notifier),
          ),
          IconButton(
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
          // Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildInfoCard(context, state),
                const Spacer(),
              ],
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
          // Current location button (top-right-ish)
          Positioned(
            right: 16,
            top: kToolbarHeight + 16,
            child: _CurrentLocationButton(
              onPressed: () => notifier.fetchCurrentLocation(),
            ),
          ),
          // Loading overlay
          if (state.isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
          // Error overlay
          if (state.error != null) _buildErrorOverlay(context, state, notifier),
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
        initialCenter: state.selectedLocation,
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
        // Weather overlay - subtle colored tint
        if (state.selectedLayer == WeatherLayer.radar)
          Opacity(
            opacity: 0.12,
            child: TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v12/tiles/{z}/{x}/{y}?access_token={accessToken}',
              additionalOptions: {'accessToken': mapboxToken},
              userAgentPackageName: 'com.windify.app',
            ),
          ),
        // Current location marker
        if (state.locationName == 'Current Location')
          MarkerLayer(
            markers: [
              Marker(
                width: 24,
                height: 24,
                point: state.selectedLocation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        // Pinned location marker
        else if (state.locationName == 'Pinned Location')
          MarkerLayer(
            markers: [
              Marker(
                width: 28,
                height: 40,
                point: state.selectedLocation,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
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

  Widget _buildInfoCard(BuildContext context, WeatherMapState state) {
    if (state.currentMap == null) return const SizedBox.shrink();

    final weather = state.currentMap!.currentWeather;
    final wind = state.currentMap!.windInfo;
    final wave = state.currentMap!.waveInfo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getLayerColor(
                      state.selectedLayer,
                    ).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getLayerColor(
                        state.selectedLayer,
                      ).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _getLayerIcon(state.selectedLayer),
                    size: 24,
                    color: _getLayerColor(state.selectedLayer),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.currentMap!.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.currentMap!.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            // Data cards (dynamic per layer)
            if (state.selectedLayer == WeatherLayer.radar &&
                weather != null) ...[
              Row(
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
              ),
            ] else if (state.selectedLayer == WeatherLayer.wind &&
                wind != null) ...[
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
            ] else if (state.selectedLayer == WeatherLayer.wave &&
                wave != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _DataCard(
                      icon: Icons.waves,
                      label: 'Wave Height',
                      value:
                          '${wave.swellHeight?.toStringAsFixed(1) ?? "N/A"} m',
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
              ),
            ] else ...[
              // Fallback basic info
              Row(
                children: [
                  Expanded(
                    child: _DataCard(
                      icon: Icons.thermostat,
                      label: 'Temperature',
                      value: weather != null
                          ? '${weather.temperature.toStringAsFixed(1)}°C'
                          : 'N/A',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DataCard(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: weather != null ? '${weather.humidity}%' : 'N/A',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),
            // Meta info
            Row(
              children: [
                Expanded(
                  child: _InfoField(
                    icon: Icons.update,
                    label: 'Last Update',
                    value: _formatTime(state.currentMap!.updatedAt),
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
          ],
        ),
      ),
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
              onPressed: () {},
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
    showDialog(
      context: context,
      builder: (ctx) => _SearchDialog(notifier: notifier),
    );
  }

  void _showAIRecommendationSheet(BuildContext context, WeatherMapState state) {
    if (state.currentMap == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AIRecommendationSheet(state: state),
    );
  }

  Widget _buildErrorOverlay(
    BuildContext context,
    WeatherMapState state,
    WeatherMapNotifier notifier,
  ) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 16),
            Text(
              'Failed to load data',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => notifier.refresh(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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

    return Expanded(
      child: Container(
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

class _CurrentLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CurrentLocationButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.gps_fixed,
            size: 20,
            color: Color(0xFF0D1B2A),
          ),
        ),
      ),
    );
  }
}

class _SearchDialog extends StatefulWidget {
  final WeatherMapNotifier notifier;

  const _SearchDialog({required this.notifier});

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final _controller = TextEditingController();
  bool _isSearching = false;
  List<Location> _results = [];

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await widget.notifier.searchPlaces(query);
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Search Location',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter city, place, or coordinates',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : (_controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              _search('');
                            },
                          )
                        : null),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            onChanged: _search,
            onSubmitted: _search,
          ),
          const SizedBox(height: 12),
          if (_results.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (ctx, i) {
                  final loc = _results[i];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.grey),
                    title: Text(loc.name ?? 'Unknown'),
                    subtitle: loc.address != null
                        ? Text(
                            loc.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.notifier.selectSearchResult(loc);
                    },
                  );
                },
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
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
            'Based on current weather at ${state.locationName ?? "your location"}',
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
