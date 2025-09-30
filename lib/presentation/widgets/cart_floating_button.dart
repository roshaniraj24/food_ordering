import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import 'animated_widgets.dart';

class CartFloatingButton extends StatefulWidget {
  const CartFloatingButton({super.key});

  @override
  State<CartFloatingButton> createState() => _CartFloatingButtonState();
}

class _CartFloatingButtonState extends State<CartFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousItemCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateOnItemAdded(int currentItemCount) {
    if (currentItemCount > _previousItemCount) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
    _previousItemCount = currentItemCount;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.isEmpty) {
          return const SizedBox.shrink();
        }

        _animateOnItemAdded(state.totalItems);

        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6C5CE7),
                      Color(0xFFE84393),
                      Color(0xFF74B9FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE84393).withOpacity(0.5),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                    ),
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Color(0xFF74B9FF),
                    size: 24,
                  ),
                  label: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF74B9FF), Color(0xFFE84393)],
                    ).createShader(bounds),
                    child: Text(
                      'Cart (${state.totalItems})',
                      style: const TextStyle(
                        color: Color(0xFF74B9FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            );
          },
        );
      },
    );
  }
}