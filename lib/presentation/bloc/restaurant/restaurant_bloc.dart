import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/restaurant_repository.dart';
import 'restaurant_event.dart';
import 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantRepository _restaurantRepository;

  RestaurantBloc({
    required RestaurantRepository restaurantRepository,
  })  : _restaurantRepository = restaurantRepository,
        super(const RestaurantInitial()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<RefreshRestaurants>(_onRefreshRestaurants);
    on<FilterRestaurants>(_onFilterRestaurants);
    on<SearchRestaurants>(_onSearchRestaurants);
  }

  Future<void> _onLoadRestaurants(
    LoadRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());

    final result = await _restaurantRepository.getRestaurants(
      category: event.category,
      searchQuery: event.searchQuery,
      minRating: event.minRating,
    );

    result.fold(
      (failure) => emit(RestaurantError(failure)),
      (restaurants) => emit(RestaurantLoaded(
        restaurants: restaurants,
        currentCategory: event.category,
        currentSearchQuery: event.searchQuery,
        currentMinRating: event.minRating,
      )),
    );
  }

  Future<void> _onRefreshRestaurants(
    RefreshRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    final currentState = state;
    if (currentState is RestaurantLoaded) {
      add(LoadRestaurants(
        category: currentState.currentCategory,
        searchQuery: currentState.currentSearchQuery,
        minRating: currentState.currentMinRating,
      ));
    } else {
      add(const LoadRestaurants());
    }
  }

  Future<void> _onFilterRestaurants(
    FilterRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    final currentState = state;
    String? searchQuery;
    
    if (currentState is RestaurantLoaded) {
      searchQuery = currentState.currentSearchQuery;
    }

    add(LoadRestaurants(
      category: event.category,
      searchQuery: searchQuery,
      minRating: event.minRating,
    ));
  }

  Future<void> _onSearchRestaurants(
    SearchRestaurants event,
    Emitter<RestaurantState> emit,
  ) async {
    final currentState = state;
    String? category;
    double? minRating;
    
    if (currentState is RestaurantLoaded) {
      category = currentState.currentCategory;
      minRating = currentState.currentMinRating;
    }

    add(LoadRestaurants(
      category: category,
      searchQuery: event.query.isEmpty ? null : event.query,
      minRating: minRating,
    ));
  }
}