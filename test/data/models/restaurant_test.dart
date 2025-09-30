import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_app/data/models/models.dart';

void main() {
  group('Restaurant Model Tests', () {
    test('should create a Restaurant instance with correct properties', () {
      // Arrange
      const restaurant = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        description: 'Test Description',
        imageUrl: 'https://test.com/image.jpg',
        rating: 4.5,
        reviewCount: 100,
        category: 'Italian',
        deliveryTime: 30,
        deliveryFee: 2.99,
        minimumOrder: 15.0,
        isOpen: true,
        tags: ['Pizza', 'Pasta'],
      );

      // Assert
      expect(restaurant.id, '1');
      expect(restaurant.name, 'Test Restaurant');
      expect(restaurant.description, 'Test Description');
      expect(restaurant.imageUrl, 'https://test.com/image.jpg');
      expect(restaurant.rating, 4.5);
      expect(restaurant.reviewCount, 100);
      expect(restaurant.category, 'Italian');
      expect(restaurant.deliveryTime, 30);
      expect(restaurant.deliveryFee, 2.99);
      expect(restaurant.minimumOrder, 15.0);
      expect(restaurant.isOpen, true);
      expect(restaurant.tags, ['Pizza', 'Pasta']);
    });

    test('should support copyWith functionality', () {
      // Arrange
      const restaurant = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        description: 'Test Description',
        imageUrl: 'https://test.com/image.jpg',
        rating: 4.5,
        reviewCount: 100,
        category: 'Italian',
        deliveryTime: 30,
        deliveryFee: 2.99,
        minimumOrder: 15.0,
        isOpen: true,
        tags: ['Pizza', 'Pasta'],
      );

      // Act
      final updatedRestaurant = restaurant.copyWith(
        name: 'Updated Restaurant',
        rating: 4.8,
        isOpen: false,
      );

      // Assert
      expect(updatedRestaurant.id, '1'); // unchanged
      expect(updatedRestaurant.name, 'Updated Restaurant'); // changed
      expect(updatedRestaurant.rating, 4.8); // changed
      expect(updatedRestaurant.isOpen, false); // changed
      expect(updatedRestaurant.description, 'Test Description'); // unchanged
    });

    test('should support equality comparison', () {
      // Arrange
      const restaurant1 = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        description: 'Test Description',
        imageUrl: 'https://test.com/image.jpg',
        rating: 4.5,
        reviewCount: 100,
        category: 'Italian',
        deliveryTime: 30,
        deliveryFee: 2.99,
        minimumOrder: 15.0,
        isOpen: true,
        tags: ['Pizza', 'Pasta'],
      );

      const restaurant2 = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        description: 'Test Description',
        imageUrl: 'https://test.com/image.jpg',
        rating: 4.5,
        reviewCount: 100,
        category: 'Italian',
        deliveryTime: 30,
        deliveryFee: 2.99,
        minimumOrder: 15.0,
        isOpen: true,
        tags: ['Pizza', 'Pasta'],
      );

      const restaurant3 = Restaurant(
        id: '2',
        name: 'Different Restaurant',
        description: 'Different Description',
        imageUrl: 'https://test.com/image2.jpg',
        rating: 4.0,
        reviewCount: 50,
        category: 'Chinese',
        deliveryTime: 25,
        deliveryFee: 1.99,
        minimumOrder: 12.0,
        isOpen: false,
        tags: ['Noodles', 'Rice'],
      );

      // Assert
      expect(restaurant1, equals(restaurant2));
      expect(restaurant1, isNot(equals(restaurant3)));
    });

    test('should convert to and from JSON correctly', () {
      // Arrange
      const restaurant = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        description: 'Test Description',
        imageUrl: 'https://test.com/image.jpg',
        rating: 4.5,
        reviewCount: 100,
        category: 'Italian',
        deliveryTime: 30,
        deliveryFee: 2.99,
        minimumOrder: 15.0,
        isOpen: true,
        tags: ['Pizza', 'Pasta'],
      );

      // Act
      final json = restaurant.toJson();
      final restaurantFromJson = Restaurant.fromJson(json);

      // Assert
      expect(restaurantFromJson, equals(restaurant));
      expect(json['id'], '1');
      expect(json['name'], 'Test Restaurant');
      expect(json['rating'], 4.5);
      expect(json['isOpen'], true);
      expect(json['tags'], ['Pizza', 'Pasta']);
    });
  });
}