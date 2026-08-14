import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dynamic Watermark Layer
/// Renders an anti-leak traceability watermark over video playback surfaces.
/// Moves position periodically and uses low opacity to deter illicit screen capture.
class DynamicWatermarkLayer extends StatefulWidget {
  final String userIdentifier;
  final String? deviceIdSuffix;
  final bool isVisible;

  const DynamicWatermarkLayer({
    super.key,
    required this.userIdentifier,
    this.deviceIdSuffix,
    this.isVisible = true,
  });

  @override
  State<DynamicWatermarkLayer> createState() => _DynamicWatermarkLayerState();
}

class _DynamicWatermarkLayerState extends State<DynamicWatermarkLayer> {
  Timer? _positionTimer;
  Alignment _currentAlignment = Alignment.topRight;
  final Random _random = Random();

  final List<Alignment> _possibleAlignments = const [
    Alignment(-0.7, -0.6),
    Alignment(0.7, -0.6),
    Alignment(-0.6, 0.4),
    Alignment(0.6, 0.5),
    Alignment(0.0, -0.3),
    Alignment(0.0, 0.3),
  ];

  @override
  void initState() {
    super.initState();
    _startPositionCycle();
  }

  void _startPositionCycle() {
    _positionTimer = Timer.periodic(const Duration(seconds: 14), (_) {
      if (mounted) {
        setState(() {
          _currentAlignment = _possibleAlignments[_random.nextInt(_possibleAlignments.length)];
        });
      }
    });
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    super.dispose();
  }

  String _generateWatermarkText() {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final deviceSuffix = widget.deviceIdSuffix ?? 'EDU-${(now.millisecond % 9000 + 1000)}';
    return '${widget.userIdentifier} • $deviceSuffix • $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedAlign(
        alignment: _currentAlignment,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Opacity(
            opacity: 0.32,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _generateWatermarkText(),
                style: GoogleFonts.robotoMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
