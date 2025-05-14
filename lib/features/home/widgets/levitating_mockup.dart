import 'package:flutter/material.dart';

class LevitatingMockup extends StatefulWidget {
  final String imageAsset;
  final double? width;
  final double? height;
  final double verticalShift;
  final double scaleAmplitude;
  final Duration animationDuration;
  final double startPhase;
  final BoxFit fit;
  final List<BoxShadow>? shadows;
  final Color? backgroundColor;

  const LevitatingMockup({
    super.key,
    required this.imageAsset,
    this.width,
    this.height,
    this.verticalShift = -10.0,
    this.scaleAmplitude = 0.02,
    this.animationDuration = const Duration(seconds: 4),
    this.startPhase = 0.0,
    this.fit = BoxFit.contain,
    this.shadows,
    this.backgroundColor,
  });

  @override
  State<LevitatingMockup> createState() => _LevitatingMockupState();
}

class _LevitatingMockupState extends State<LevitatingMockup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _verticalAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);

    if (widget.startPhase > 0.0) {
      _controller.value = widget.startPhase % 1.0;
    }

    _verticalAnimation = Tween<double>(
      begin: -widget.verticalShift,
      end: widget.verticalShift,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0 - widget.scaleAmplitude,
      end: 1.0 + widget.scaleAmplitude,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..translate(0.0, _verticalAnimation.value)
              ..scale(_scaleAnimation.value),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                boxShadow: widget.shadows,
              ),
              child: Image.asset(
                widget.imageAsset,
                fit: widget.fit,
                width: widget.width,
                height: widget.height,
              ),
            ),
          );
        },
      ),
    );
  }
}