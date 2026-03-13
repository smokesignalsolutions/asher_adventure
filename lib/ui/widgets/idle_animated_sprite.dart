import 'dart:math';
import 'package:flutter/material.dart';

class IdleAnimatedSprite extends StatefulWidget {
  final String imagePath;
  final double size;
  final double phaseOffset;
  final bool animate;

  const IdleAnimatedSprite({
    super.key,
    required this.imagePath,
    required this.size,
    this.phaseOffset = 0.0,
    this.animate = true,
  });

  @override
  State<IdleAnimatedSprite> createState() => _IdleAnimatedSpriteState();
}

class _IdleAnimatedSpriteState extends State<IdleAnimatedSprite>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(IdleAnimatedSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return _buildImage();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 * pi + widget.phaseOffset;
        // Vertical bob: 2.5px amplitude, 1.5s period (half of 3s controller)
        final bobY = sin(t * 2) * 2.5;
        // Breathing scale: 1.0 to 1.02, 2s period (2/3 of 3s controller)
        final scale = 1.0 + sin(t * 1.5) * 0.02;

        return Transform.translate(
          offset: Offset(0, bobY),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      widget.imagePath,
      width: widget.size,
      height: widget.size,
      filterQuality: FilterQuality.none,
      errorBuilder: (context, error, stackTrace) => Container(
        width: widget.size,
        height: widget.size,
        color: Colors.grey[800],
        child: Icon(Icons.person, size: widget.size * 0.5),
      ),
    );
  }
}
