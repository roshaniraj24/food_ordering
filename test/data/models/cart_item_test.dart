import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_app/data/models/models.dart';

void main() {
  group('CartItem Model Tests', () {
    final testMenuItem = MenuItem(
      id: '1',
      name: 'Test Pizza',
      description: 'Delicious test pizza',
      price: 15.99,
      imageUrl: 'https://test.com/pizza.jpg',
      category: 'Pizza',
      isVegetarian: true,
      isVegan: false,
      isSpicy: false,
      allergens: const ['Gluten', 'Dairy'],
      preparationTime: 20,
      isAvailable: true,
    );

    test('should create a CartItem instance with correct properties', () {
      // Arrange
      final cartItem = CartItem(
        id: 'cart-1',
        menuItem: testMenuItem,
        quantity: 2,
        customizations: const {
          'size': ['Large'],
          'toppings': ['Extra Cheese', 'Pepperoni'],
        },
        specialInstructions: 'No onions please',
      );

      // Assert
      expect(cartItem.id, 'cart-1');
      expect(cartItem.menuItem, testMenuItem);
      expect(cartItem.quantity, 2);
      expect(cartItem.customizations['size'], ['Large']);
      expect(cartItem.customizations['toppings'], ['Extra Cheese', 'Pepperoni']);
      expect(cartItem.specialInstructions, 'No onions please');
    });

    test('should calculate total price correctly with quantity', () {
      // Arrange
      final cartItem = CartItem(
        id: 'cart-1',
        menuItem: testMenuItem,
        quantity: 3,
      );

      // Act & Assert
      expect(cartItem.totalPrice, 47.97); // 15.99 * 3
    });

    test('should calculate total price with discounted menu item', () {
      // Arrange
      final discountedMenuItem = testMenuItem.copyWith(
        price: 20.0,
        discountPercentage: 25.0, // 25% discount, final price = 15.0
      );

      final cartItem = CartItem(
        id: 'cart-1',
        menuItem: discountedMenuItem,
        quantity: 2,
      );

      // Act & Assert
      expect(cartItem.totalPrice, 30.0); // 15.0 * 2
    });

    test('should support copyWith functionality', () {
      // Arrange
      final cartItem = CartItem(
        id: 'cart-1',
        menuItem: testMenuItem,
        quantity: 2,
        customizations: const {
          'size': ['Medium'],
        },
        specialInstructions: 'No onions',
      );

      // Act
      final updatedCartItem = cartItem.copyWith(
        quantity: 3,
        specialInstructions: 'Extra spicy',
      );

      // Assert
      expect(updatedCartItem.id, 'cart-1'); // unchanged
      expect(updatedCartItem.menuItem, testMenuItem); // unchanged
      expect(updatedCartItem.quantity, 3); // changed
      expect(updatedCartItem.customizations['size'], ['Medium']); // unchanged
      expect(updatedCartItem.specialInstructions, 'Extra spicy'); // changed
    });

    test('should support equality comparison', () {
      // Arrange
      final cartItem1 = CartItem(
        id: 'cart-1',
        menuItem: testMenuItem,
        quantity: 2,
        customizations: const {
          'size': ['Large'],
          'toppings': ['Extra Cheese'],
        },
      );

      final cartItem2 = CartItem(
        id: 'cart-1',
        menuItem: testMenuItem,
        quantity: 2,
        customizations: const {
          'size': ['Large'],
          'toppings': ['Extra Cheese'],
        },
      );

      final cartItem3 = CartItem(
        id: 'cart-2',
        menuItem: testMenuItem,
        quantity: 1,
        customizations: const {
          'size': ['Medium'],
        },
      );

      // Assert
      expect(cartItem1, equals(cartItem2));
      expect(cartItem1, isNot(equals(cartItem3)));
    });

    test('should handle empty customizations', () {
      // Arrange
      final cartItem = CartItem(
        id: 'cart-1',
        menuItem: testMenuItem,
        quantity: 1,
        customizations: const {},
      );

      // Assert
      expect(cartItem.customizations, isEmpty);
      expect(cartItem.totalPrice, testMenuItem.finalPrice);
    });

    test('should handle null special instructions', () {
      // Arrange
      final cartItem = CartItem(
        id: 'cart-1',
        menuItem: testMenuItem,
        quantity: 1,
      );

      // Assert
      expect(cartItem.specialInstructions, isNull);
    });

    test('should maintain quantity precision', () {
      // Arrange
      final cartItem = CartItem(
        id: 'cart-1',
        menuItem: testMenuItem,
        quantity: 5,
      );

      // Act & Assert
      expect(cartItem.totalPrice, 79.95); // 15.99 * 5
    });

    test('should handle complex customizations structure', () {
      // Arrange
      final cartItem = CartItem(
        id: 'cart-1',
        menuItem: testMenuItem,
        quantity: 1,
        customizations: const {
          'size': ['Large'],
          'toppings': ['Pepperoni', 'Mushrooms', 'Extra Cheese'],
          'crust': ['Thin'],
          'cooking': ['Well Done'],
        },
      );

      // Assert
      expect(cartItem.customizations.keys.length, 4);
      expect(cartItem.customizations['toppings']?.length, 3);
      expect(cartItem.customizations['size']?.first, 'Large');
    });
  });
}