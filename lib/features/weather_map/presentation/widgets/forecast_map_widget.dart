import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/weather_layer.dart';
import '../controllers/weather_map_controller.dart';
import 'map_controls_widget.dart';

class ForecastMapWidget extends ConsumerWidget {
  const ForecastMapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherMapNotifierProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(weatherMapNotifierProvider.notifier).loadInitialData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final map = state.currentMap;
    if (map == null) {
      return const Center(child: Text('No map data available'));
    }

    // Placeholder for map implementation
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getLayerIcon(state.selectedLayer),
                  size: 64,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(height: 16),
                Text(
                  map.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  map.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Updated: ${map.updatedAt.toLocal()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Map implementation placeholder\n(Ready for flutter_map, google_maps_flutter, or mapbox)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        MapControlsWidget(
          onZoomIn: () {
            // TODO: Implement zoom in
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zoom In - Coming Soon!')),
            );
          },
          onZoomOut: () {
            // TODO: Implement zoom out
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zoom Out - Coming Soon!')),
            );
          },
          onReset: () {
            // TODO: Implement reset view
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reset View - Coming Soon!')),
            );
          },
        ),
      ],
    );
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
}
