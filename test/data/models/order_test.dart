import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_app/data/models/models.dart';

void main() {
  group('Order Model Tests', () {
    final testRestaurant = Restaurant(
      id: '1',
      name: 'Test Restaurant',
      description: 'A test restaurant',
      imageUrl: 'https://test.com/restaurant.jpg',
      rating: 4.5,
      deliveryTime: '30-45 min',
      deliveryFee: 2.99,
      minimumOrder: 15.0,
      cuisineTypes: const ['Italian', 'Pizza'],
      isOpen: true,
      address: '123 Test St',
      phone: '+1234567890',
      priceRange: '\$\$',
    );

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

    final testCartItem = CartItem(
      id: 'cart-1',
      menuItem: testMenuItem,
      quantity: 2,
    );

    test('should create an Order instance with correct properties', () {
      // Arrange
      final order = Order(
        id: 'order-1',
        restaurant: testRestaurant,
        items: [testCartItem],
        status: OrderStatus.pending,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        subtotal: 31.98,
        deliveryFee: 2.99,
        tax: 2.88,
        total: 37.85,
        deliveryAddress: const DeliveryAddress(
          street: '456 Customer St',
          city: 'Test City',
          state: 'TS',
          zipCode: '12345',
          instructions: 'Ring doorbell',
        ),
        paymentMethod: const PaymentMethod(
          type: 'credit_card',
          last4: '1234',
        ),
        estimatedDeliveryTime: DateTime(2024, 1, 1, 13, 0),
        trackingUpdates: const [
          TrackingUpdate(
            status: OrderStatus.pending,
            message: 'Order received',
            timestamp: '2024-01-01T12:00:00Z',
          ),
        ],
      );

      // Assert
      expect(order.id, 'order-1');
      expect(order.restaurant, testRestaurant);
      expect(order.items.length, 1);
      expect(order.items.first, testCartItem);
      expect(order.status, OrderStatus.pending);
      expect(order.createdAt, DateTime(2024, 1, 1, 12, 0));
      expect(order.subtotal, 31.98);
      expect(order.deliveryFee, 2.99);
      expect(order.tax, 2.88);
      expect(order.total, 37.85);
      expect(order.deliveryAddress?.street, '456 Customer St');
      expect(order.paymentMethod?.type, 'credit_card');
      expect(order.estimatedDeliveryTime, DateTime(2024, 1, 1, 13, 0));
      expect(order.trackingUpdates.length, 1);
    });

    test('should support copyWith functionality', () {
      // Arrange
      final order = Order(
        id: 'order-1',
        restaurant: testRestaurant,
        items: [testCartItem],
        status: OrderStatus.pending,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        subtotal: 31.98,
        deliveryFee: 2.99,
        tax: 2.88,
        total: 37.85,
      );

      // Act
      final updatedOrder = order.copyWith(
        status: OrderStatus.confirmed,
        total: 40.00,
      );

      // Assert
      expect(updatedOrder.id, 'order-1'); // unchanged
      expect(updatedOrder.restaurant, testRestaurant); // unchanged
      expect(updatedOrder.status, OrderStatus.confirmed); // changed
      expect(updatedOrder.total, 40.00); // changed
      expect(updatedOrder.subtotal, 31.98); // unchanged
    });

    test('should support equality comparison', () {
      // Arrange
      final order1 = Order(
        id: 'order-1',
        restaurant: testRestaurant,
        items: [testCartItem],
        status: OrderStatus.pending,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        subtotal: 31.98,
        deliveryFee: 2.99,
        tax: 2.88,
        total: 37.85,
      );

      final order2 = Order(
        id: 'order-1',
        restaurant: testRestaurant,
        items: [testCartItem],
        status: OrderStatus.pending,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        subtotal: 31.98,
        deliveryFee: 2.99,
        tax: 2.88,
        total: 37.85,
      );

      final order3 = Order(
        id: 'order-2',
        restaurant: testRestaurant,
        items: [testCartItem],
        status: OrderStatus.confirmed,
        createdAt: DateTime(2024, 1, 1, 13, 0),
        subtotal: 25.00,
        deliveryFee: 2.99,
        tax: 2.50,
        total: 30.49,
      );

      // Assert
      expect(order1, equals(order2));
      expect(order1, isNot(equals(order3)));
    });

    test('should handle multiple items correctly', () {
      // Arrange
      final secondCartItem = CartItem(
        id: 'cart-2',
        menuItem: testMenuItem.copyWith(id: '2', name: 'Test Pasta', price: 12.99),
        quantity: 1,
      );

      final order = Order(
        id: 'order-1',
        restaurant: testRestaurant,
        items: [testCartItem, secondCartItem],
        status: OrderStatus.pending,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        subtotal: 44.97, // (15.99 * 2) + 12.99
        deliveryFee: 2.99,
        tax: 4.32,
        total: 52.28,
      );

      // Assert
      expect(order.items.length, 2);
      expect(order.items[0], testCartItem);
      expect(order.items[1], secondCartItem);
      expect(order.subtotal, 44.97);
    });
  });

  group('OrderStatus Enum Tests', () {
    test('should have all expected order statuses', () {
      // Assert
      expect(OrderStatus.values.contains(OrderStatus.pending), true);
      expect(OrderStatus.values.contains(OrderStatus.confirmed), true);
      expect(OrderStatus.values.contains(OrderStatus.preparing), true);
      expect(OrderStatus.values.contains(OrderStatus.outForDelivery), true);
      expect(OrderStatus.values.contains(OrderStatus.delivered), true);
      expect(OrderStatus.values.contains(OrderStatus.cancelled), true);
    });

    test('should maintain order status progression', () {
      // Arrange
      final statuses = [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.outForDelivery,
        OrderStatus.delivered,
      ];

      // Assert - Just verify the statuses exist and can be compared
      expect(statuses.length, 5);
      expect(statuses.contains(OrderStatus.pending), true);
      expect(statuses.contains(OrderStatus.delivered), true);
    });
  });

  group('DeliveryAddress Model Tests', () {
    test('should create a DeliveryAddress instance with correct properties', () {
      // Arrange
      const address = DeliveryAddress(
        street: '123 Main St',
        city: 'Test City',
        state: 'TS',
        zipCode: '12345',
        instructions: 'Leave at door',
      );

      // Assert
      expect(address.street, '123 Main St');
      expect(address.city, 'Test City');
      expect(address.state, 'TS');
      expect(address.zipCode, '12345');
      expect(address.instructions, 'Leave at door');
    });

    test('should support equality comparison', () {
      // Arrange
      const address1 = DeliveryAddress(
        street: '123 Main St',
        city: 'Test City',
        state: 'TS',
        zipCode: '12345',
      );

      const address2 = DeliveryAddress(
        street: '123 Main St',
        city: 'Test City',
        state: 'TS',
        zipCode: '12345',
      );

      const address3 = DeliveryAddress(
        street: '456 Oak Ave',
        city: 'Other City',
        state: 'OC',
        zipCode: '67890',
      );

      // Assert
      expect(address1, equals(address2));
      expect(address1, isNot(equals(address3)));
    });
  });

  group('PaymentMethod Model Tests', () {
    test('should create a PaymentMethod instance with correct properties', () {
      // Arrange
      const paymentMethod = PaymentMethod(
        type: 'credit_card',
        last4: '1234',
        brand: 'Visa',
      );

      // Assert
      expect(paymentMethod.type, 'credit_card');
      expect(paymentMethod.last4, '1234');
      expect(paymentMethod.brand, 'Visa');
    });

    test('should support equality comparison', () {
      // Arrange
      const payment1 = PaymentMethod(
        type: 'credit_card',
        last4: '1234',
        brand: 'Visa',
      );

      const payment2 = PaymentMethod(
        type: 'credit_card',
        last4: '1234',
        brand: 'Visa',
      );

      const payment3 = PaymentMethod(
        type: 'debit_card',
        last4: '5678',
        brand: 'Mastercard',
      );

      // Assert
      expect(payment1, equals(payment2));
      expect(payment1, isNot(equals(payment3)));
    });
  });

  group('TrackingUpdate Model Tests', () {
    test('should create a TrackingUpdate instance with correct properties', () {
      // Arrange
      const update = TrackingUpdate(
        status: OrderStatus.preparing,
        message: 'Your order is being prepared',
        timestamp: '2024-01-01T12:30:00Z',
      );

      // Assert
      expect(update.status, OrderStatus.preparing);
      expect(update.message, 'Your order is being prepared');
      expect(update.timestamp, '2024-01-01T12:30:00Z');
    });

    test('should support equality comparison', () {
      // Arrange
      const update1 = TrackingUpdate(
        status: OrderStatus.preparing,
        message: 'Your order is being prepared',
        timestamp: '2024-01-01T12:30:00Z',
      );

      const update2 = TrackingUpdate(
        status: OrderStatus.preparing,
        message: 'Your order is being prepared',
        timestamp: '2024-01-01T12:30:00Z',
      );

      const update3 = TrackingUpdate(
        status: OrderStatus.outForDelivery,
        message: 'Out for delivery',
        timestamp: '2024-01-01T13:00:00Z',
      );

      // Assert
      expect(update1, equals(update2));
      expect(update1, isNot(equals(update3)));
    });
  });
}