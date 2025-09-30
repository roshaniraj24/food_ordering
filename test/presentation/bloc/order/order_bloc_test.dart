import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:food_order_app/core/failures.dart';
import 'package:food_order_app/data/models/models.dart';
import 'package:food_order_app/data/repositories/order_repository.dart';
import 'package:food_order_app/presentation/bloc/order/order_bloc.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('OrderBloc Tests', () {
    late OrderBloc orderBloc;
    late MockOrderRepository mockRepository;

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

    final testOrder = Order(
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

    const testDeliveryAddress = DeliveryAddress(
      street: '456 Customer St',
      city: 'Test City',
      state: 'TS',
      zipCode: '12345',
      instructions: 'Ring doorbell',
    );

    const testPaymentMethod = PaymentMethod(
      type: 'credit_card',
      last4: '1234',
      brand: 'Visa',
    );

    setUp(() {
      mockRepository = MockOrderRepository();
      orderBloc = OrderBloc(orderRepository: mockRepository);
    });

    tearDown(() {
      orderBloc.close();
    });

    test('initial state is OrderInitial', () {
      expect(orderBloc.state, const OrderInitial());
    });

    group('CreateOrder', () {
      blocTest<OrderBloc, OrderState>(
        'emits [OrderLoading, OrderCreated] when CreateOrder succeeds',
        build: () {
          when(() => mockRepository.createOrder(
                restaurant: testRestaurant,
                items: [testCartItem],
                deliveryAddress: testDeliveryAddress,
                paymentMethod: testPaymentMethod,
              )).thenAnswer((_) async => Right(testOrder));
          return orderBloc;
        },
        act: (bloc) => bloc.add(CreateOrder(
          restaurant: testRestaurant,
          items: [testCartItem],
          deliveryAddress: testDeliveryAddress,
          paymentMethod: testPaymentMethod,
        )),
        expect: () => [
          const OrderLoading(),
          OrderCreated(order: testOrder),
        ],
        verify: (_) {
          verify(() => mockRepository.createOrder(
                restaurant: testRestaurant,
                items: [testCartItem],
                deliveryAddress: testDeliveryAddress,
                paymentMethod: testPaymentMethod,
              )).called(1);
        },
      );

      blocTest<OrderBloc, OrderState>(
        'emits [OrderLoading, OrderError] when CreateOrder fails',
        build: () {
          when(() => mockRepository.createOrder(
                restaurant: testRestaurant,
                items: [testCartItem],
                deliveryAddress: testDeliveryAddress,
                paymentMethod: testPaymentMethod,
              )).thenAnswer((_) async => const Left(ServerFailure('Payment failed')));
          return orderBloc;
        },
        act: (bloc) => bloc.add(CreateOrder(
          restaurant: testRestaurant,
          items: [testCartItem],
          deliveryAddress: testDeliveryAddress,
          paymentMethod: testPaymentMethod,
        )),
        expect: () => [
          const OrderLoading(),
          const OrderError(message: 'Payment failed'),
        ],
        verify: (_) {
          verify(() => mockRepository.createOrder(
                restaurant: testRestaurant,
                items: [testCartItem],
                deliveryAddress: testDeliveryAddress,
                paymentMethod: testPaymentMethod,
              )).called(1);
        },
      );
    });

    group('LoadOrder', () {
      blocTest<OrderBloc, OrderState>(
        'emits [OrderLoading, OrderLoaded] when LoadOrder succeeds',
        build: () {
          when(() => mockRepository.getOrder('order-1'))
              .thenAnswer((_) async => Right(testOrder));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const LoadOrder(orderId: 'order-1')),
        expect: () => [
          const OrderLoading(),
          OrderLoaded(order: testOrder),
        ],
        verify: (_) {
          verify(() => mockRepository.getOrder('order-1')).called(1);
        },
      );

      blocTest<OrderBloc, OrderState>(
        'emits [OrderLoading, OrderError] when LoadOrder fails',
        build: () {
          when(() => mockRepository.getOrder('order-1'))
              .thenAnswer((_) async => const Left(NotFoundFailure('Order not found')));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const LoadOrder(orderId: 'order-1')),
        expect: () => [
          const OrderLoading(),
          const OrderError(message: 'Order not found'),
        ],
        verify: (_) {
          verify(() => mockRepository.getOrder('order-1')).called(1);
        },
      );
    });

    group('LoadUserOrders', () {
      final userOrders = [
        testOrder,
        testOrder.copyWith(
          id: 'order-2',
          status: OrderStatus.delivered,
          createdAt: DateTime(2024, 1, 2, 12, 0),
        ),
      ];

      blocTest<OrderBloc, OrderState>(
        'emits [OrderLoading, UserOrdersLoaded] when LoadUserOrders succeeds',
        build: () {
          when(() => mockRepository.getUserOrders('user-123'))
              .thenAnswer((_) async => Right(userOrders));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const LoadUserOrders(userId: 'user-123')),
        expect: () => [
          const OrderLoading(),
          UserOrdersLoaded(orders: userOrders),
        ],
        verify: (_) {
          verify(() => mockRepository.getUserOrders('user-123')).called(1);
        },
      );

      blocTest<OrderBloc, OrderState>(
        'emits [OrderLoading, OrderError] when LoadUserOrders fails',
        build: () {
          when(() => mockRepository.getUserOrders('user-123'))
              .thenAnswer((_) async => const Left(NetworkFailure('Network error')));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const LoadUserOrders(userId: 'user-123')),
        expect: () => [
          const OrderLoading(),
          const OrderError(message: 'Network error'),
        ],
        verify: (_) {
          verify(() => mockRepository.getUserOrders('user-123')).called(1);
        },
      );
    });

    group('UpdateOrderStatus', () {
      final updatedOrder = testOrder.copyWith(
        status: OrderStatus.confirmed,
        trackingUpdates: [
          ...testOrder.trackingUpdates,
          const TrackingUpdate(
            status: OrderStatus.confirmed,
            message: 'Order confirmed by restaurant',
            timestamp: '2024-01-01T12:05:00Z',
          ),
        ],
      );

      blocTest<OrderBloc, OrderState>(
        'emits [OrderLoading, OrderLoaded] when UpdateOrderStatus succeeds',
        build: () {
          when(() => mockRepository.updateOrderStatus('order-1', OrderStatus.confirmed))
              .thenAnswer((_) async => Right(updatedOrder));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const UpdateOrderStatus(
          orderId: 'order-1',
          status: OrderStatus.confirmed,
        )),
        expect: () => [
          const OrderLoading(),
          OrderLoaded(order: updatedOrder),
        ],
        verify: (_) {
          verify(() => mockRepository.updateOrderStatus('order-1', OrderStatus.confirmed)).called(1);
        },
      );

      blocTest<OrderBloc, OrderState>(
        'emits [OrderLoading, OrderError] when UpdateOrderStatus fails',
        build: () {
          when(() => mockRepository.updateOrderStatus('order-1', OrderStatus.confirmed))
              .thenAnswer((_) async => const Left(ServerFailure('Update failed')));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const UpdateOrderStatus(
          orderId: 'order-1',
          status: OrderStatus.confirmed,
        )),
        expect: () => [
          const OrderLoading(),
          const OrderError(message: 'Update failed'),
        ],
        verify: (_) {
          verify(() => mockRepository.updateOrderStatus('order-1', OrderStatus.confirmed)).called(1);
        },
      );
    });

    group('CancelOrder', () {
      final cancelledOrder = testOrder.copyWith(
        status: OrderStatus.cancelled,
        trackingUpdates: [
          ...testOrder.trackingUpdates,
          const TrackingUpdate(
            status: OrderStatus.cancelled,
            message: 'Order cancelled by customer',
            timestamp: '2024-01-01T12:10:00Z',
          ),
        ],
      );

      blocTest<OrderBloc, OrderState>(
        'emits [OrderLoading, OrderLoaded] when CancelOrder succeeds',
        build: () {
          when(() => mockRepository.cancelOrder('order-1'))
              .thenAnswer((_) async => Right(cancelledOrder));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const CancelOrder(orderId: 'order-1')),
        expect: () => [
          const OrderLoading(),
          OrderLoaded(order: cancelledOrder),
        ],
        verify: (_) {
          verify(() => mockRepository.cancelOrder('order-1')).called(1);
        },
      );

      blocTest<OrderBloc, OrderState>(
        'emits [OrderLoading, OrderError] when CancelOrder fails',
        build: () {
          when(() => mockRepository.cancelOrder('order-1'))
              .thenAnswer((_) async => const Left(ServerFailure('Cannot cancel order')));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const CancelOrder(orderId: 'order-1')),
        expect: () => [
          const OrderLoading(),
          const OrderError(message: 'Cannot cancel order'),
        ],
        verify: (_) {
          verify(() => mockRepository.cancelOrder('order-1')).called(1);
        },
      );
    });

    group('TrackOrder', () {
      blocTest<OrderBloc, OrderState>(
        'periodically updates order status when tracking',
        build: () {
          when(() => mockRepository.getOrder('order-1'))
              .thenAnswer((_) async => Right(testOrder));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const TrackOrder(orderId: 'order-1')),
        expect: () => [
          const OrderLoading(),
          OrderLoaded(order: testOrder),
        ],
        verify: (_) {
          verify(() => mockRepository.getOrder('order-1')).called(1);
        },
      );

      blocTest<OrderBloc, OrderState>(
        'stops tracking when order is delivered',
        build: () {
          final deliveredOrder = testOrder.copyWith(status: OrderStatus.delivered);
          when(() => mockRepository.getOrder('order-1'))
              .thenAnswer((_) async => Right(deliveredOrder));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const TrackOrder(orderId: 'order-1')),
        expect: () => [
          const OrderLoading(),
          OrderLoaded(order: deliveredOrder),
        ],
        verify: (_) {
          verify(() => mockRepository.getOrder('order-1')).called(1);
        },
      );

      blocTest<OrderBloc, OrderState>(
        'stops tracking when order is cancelled',
        build: () {
          final cancelledOrder = testOrder.copyWith(status: OrderStatus.cancelled);
          when(() => mockRepository.getOrder('order-1'))
              .thenAnswer((_) async => Right(cancelledOrder));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const TrackOrder(orderId: 'order-1')),
        expect: () => [
          const OrderLoading(),
          OrderLoaded(order: cancelledOrder),
        ],
        verify: (_) {
          verify(() => mockRepository.getOrder('order-1')).called(1);
        },
      );
    });

    group('StopTracking', () {
      blocTest<OrderBloc, OrderState>(
        'does nothing when not currently tracking',
        build: () => orderBloc,
        act: (bloc) => bloc.add(const StopTracking()),
        expect: () => [],
      );
    });

    group('Error Handling', () {
      blocTest<OrderBloc, OrderState>(
        'handles repository exceptions gracefully',
        build: () {
          when(() => mockRepository.getOrder('order-1'))
              .thenThrow(Exception('Unexpected error'));
          return orderBloc;
        },
        act: (bloc) => bloc.add(const LoadOrder(orderId: 'order-1')),
        expect: () => [
          const OrderLoading(),
          const OrderError(message: 'An unexpected error occurred'),
        ],
      );
    });

    group('State Transitions', () {
      blocTest<OrderBloc, OrderState>(
        'handles sequential order operations correctly',
        build: () {
          when(() => mockRepository.createOrder(
                restaurant: testRestaurant,
                items: [testCartItem],
                deliveryAddress: testDeliveryAddress,
                paymentMethod: testPaymentMethod,
              )).thenAnswer((_) async => Right(testOrder));
          when(() => mockRepository.getOrder('order-1'))
              .thenAnswer((_) async => Right(testOrder));
          return orderBloc;
        },
        act: (bloc) {
          bloc.add(CreateOrder(
            restaurant: testRestaurant,
            items: [testCartItem],
            deliveryAddress: testDeliveryAddress,
            paymentMethod: testPaymentMethod,
          ));
          bloc.add(const LoadOrder(orderId: 'order-1'));
        },
        expect: () => [
          const OrderLoading(),
          OrderCreated(order: testOrder),
          const OrderLoading(),
          OrderLoaded(order: testOrder),
        ],
      );
    });
  });
}