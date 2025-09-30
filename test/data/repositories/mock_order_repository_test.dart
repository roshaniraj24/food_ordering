import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_app/data/models/models.dart';
import 'package:food_order_app/data/repositories/mock_order_repository.dart';

void main() {
  group('MockOrderRepository Tests', () {
    late MockOrderRepository repository;
    late Restaurant testRestaurant;
    late List<CartItem> testCartItems;

    setUp(() {
      repository = MockOrderRepository();
      
      testRestaurant = Restaurant(
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

      testCartItems = [
        CartItem(
          id: 'cart-1',
          menuItem: testMenuItem,
          quantity: 2,
        ),
      ];
    });

    test('should create order successfully', () async {
      // Arrange
      const deliveryAddress = DeliveryAddress(
        street: '456 Customer St',
        city: 'Test City',
        state: 'TS',
        zipCode: '12345',
        instructions: 'Ring doorbell',
      );

      const paymentMethod = PaymentMethod(
        type: 'credit_card',
        last4: '1234',
        brand: 'Visa',
      );

      // Act
      final result = await repository.createOrder(
        restaurant: testRestaurant,
        items: testCartItems,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      // Assert
      expect(result.isSuccess, true);
      final order = result.getOrElse(() => throw Exception('Failed'));
      expect(order.id, isNotEmpty);
      expect(order.restaurant, testRestaurant);
      expect(order.items, testCartItems);
      expect(order.status, OrderStatus.pending);
      expect(order.deliveryAddress, deliveryAddress);
      expect(order.paymentMethod, paymentMethod);
      expect(order.subtotal, greaterThan(0));
      expect(order.total, greaterThan(order.subtotal));
      expect(order.createdAt, isNotNull);
      expect(order.estimatedDeliveryTime, isNotNull);
      expect(order.trackingUpdates, isNotEmpty);
    });

    test('should calculate order totals correctly', () async {
      // Arrange
      const deliveryAddress = DeliveryAddress(
        street: '456 Customer St',
        city: 'Test City',
        state: 'TS',
        zipCode: '12345',
      );

      const paymentMethod = PaymentMethod(
        type: 'credit_card',
        last4: '1234',
      );

      // Act
      final result = await repository.createOrder(
        restaurant: testRestaurant,
        items: testCartItems,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      // Assert
      expect(result.isSuccess, true);
      final order = result.getOrElse(() => throw Exception('Failed'));
      
      // Calculate expected subtotal (15.99 * 2 = 31.98)
      final expectedSubtotal = testCartItems.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );
      
      expect(order.subtotal, expectedSubtotal);
      expect(order.deliveryFee, testRestaurant.deliveryFee);
      expect(order.tax, greaterThan(0));
      expect(order.total, order.subtotal + order.deliveryFee + order.tax);
    });

    test('should retrieve order by id when it exists', () async {
      // Arrange - First create an order
      const deliveryAddress = DeliveryAddress(
        street: '456 Customer St',
        city: 'Test City',
        state: 'TS',
        zipCode: '12345',
      );

      const paymentMethod = PaymentMethod(
        type: 'credit_card',
        last4: '1234',
      );

      final createResult = await repository.createOrder(
        restaurant: testRestaurant,
        items: testCartItems,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      final createdOrder = createResult.getOrElse(() => throw Exception('Failed'));

      // Act
      final result = await repository.getOrder(createdOrder.id);

      // Assert
      expect(result.isSuccess, true);
      final retrievedOrder = result.getOrElse(() => throw Exception('Failed'));
      expect(retrievedOrder.id, createdOrder.id);
      expect(retrievedOrder.restaurant.id, testRestaurant.id);
      expect(retrievedOrder.items.length, testCartItems.length);
    });

    test('should return failure for non-existent order id', () async {
      // Act
      final result = await repository.getOrder('non-existent-order-id');

      // Assert
      expect(result.isFailure, true);
      result.fold(
        (failure) => expect(failure.message, contains('not found')),
        (order) => fail('Expected failure but got success'),
      );
    });

    test('should return user orders', () async {
      // Arrange - Create multiple orders
      const deliveryAddress = DeliveryAddress(
        street: '456 Customer St',
        city: 'Test City',
        state: 'TS',
        zipCode: '12345',
      );

      const paymentMethod = PaymentMethod(
        type: 'credit_card',
        last4: '1234',
      );

      // Create first order
      await repository.createOrder(
        restaurant: testRestaurant,
        items: testCartItems,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      // Create second order
      await repository.createOrder(
        restaurant: testRestaurant,
        items: testCartItems,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      // Act
      final result = await repository.getUserOrders('user-123');

      // Assert
      expect(result.isSuccess, true);
      final orders = result.getOrElse(() => []);
      expect(orders.length, greaterThanOrEqualTo(2));
      
      // Verify orders are sorted by creation date (most recent first)
      for (int i = 0; i < orders.length - 1; i++) {
        expect(
          orders[i].createdAt.isAfter(orders[i + 1].createdAt) ||
          orders[i].createdAt.isAtSameMomentAs(orders[i + 1].createdAt),
          true,
        );
      }
    });

    test('should update order status successfully', () async {
      // Arrange - Create an order first
      const deliveryAddress = DeliveryAddress(
        street: '456 Customer St',
        city: 'Test City',
        state: 'TS',
        zipCode: '12345',
      );

      const paymentMethod = PaymentMethod(
        type: 'credit_card',
        last4: '1234',
      );

      final createResult = await repository.createOrder(
        restaurant: testRestaurant,
        items: testCartItems,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      final createdOrder = createResult.getOrElse(() => throw Exception('Failed'));

      // Act
      final result = await repository.updateOrderStatus(
        createdOrder.id,
        OrderStatus.confirmed,
      );

      // Assert
      expect(result.isSuccess, true);
      final updatedOrder = result.getOrElse(() => throw Exception('Failed'));
      expect(updatedOrder.status, OrderStatus.confirmed);
      expect(updatedOrder.trackingUpdates.length, greaterThan(1));
      
      // Verify the latest tracking update
      final latestUpdate = updatedOrder.trackingUpdates.last;
      expect(latestUpdate.status, OrderStatus.confirmed);
      expect(latestUpdate.message, isNotEmpty);
    });

    test('should return failure when updating non-existent order', () async {
      // Act
      final result = await repository.updateOrderStatus(
        'non-existent-order-id',
        OrderStatus.confirmed,
      );

      // Assert
      expect(result.isFailure, true);
      result.fold(
        (failure) => expect(failure.message, contains('not found')),
        (order) => fail('Expected failure but got success'),
      );
    });

    test('should cancel order successfully', () async {
      // Arrange - Create an order first
      const deliveryAddress = DeliveryAddress(
        street: '456 Customer St',
        city: 'Test City',
        state: 'TS',
        zipCode: '12345',
      );

      const paymentMethod = PaymentMethod(
        type: 'credit_card',
        last4: '1234',
      );

      final createResult = await repository.createOrder(
        restaurant: testRestaurant,
        items: testCartItems,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      final createdOrder = createResult.getOrElse(() => throw Exception('Failed'));

      // Act
      final result = await repository.cancelOrder(createdOrder.id);

      // Assert
      expect(result.isSuccess, true);
      final cancelledOrder = result.getOrElse(() => throw Exception('Failed'));
      expect(cancelledOrder.status, OrderStatus.cancelled);
      
      // Verify cancellation tracking update
      final latestUpdate = cancelledOrder.trackingUpdates.last;
      expect(latestUpdate.status, OrderStatus.cancelled);
      expect(latestUpdate.message, contains('cancelled'));
    });

    test('should return failure when cancelling non-existent order', () async {
      // Act
      final result = await repository.cancelOrder('non-existent-order-id');

      // Assert
      expect(result.isFailure, true);
      result.fold(
        (failure) => expect(failure.message, contains('not found')),
        (order) => fail('Expected failure but got success'),
      );
    });

    test('should simulate network delay for all operations', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();
      
      const deliveryAddress = DeliveryAddress(
        street: '456 Customer St',
        city: 'Test City',
        state: 'TS',
        zipCode: '12345',
      );

      const paymentMethod = PaymentMethod(
        type: 'credit_card',
        last4: '1234',
      );

      // Act
      await repository.createOrder(
        restaurant: testRestaurant,
        items: testCartItems,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      // Assert
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(800)); // At least 800ms delay
    });

    test('should handle edge case with empty cart items', () async {
      // Arrange
      const deliveryAddress = DeliveryAddress(
        street: '456 Customer St',
        city: 'Test City',
        state: 'TS',
        zipCode: '12345',
      );

      const paymentMethod = PaymentMethod(
        type: 'credit_card',
        last4: '1234',
      );

      // Act
      final result = await repository.createOrder(
        restaurant: testRestaurant,
        items: [], // Empty cart
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      // Assert
      expect(result.isSuccess, true);
      final order = result.getOrElse(() => throw Exception('Failed'));
      expect(order.items, isEmpty);
      expect(order.subtotal, 0.0);
      expect(order.total, order.deliveryFee + order.tax);
    });
  });
}