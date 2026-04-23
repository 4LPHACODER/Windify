import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/weather_layer.dart';
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
  static const LatLng _defaultCenter = LatLng(9.0780, 126.1986);
  static const double _defaultZoom = 5.0;

  @override
  void dispose() {
    _mapController.dispose();
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

  void _resetView() {
    _mapController.move(_defaultCenter, _defaultZoom);
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
                  state.selectedLayer.displayName,
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
            onPressed: () {},
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
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
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
        initialCenter: _defaultCenter,
        initialZoom: _defaultZoom,
        minZoom: 2,
        maxZoom: 12,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}?access_token={accessToken}',
          additionalOptions: {'accessToken': mapboxToken},
          userAgentPackageName: 'com.windify.app',
        ),
        Opacity(
          opacity: 0.25,
          child: TileLayer(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}?access_token={accessToken}',
            additionalOptions: {'accessToken': mapboxToken},
            userAgentPackageName: 'com.windify.app',
          ),
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
          tooltip: 'Reset view',
          onPressed: _resetView,
        ),
        const SizedBox(height: 10),
        _MapControlButton(
          icon: Icons.refresh,
          tooltip: 'Refresh',
          onPressed: notifier.loadInitialData,
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, WeatherMapState state) {
    if (state.currentMap == null) return const SizedBox.shrink();

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
              onPressed: () => notifier.loadInitialData(),
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
