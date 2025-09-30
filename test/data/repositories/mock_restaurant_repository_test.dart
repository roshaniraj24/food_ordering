import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_app/data/models/models.dart';
import 'package:food_order_app/data/repositories/mock_restaurant_repository.dart';

void main() {
  group('MockRestaurantRepository Tests', () {
    late MockRestaurantRepository repository;

    setUp(() {
      repository = MockRestaurantRepository();
    });

    test('should return list of restaurants', () async {
      // Act
      final result = await repository.getRestaurants();

      // Assert
      expect(result.isSuccess, true);
      final restaurants = result.getOrElse(() => []);
      expect(restaurants, isNotEmpty);
      expect(restaurants.length, greaterThan(0));
      
      // Verify restaurant properties
      final firstRestaurant = restaurants.first;
      expect(firstRestaurant.id, isNotEmpty);
      expect(firstRestaurant.name, isNotEmpty);
      expect(firstRestaurant.rating, greaterThan(0));
      expect(firstRestaurant.cuisineTypes, isNotEmpty);
    });

    test('should return restaurants with proper structure', () async {
      // Act
      final result = await repository.getRestaurants();

      // Assert
      expect(result.isSuccess, true);
      final restaurants = result.getOrElse(() => []);
      
      for (final restaurant in restaurants) {
        expect(restaurant.id, isNotEmpty);
        expect(restaurant.name, isNotEmpty);
        expect(restaurant.description, isNotEmpty);
        expect(restaurant.imageUrl, isNotEmpty);
        expect(restaurant.rating, inInclusiveRange(0.0, 5.0));
        expect(restaurant.deliveryTime, isNotEmpty);
        expect(restaurant.deliveryFee, greaterThanOrEqualTo(0));
        expect(restaurant.minimumOrder, greaterThanOrEqualTo(0));
        expect(restaurant.cuisineTypes, isNotEmpty);
        expect(restaurant.address, isNotEmpty);
        expect(restaurant.phone, isNotEmpty);
        expect(restaurant.priceRange, isNotEmpty);
      }
    });

    test('should return restaurant by id when it exists', () async {
      // Arrange
      final restaurantsResult = await repository.getRestaurants();
      final restaurants = restaurantsResult.getOrElse(() => []);
      final existingRestaurantId = restaurants.first.id;

      // Act
      final result = await repository.getRestaurant(existingRestaurantId);

      // Assert
      expect(result.isSuccess, true);
      final restaurant = result.getOrElse(() => throw Exception('Failed'));
      expect(restaurant.id, existingRestaurantId);
      expect(restaurant.name, isNotEmpty);
    });

    test('should return failure for non-existent restaurant id', () async {
      // Act
      final result = await repository.getRestaurant('non-existent-id');

      // Assert
      expect(result.isFailure, true);
      result.fold(
        (failure) => expect(failure.message, contains('not found')),
        (restaurant) => fail('Expected failure but got success'),
      );
    });

    test('should return menu items for existing restaurant', () async {
      // Arrange
      final restaurantsResult = await repository.getRestaurants();
      final restaurants = restaurantsResult.getOrElse(() => []);
      final existingRestaurantId = restaurants.first.id;

      // Act
      final result = await repository.getMenuItems(existingRestaurantId);

      // Assert
      expect(result.isSuccess, true);
      final menuItems = result.getOrElse(() => []);
      expect(menuItems, isNotEmpty);
      
      // Verify menu item properties
      final firstMenuItem = menuItems.first;
      expect(firstMenuItem.id, isNotEmpty);
      expect(firstMenuItem.name, isNotEmpty);
      expect(firstMenuItem.price, greaterThan(0));
      expect(firstMenuItem.category, isNotEmpty);
    });

    test('should return menu items with proper structure', () async {
      // Arrange
      final restaurantsResult = await repository.getRestaurants();
      final restaurants = restaurantsResult.getOrElse(() => []);
      final existingRestaurantId = restaurants.first.id;

      // Act
      final result = await repository.getMenuItems(existingRestaurantId);

      // Assert
      expect(result.isSuccess, true);
      final menuItems = result.getOrElse(() => []);
      
      for (final menuItem in menuItems) {
        expect(menuItem.id, isNotEmpty);
        expect(menuItem.name, isNotEmpty);
        expect(menuItem.description, isNotEmpty);
        expect(menuItem.price, greaterThan(0));
        expect(menuItem.imageUrl, isNotEmpty);
        expect(menuItem.category, isNotEmpty);
        expect(menuItem.allergens, isA<List<String>>());
        expect(menuItem.preparationTime, greaterThan(0));
        expect(menuItem.isAvailable, isA<bool>());
        expect(menuItem.isVegetarian, isA<bool>());
        expect(menuItem.isVegan, isA<bool>());
        expect(menuItem.isSpicy, isA<bool>());
      }
    });

    test('should return failure for menu items of non-existent restaurant', () async {
      // Act
      final result = await repository.getMenuItems('non-existent-id');

      // Assert
      expect(result.isFailure, true);
      result.fold(
        (failure) => expect(failure.message, contains('not found')),
        (menuItems) => fail('Expected failure but got success'),
      );
    });

    test('should return filtered restaurants by cuisine', () async {
      // Arrange
      const cuisineFilter = 'Italian';

      // Act
      final result = await repository.getRestaurantsByCuisine(cuisineFilter);

      // Assert
      expect(result.isSuccess, true);
      final restaurants = result.getOrElse(() => []);
      expect(restaurants, isNotEmpty);
      
      // Verify all returned restaurants have Italian cuisine
      for (final restaurant in restaurants) {
        expect(restaurant.cuisineTypes, contains(cuisineFilter));
      }
    });

    test('should return empty list for non-existent cuisine filter', () async {
      // Act
      final result = await repository.getRestaurantsByCuisine('NonExistentCuisine');

      // Assert
      expect(result.isSuccess, true);
      final restaurants = result.getOrElse(() => []);
      expect(restaurants, isEmpty);
    });

    test('should search restaurants by name', () async {
      // Arrange
      const query = 'Pizza';

      // Act
      final result = await repository.searchRestaurants(query);

      // Assert
      expect(result.isSuccess, true);
      final restaurants = result.getOrElse(() => []);
      expect(restaurants, isNotEmpty);
      
      // Verify search results contain the query term
      for (final restaurant in restaurants) {
        final nameContainsQuery = restaurant.name.toLowerCase().contains(query.toLowerCase());
        final cuisineContainsQuery = restaurant.cuisineTypes.any(
          (cuisine) => cuisine.toLowerCase().contains(query.toLowerCase()),
        );
        expect(nameContainsQuery || cuisineContainsQuery, true);
      }
    });

    test('should return empty list for search with no matches', () async {
      // Act
      final result = await repository.searchRestaurants('XYZNonExistentQuery');

      // Assert
      expect(result.isSuccess, true);
      final restaurants = result.getOrElse(() => []);
      expect(restaurants, isEmpty);
    });

    test('should simulate network delay', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      await repository.getRestaurants();

      // Assert
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500)); // At least 500ms delay
    });

    test('should return consistent data across multiple calls', () async {
      // Act
      final result1 = await repository.getRestaurants();
      final result2 = await repository.getRestaurants();

      // Assert
      expect(result1.isSuccess, true);
      expect(result2.isSuccess, true);
      
      final restaurants1 = result1.getOrElse(() => []);
      final restaurants2 = result2.getOrElse(() => []);
      
      expect(restaurants1.length, restaurants2.length);
      expect(restaurants1.first.id, restaurants2.first.id);
    });
  });
}