import '../models/models.dart';
import '../../core/result.dart';

abstract class OrderRepository {
  Future<Result<Order>> createOrder(Order order);
  
  Future<Result<Order>> getOrderById(String orderId);
  
  Future<Result<List<Order>>> getUserOrders();
  
  Future<Result<Order>> updateOrderStatus(String orderId, OrderStatus status);
  
  Future<Result<void>> cancelOrder(String orderId);
}