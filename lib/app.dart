import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/mock_restaurant_repository.dart';
import '../data/repositories/mock_order_repository.dart';
import '../presentation/bloc/bloc.dart';
import '../presentation/theme/app_theme.dart';
import '../presentation/screens/restaurant_list_screen.dart';
import '../presentation/screens/cart_screen.dart';

class FoodOrderApp extends StatelessWidget {
  const FoodOrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => MockRestaurantRepository()),
        RepositoryProvider(create: (context) => MockOrderRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => RestaurantBloc(
              restaurantRepository: context.read<MockRestaurantRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => MenuBloc(
              restaurantRepository: context.read<MockRestaurantRepository>(),
            ),
          ),
          BlocProvider(create: (context) => CartBloc()),
          BlocProvider(
            create: (context) => OrderBloc(
              orderRepository: context.read<MockOrderRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Food Order App',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const RestaurantListScreen(),
            '/cart': (context) => const CartScreen(),
          },
          builder: (context, child) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D1117),
                    Color(0xFF161B22),
                    Color(0xFF21262D),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Animated background particles/stars
                  ...List.generate(50, (index) {
                    return Positioned(
                      left: (index * 37) % MediaQuery.of(context).size.width,
                      top: (index * 67) % MediaQuery.of(context).size.height,
                      child: Container(
                        width: 2,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFF74B9FF).withOpacity(0.6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF74B9FF).withOpacity(0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (child != null) child,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}