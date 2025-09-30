import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../../core/result.dart';
import '../../core/failures.dart';
import 'order_repository.dart';

class MockOrderRepository implements OrderRepository {
  static const Duration _networkDelay = Duration(milliseconds: 1000);
  static final List<Order> _mockOrders = [];
  static const _uuid = Uuid();

  @override
  Future<Result<Order>> createOrder(Order order) async {
    try {
      await Future.delayed(_networkDelay);
      
      // Simulate occasional payment failure
      if (Random().nextInt(20) == 0) {
        return failure(const ServerFailure('Payment processing failed'));
      }

      // Create order with generated ID and tracking ID
      final newOrder = order.copyWith(
        id: _uuid.v4(),
        trackingId: 'TRK${Random().nextInt(999999).toString().padLeft(6, '0')}',
        orderTime: DateTime.now(),
        estimatedDeliveryTime: DateTime.now().add(Duration(minutes: order.restaurant.deliveryTime)),
        status: OrderStatus.confirmed,
      );

      _mockOrders.add(newOrder);
      
      // Simulate order status updates
      _simulateOrderStatusUpdates(newOrder.id);
      
      return success(newOrder);
    } catch (e) {
      return failure(ServerFailure('Failed to create order: $e'));
    }
  }

  @override
  Future<Result<Order>> getOrderById(String orderId) async {
    try {
      await Future.delayed(_networkDelay);
      
      final order = _mockOrders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );
      
      return success(order);
    } catch (e) {
      return failure(const NotFoundFailure('Order not found'));
    }
  }

  @override
  Future<Result<List<Order>>> getUserOrders() async {
    try {
      await Future.delayed(_networkDelay);
      
      // Return orders sorted by most recent first
      final sortedOrders = List<Order>.from(_mockOrders)
        ..sort((a, b) => b.orderTime.compareTo(a.orderTime));
      
      return success(sortedOrders);
    } catch (e) {
      return failure(ServerFailure('Failed to load orders: $e'));
    }
  }

  @override
  Future<Result<Order>> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await Future.delayed(_networkDelay);
      
      final orderIndex = _mockOrders.indexWhere((o) => o.id == orderId);
      if (orderIndex == -1) {
        return failure(const NotFoundFailure('Order not found'));
      }
      
      final updatedOrder = _mockOrders[orderIndex].copyWith(status: status);
      _mockOrders[orderIndex] = updatedOrder;
      
      return success(updatedOrder);
    } catch (e) {
      return failure(ServerFailure('Failed to update order status: $e'));
    }
  }

  @override
  Future<Result<void>> cancelOrder(String orderId) async {
    try {
      await Future.delayed(_networkDelay);
      
      final orderIndex = _mockOrders.indexWhere((o) => o.id == orderId);
      if (orderIndex == -1) {
        return failure(const NotFoundFailure('Order not found'));
      }
      
      final order = _mockOrders[orderIndex];
      
      // Check if order can be cancelled
      if (order.status == OrderStatus.delivered || 
          order.status == OrderStatus.cancelled ||
          order.status == OrderStatus.outForDelivery) {
        return failure(const ValidationFailure('Order cannot be cancelled at this stage'));
      }
      
      final cancelledOrder = order.copyWith(status: OrderStatus.cancelled);
      _mockOrders[orderIndex] = cancelledOrder;
      
      return success(null);
    } catch (e) {
      return failure(ServerFailure('Failed to cancel order: $e'));
    }
  }

  // Simulate realistic order status updates
  void _simulateOrderStatusUpdates(String orderId) {
    Future.delayed(const Duration(minutes: 2), () async {
      await updateOrderStatus(orderId, OrderStatus.preparing);
    });
    
    Future.delayed(const Duration(minutes: 15), () async {
      await updateOrderStatus(orderId, OrderStatus.ready);
    });
    
    Future.delayed(const Duration(minutes: 20), () async {
      await updateOrderStatus(orderId, OrderStatus.outForDelivery);
    });
    
    Future.delayed(const Duration(minutes: 35), () async {
      await updateOrderStatus(orderId, OrderStatus.delivered);
    });
  }
}