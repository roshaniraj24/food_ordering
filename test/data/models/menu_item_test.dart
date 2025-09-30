import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_app/data/models/models.dart';

void main() {
  group('MenuItem Model Tests', () {
    test('should create a MenuItem instance with correct properties', () {
      // Arrange
      const menuItem = MenuItem(
        id: '1',
        name: 'Test Pizza',
        description: 'Delicious test pizza',
        price: 15.99,
        imageUrl: 'https://test.com/pizza.jpg',
        category: 'Pizza',
        isVegetarian: true,
        isVegan: false,
        isSpicy: false,
        allergens: ['Gluten', 'Dairy'],
        preparationTime: 20,
        isAvailable: true,
        discountPercentage: 10.0,
      );

      // Assert
      expect(menuItem.id, '1');
      expect(menuItem.name, 'Test Pizza');
      expect(menuItem.description, 'Delicious test pizza');
      expect(menuItem.price, 15.99);
      expect(menuItem.imageUrl, 'https://test.com/pizza.jpg');
      expect(menuItem.category, 'Pizza');
      expect(menuItem.isVegetarian, true);
      expect(menuItem.isVegan, false);
      expect(menuItem.isSpicy, false);
      expect(menuItem.allergens, ['Gluten', 'Dairy']);
      expect(menuItem.preparationTime, 20);
      expect(menuItem.isAvailable, true);
      expect(menuItem.discountPercentage, 10.0);
    });

    test('should calculate final price correctly with discount', () {
      // Arrange
      const menuItem = MenuItem(
        id: '1',
        name: 'Test Pizza',
        description: 'Delicious test pizza',
        price: 20.0,
        imageUrl: 'https://test.com/pizza.jpg',
        category: 'Pizza',
        isVegetarian: true,
        isVegan: false,
        isSpicy: false,
        allergens: ['Gluten', 'Dairy'],
        preparationTime: 20,
        isAvailable: true,
        discountPercentage: 25.0, // 25% discount
      );

      // Act & Assert
      expect(menuItem.finalPrice, 15.0); // 20.0 - (20.0 * 0.25)
    });

    test('should return original price when no discount', () {
      // Arrange
      const menuItem = MenuItem(
        id: '1',
        name: 'Test Pizza',
        description: 'Delicious test pizza',
        price: 20.0,
        imageUrl: 'https://test.com/pizza.jpg',
        category: 'Pizza',
        isVegetarian: true,
        isVegan: false,
        isSpicy: false,
        allergens: ['Gluten', 'Dairy'],
        preparationTime: 20,
        isAvailable: true,
      );

      // Act & Assert
      expect(menuItem.finalPrice, 20.0);
    });

    test('should support copyWith functionality', () {
      // Arrange
      const menuItem = MenuItem(
        id: '1',
        name: 'Test Pizza',
        description: 'Delicious test pizza',
        price: 15.99,
        imageUrl: 'https://test.com/pizza.jpg',
        category: 'Pizza',
        isVegetarian: true,
        isVegan: false,
        isSpicy: false,
        allergens: ['Gluten', 'Dairy'],
        preparationTime: 20,
        isAvailable: true,
      );

      // Act
      final updatedMenuItem = menuItem.copyWith(
        name: 'Updated Pizza',
        price: 18.99,
        isVegan: true,
      );

      // Assert
      expect(updatedMenuItem.id, '1'); // unchanged
      expect(updatedMenuItem.name, 'Updated Pizza'); // changed
      expect(updatedMenuItem.price, 18.99); // changed
      expect(updatedMenuItem.isVegan, true); // changed
      expect(updatedMenuItem.description, 'Delicious test pizza'); // unchanged
    });

    test('should support equality comparison', () {
      // Arrange
      const menuItem1 = MenuItem(
        id: '1',
        name: 'Test Pizza',
        description: 'Delicious test pizza',
        price: 15.99,
        imageUrl: 'https://test.com/pizza.jpg',
        category: 'Pizza',
        isVegetarian: true,
        isVegan: false,
        isSpicy: false,
        allergens: ['Gluten', 'Dairy'],
        preparationTime: 20,
        isAvailable: true,
      );

      const menuItem2 = MenuItem(
        id: '1',
        name: 'Test Pizza',
        description: 'Delicious test pizza',
        price: 15.99,
        imageUrl: 'https://test.com/pizza.jpg',
        category: 'Pizza',
        isVegetarian: true,
        isVegan: false,
        isSpicy: false,
        allergens: ['Gluten', 'Dairy'],
        preparationTime: 20,
        isAvailable: true,
      );

      const menuItem3 = MenuItem(
        id: '2',
        name: 'Different Pizza',
        description: 'Different pizza',
        price: 12.99,
        imageUrl: 'https://test.com/pizza2.jpg',
        category: 'Pizza',
        isVegetarian: false,
        isVegan: false,
        isSpicy: true,
        allergens: ['Gluten'],
        preparationTime: 15,
        isAvailable: false,
      );

      // Assert
      expect(menuItem1, equals(menuItem2));
      expect(menuItem1, isNot(equals(menuItem3)));
    });
  });

  group('MenuItemCustomization Model Tests', () {
    test('should create a MenuItemCustomization instance with correct properties', () {
      // Arrange
      const customization = MenuItemCustomization(
        id: 'size',
        name: 'Size',
        type: 'radio',
        isRequired: true,
        options: [
          CustomizationOption(id: 'small', name: 'Small', additionalPrice: 0),
          CustomizationOption(id: 'large', name: 'Large', additionalPrice: 3.0),
        ],
      );

      // Assert
      expect(customization.id, 'size');
      expect(customization.name, 'Size');
      expect(customization.type, 'radio');
      expect(customization.isRequired, true);
      expect(customization.options.length, 2);
    });

    test('should support equality comparison', () {
      // Arrange
      const customization1 = MenuItemCustomization(
        id: 'size',
        name: 'Size',
        type: 'radio',
        isRequired: true,
        options: [
          CustomizationOption(id: 'small', name: 'Small', additionalPrice: 0),
        ],
      );

      const customization2 = MenuItemCustomization(
        id: 'size',
        name: 'Size',
        type: 'radio',
        isRequired: true,
        options: [
          CustomizationOption(id: 'small', name: 'Small', additionalPrice: 0),
        ],
      );

      // Assert
      expect(customization1, equals(customization2));
    });
  });

  group('CustomizationOption Model Tests', () {
    test('should create a CustomizationOption instance with correct properties', () {
      // Arrange
      const option = CustomizationOption(
        id: 'large',
        name: 'Large',
        additionalPrice: 3.0,
        isDefault: true,
      );

      // Assert
      expect(option.id, 'large');
      expect(option.name, 'Large');
      expect(option.additionalPrice, 3.0);
      expect(option.isDefault, true);
    });

    test('should have default value for isDefault', () {
      // Arrange
      const option = CustomizationOption(
        id: 'small',
        name: 'Small',
        additionalPrice: 0,
      );

      // Assert
      expect(option.isDefault, false);
    });

    test('should support equality comparison', () {
      // Arrange
      const option1 = CustomizationOption(
        id: 'large',
        name: 'Large',
        additionalPrice: 3.0,
        isDefault: true,
      );

      const option2 = CustomizationOption(
        id: 'large',
        name: 'Large',
        additionalPrice: 3.0,
        isDefault: true,
      );

      const option3 = CustomizationOption(
        id: 'small',
        name: 'Small',
        additionalPrice: 0,
        isDefault: false,
      );

      // Assert
      expect(option1, equals(option2));
      expect(option1, isNot(equals(option3)));
    });
  });
}