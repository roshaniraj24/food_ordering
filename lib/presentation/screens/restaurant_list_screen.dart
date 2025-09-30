import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../widgets/restaurant_card_simple.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_filter.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/cart_floating_button.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/floating_particles.dart';
import '../../data/models/models.dart';
import 'menu_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  double? _selectedMinRating;

  @override
  void initState() {
    super.initState();
    // Load restaurants on screen init
    context.read<RestaurantBloc>().add(const LoadRestaurants());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF74B9FF), Color(0xFFE84393), Color(0xFF00CEC9)],
          ).createShader(bounds),
          child: const Text(
            '🍕 FoodNeon',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 28,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF21262D),
                Color(0xFF30363D),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF74B9FF),
                blurRadius: 20,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF74B9FF), Color(0xFFE84393)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF74B9FF).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                context.read<RestaurantBloc>().add(const RefreshRestaurants());
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xFF0D1117),
                ],
                stops: [0.0, 0.8],
              ),
            ),
          ),
          
          // Floating particles
          const FloatingParticles(
            numberOfParticles: 15,
            particleColor: Color(0xFF74B9FF),
          ),
          
          // Main content
          Column(
          children: [
            // Neon search bar
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF21262D),
                    Color(0xFF30363D),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                border: Border.all(
                  color: const Color(0xFF74B9FF).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF74B9FF).withOpacity(0.2),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                  BoxShadow(
                    color: const Color(0xFFE84393).withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: SearchBarWidget(
                controller: _searchController,
                onChanged: (query) {
                  context.read<RestaurantBloc>().add(SearchRestaurants(query));
                },
                hintText: 'Search restaurants...',
              ),
            ),
          
          // Category filter
          CategoryFilter(
            selectedCategory: _selectedCategory,
            selectedMinRating: _selectedMinRating,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
              context.read<RestaurantBloc>().add(FilterRestaurants(
                category: category,
                minRating: _selectedMinRating,
              ));
            },
            onRatingChanged: (rating) {
              setState(() {
                _selectedMinRating = rating;
              });
              context.read<RestaurantBloc>().add(FilterRestaurants(
                category: _selectedCategory,
                minRating: rating,
              ));
            },
          ),
          
          // Restaurant list
          Expanded(
            child: BlocBuilder<RestaurantBloc, RestaurantState>(
              builder: (context, state) {
                if (state is RestaurantLoading) {
                  return const LoadingWidget(showShimmer: true);
                } else if (state is RestaurantError) {
                  return ErrorWidgetCustom(
                    message: state.failure.message,
                    onRetry: () {
                      context.read<RestaurantBloc>().add(const LoadRestaurants());
                    },
                  );
                } else if (state is RestaurantLoaded) {
                  if (state.restaurants.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No restaurants found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<RestaurantBloc>().add(const RefreshRestaurants());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = state.restaurants[index];
                        return FadeInAnimation(
                          delay: Duration(milliseconds: index * 100),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: RestaurantCard(
                              restaurant: restaurant,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        MenuScreen(restaurant: restaurant),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOutCubic;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));

                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: const CartFloatingButton(),
    );
  }
}