import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingParticles extends StatefulWidget {
  final int numberOfParticles;
  final Color particleColor;

  const FloatingParticles({
    super.key,
    this.numberOfParticles = 20,
    this.particleColor = const Color(0xFF74B9FF),
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
  }

  void _initializeParticles() {
    _controllers = [];
    _animations = [];
    _particles = [];

    for (int i = 0; i < widget.numberOfParticles; i++) {
      final controller = AnimationController(
        duration: Duration(
          milliseconds: 3000 + math.Random().nextInt(4000),
        ),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));

      _controllers.add(controller);
      _animations.add(animation);
      _particles.add(Particle.random());

      controller.repeat();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: List.generate(widget.numberOfParticles, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                final particle = _particles[index];
                final progress = _animations[index].value;
                
                // Calculate position based on animation progress
                final x = particle.startX + 
                    (particle.endX - particle.startX) * progress;
                final y = particle.startY + 
                    (particle.endY - particle.startY) * progress;

                // Reset particle when animation completes
                if (progress >= 1.0) {
                  _particles[index] = Particle.random();
                }

                return Positioned(
                  left: x * constraints.maxWidth,
                  top: y * constraints.maxHeight,
                  child: Transform.rotate(
                    angle: progress * 2 * math.pi,
                    child: Container(
                      width: particle.size,
                      height: particle.size,
                      decoration: BoxDecoration(
                        color: widget.particleColor.withOpacity(
                          particle.opacity * (1.0 - progress),
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.particleColor.withOpacity(0.1),
                            blurRadius: particle.size / 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}

class Particle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final double opacity;

  Particle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.opacity,
  });

  factory Particle.random() {
    final random = math.Random();
    return Particle(
      startX: random.nextDouble(),
      startY: 1.2, // Start below screen
      endX: random.nextDouble(),
      endY: -0.2, // End above screen
      size: 2.0 + random.nextDouble() * 6.0,
      opacity: 0.1 + random.nextDouble() * 0.4,
    );
  }
}