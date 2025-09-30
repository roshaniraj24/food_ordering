import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurants extends RestaurantEvent {
  final String? category;
  final String? searchQuery;
  final double? minRating;

  const LoadRestaurants({
    this.category,
    this.searchQuery,
    this.minRating,
  });

  @override
  List<Object?> get props => [category, searchQuery, minRating];
}

class RefreshRestaurants extends RestaurantEvent {
  const RefreshRestaurants();
}

class FilterRestaurants extends RestaurantEvent {
  final String? category;
  final double? minRating;

  const FilterRestaurants({
    this.category,
    this.minRating,
  });

  @override
  List<Object?> get props => [category, minRating];
}

class SearchRestaurants extends RestaurantEvent {
  final String query;

  const SearchRestaurants(this.query);

  @override
  List<Object?> get props => [query];
}