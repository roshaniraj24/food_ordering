import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:food_order_app/core/failures.dart';
import 'package:food_order_app/data/models/models.dart';
import 'package:food_order_app/data/repositories/restaurant_repository.dart';
import 'package:food_order_app/presentation/bloc/restaurant/restaurant_bloc.dart';

class MockRestaurantRepository extends Mock implements RestaurantRepository {}

void main() {
  group('RestaurantBloc Tests', () {
    late RestaurantBloc restaurantBloc;
    late MockRestaurantRepository mockRepository;

    final testRestaurants = [
      Restaurant(
        id: '1',
        name: 'Test Restaurant 1',
        description: 'A test restaurant',
        imageUrl: 'https://test.com/restaurant1.jpg',
        rating: 4.5,
        deliveryTime: '30-45 min',
        deliveryFee: 2.99,
        minimumOrder: 15.0,
        cuisineTypes: const ['Italian', 'Pizza'],
        isOpen: true,
        address: '123 Test St',
        phone: '+1234567890',
        priceRange: '\$\$',
      ),
      Restaurant(
        id: '2',
        name: 'Pizza Palace',
        description: 'Best pizza in town',
        imageUrl: 'https://test.com/restaurant2.jpg',
        rating: 4.2,
        deliveryTime: '25-35 min',
        deliveryFee: 1.99,
        minimumOrder: 12.0,
        cuisineTypes: const ['Italian', 'Pizza'],
        isOpen: true,
        address: '456 Pizza Ave',
        phone: '+1234567891',
        priceRange: '\$',
      ),
    ];

    setUp(() {
      mockRepository = MockRestaurantRepository();
      restaurantBloc = RestaurantBloc(restaurantRepository: mockRepository);
    });

    tearDown(() {
      restaurantBloc.close();
    });

    test('initial state is RestaurantInitial', () {
      expect(restaurantBloc.state, const RestaurantInitial());
    });

    group('LoadRestaurants', () {
      blocTest<RestaurantBloc, RestaurantState>(
        'emits [RestaurantLoading, RestaurantLoaded] when LoadRestaurants succeeds',
        build: () {
          when(() => mockRepository.getRestaurants())
              .thenAnswer((_) async => Right(testRestaurants));
          return restaurantBloc;
        },
        act: (bloc) => bloc.add(const LoadRestaurants()),
        expect: () => [
          const RestaurantLoading(),
          RestaurantLoaded(restaurants: testRestaurants),
        ],
        verify: (_) {
          verify(() => mockRepository.getRestaurants()).called(1);
        },
      );

      blocTest<RestaurantBloc, RestaurantState>(
        'emits [RestaurantLoading, RestaurantError] when LoadRestaurants fails',
        build: () {
          when(() => mockRepository.getRestaurants())
              .thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return restaurantBloc;
        },
        act: (bloc) => bloc.add(const LoadRestaurants()),
        expect: () => [
          const RestaurantLoading(),
          const RestaurantError(message: 'Server error'),
        ],
        verify: (_) {
          verify(() => mockRepository.getRestaurants()).called(1);
        },
      );
    });

    group('SearchRestaurants', () {
      const searchQuery = 'Pizza';
      final searchResults = [testRestaurants[1]]; // Only Pizza Palace

      blocTest<RestaurantBloc, RestaurantState>(
        'emits [RestaurantLoading, RestaurantLoaded] when SearchRestaurants succeeds',
        build: () {
          when(() => mockRepository.searchRestaurants(searchQuery))
              .thenAnswer((_) async => Right(searchResults));
          return restaurantBloc;
        },
        act: (bloc) => bloc.add(const SearchRestaurants(query: searchQuery)),
        expect: () => [
          const RestaurantLoading(),
          RestaurantLoaded(restaurants: searchResults),
        ],
        verify: (_) {
          verify(() => mockRepository.searchRestaurants(searchQuery)).called(1);
        },
      );

      blocTest<RestaurantBloc, RestaurantState>(
        'emits [RestaurantLoading, RestaurantError] when SearchRestaurants fails',
        build: () {
          when(() => mockRepository.searchRestaurants(searchQuery))
              .thenAnswer((_) async => const Left(NetworkFailure('Network error')));
          return restaurantBloc;
        },
        act: (bloc) => bloc.add(const SearchRestaurants(query: searchQuery)),
        expect: () => [
          const RestaurantLoading(),
          const RestaurantError(message: 'Network error'),
        ],
        verify: (_) {
          verify(() => mockRepository.searchRestaurants(searchQuery)).called(1);
        },
      );

      blocTest<RestaurantBloc, RestaurantState>(
        'emits [RestaurantLoading, RestaurantLoaded] with empty list when search returns no results',
        build: () {
          when(() => mockRepository.searchRestaurants('NonExistent'))
              .thenAnswer((_) async => const Right([]));
          return restaurantBloc;
        },
        act: (bloc) => bloc.add(const SearchRestaurants(query: 'NonExistent')),
        expect: () => [
          const RestaurantLoading(),
          const RestaurantLoaded(restaurants: []),
        ],
        verify: (_) {
          verify(() => mockRepository.searchRestaurants('NonExistent')).called(1);
        },
      );
    });

    group('FilterRestaurantsByCuisine', () {
      const cuisineFilter = 'Italian';
      final filteredResults = testRestaurants; // Both have Italian cuisine

      blocTest<RestaurantBloc, RestaurantState>(
        'emits [RestaurantLoading, RestaurantLoaded] when FilterRestaurantsByCuisine succeeds',
        build: () {
          when(() => mockRepository.getRestaurantsByCuisine(cuisineFilter))
              .thenAnswer((_) async => Right(filteredResults));
          return restaurantBloc;
        },
        act: (bloc) => bloc.add(const FilterRestaurantsByCuisine(cuisine: cuisineFilter)),
        expect: () => [
          const RestaurantLoading(),
          RestaurantLoaded(restaurants: filteredResults),
        ],
        verify: (_) {
          verify(() => mockRepository.getRestaurantsByCuisine(cuisineFilter)).called(1);
        },
      );

      blocTest<RestaurantBloc, RestaurantState>(
        'emits [RestaurantLoading, RestaurantError] when FilterRestaurantsByCuisine fails',
        build: () {
          when(() => mockRepository.getRestaurantsByCuisine(cuisineFilter))
              .thenAnswer((_) async => const Left(CacheFailure('Cache error')));
          return restaurantBloc;
        },
        act: (bloc) => bloc.add(const FilterRestaurantsByCuisine(cuisine: cuisineFilter)),
        expect: () => [
          const RestaurantLoading(),
          const RestaurantError(message: 'Cache error'),
        ],
        verify: (_) {
          verify(() => mockRepository.getRestaurantsByCuisine(cuisineFilter)).called(1);
        },
      );
    });

    group('RefreshRestaurants', () {
      blocTest<RestaurantBloc, RestaurantState>(
        'emits [RestaurantLoading, RestaurantLoaded] when RefreshRestaurants succeeds',
        build: () {
          when(() => mockRepository.getRestaurants())
              .thenAnswer((_) async => Right(testRestaurants));
          return restaurantBloc;
        },
        act: (bloc) => bloc.add(const RefreshRestaurants()),
        expect: () => [
          const RestaurantLoading(),
          RestaurantLoaded(restaurants: testRestaurants),
        ],
        verify: (_) {
          verify(() => mockRepository.getRestaurants()).called(1);
        },
      );

      blocTest<RestaurantBloc, RestaurantState>(
        'emits [RestaurantLoading, RestaurantError] when RefreshRestaurants fails',
        build: () {
          when(() => mockRepository.getRestaurants())
              .thenAnswer((_) async => const Left(ServerFailure('Refresh failed')));
          return restaurantBloc;
        },
        act: (bloc) => bloc.add(const RefreshRestaurants()),
        expect: () => [
          const RestaurantLoading(),
          const RestaurantError(message: 'Refresh failed'),
        ],
        verify: (_) {
          verify(() => mockRepository.getRestaurants()).called(1);
        },
      );
    });

    group('State Transitions', () {
      blocTest<RestaurantBloc, RestaurantState>(
        'maintains state when multiple events are processed sequentially',
        build: () {
          when(() => mockRepository.getRestaurants())
              .thenAnswer((_) async => Right(testRestaurants));
          when(() => mockRepository.searchRestaurants('Pizza'))
              .thenAnswer((_) async => Right([testRestaurants[1]]));
          return restaurantBloc;
        },
        act: (bloc) {
          bloc.add(const LoadRestaurants());
          bloc.add(const SearchRestaurants(query: 'Pizza'));
        },
        expect: () => [
          const RestaurantLoading(),
          RestaurantLoaded(restaurants: testRestaurants),
          const RestaurantLoading(),
          RestaurantLoaded(restaurants: [testRestaurants[1]]),
        ],
        verify: (_) {
          verify(() => mockRepository.getRestaurants()).called(1);
          verify(() => mockRepository.searchRestaurants('Pizza')).called(1);
        },
      );
    });

    group('Error Handling', () {
      blocTest<RestaurantBloc, RestaurantState>(
        'handles repository exceptions gracefully',
        build: () {
          when(() => mockRepository.getRestaurants())
              .thenThrow(Exception('Unexpected error'));
          return restaurantBloc;
        },
        act: (bloc) => bloc.add(const LoadRestaurants()),
        expect: () => [
          const RestaurantLoading(),
          const RestaurantError(message: 'An unexpected error occurred'),
        ],
        verify: (_) {
          verify(() => mockRepository.getRestaurants()).called(1);
        },
      );
    });
  });
}