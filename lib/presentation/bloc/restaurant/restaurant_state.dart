import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';
import '../../../core/failures.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {
  const RestaurantInitial();
}

class RestaurantLoading extends RestaurantState {
  const RestaurantLoading();
}

class RestaurantLoaded extends RestaurantState {
  final List<Restaurant> restaurants;
  final String? currentCategory;
  final String? currentSearchQuery;
  final double? currentMinRating;

  const RestaurantLoaded({
    required this.restaurants,
    this.currentCategory,
    this.currentSearchQuery,
    this.currentMinRating,
  });

  @override
  List<Object?> get props => [
        restaurants,
        currentCategory,
        currentSearchQuery,
        currentMinRating,
      ];

  RestaurantLoaded copyWith({
    List<Restaurant>? restaurants,
    String? currentCategory,
    String? currentSearchQuery,
    double? currentMinRating,
  }) {
    return RestaurantLoaded(
      restaurants: restaurants ?? this.restaurants,
      currentCategory: currentCategory ?? this.currentCategory,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      currentMinRating: currentMinRating ?? this.currentMinRating,
    );
  }
}

class RestaurantError extends RestaurantState {
  final Failure failure;

  const RestaurantError(this.failure);

  @override
  List<Object?> get props => [failure];
}