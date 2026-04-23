import 'package:flutter/material.dart';

class MapControlsWidget extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  const MapControlsWidget({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          FloatingActionButton(
            onPressed: onZoomIn,
            mini: true,
            child: const Icon(Icons.add),
            tooltip: 'Zoom In',
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: onZoomOut,
            mini: true,
            child: const Icon(Icons.remove),
            tooltip: 'Zoom Out',
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: onReset,
            mini: true,
            child: const Icon(Icons.refresh),
            tooltip: 'Reset View',
          ),
        ],
      ),
    );
  }
}
