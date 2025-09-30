import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class CreateOrder extends OrderEvent {
  final Restaurant restaurant;
  final List<CartItem> items;
  final PaymentMethod paymentMethod;
  final String deliveryAddress;
  final String? specialInstructions;

  const CreateOrder({
    required this.restaurant,
    required this.items,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
        restaurant,
        items,
        paymentMethod,
        deliveryAddress,
        specialInstructions,
      ];
}

class LoadOrder extends OrderEvent {
  final String orderId;

  const LoadOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class LoadUserOrders extends OrderEvent {
  const LoadUserOrders();
}

class CancelOrder extends OrderEvent {
  final String orderId;

  const CancelOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RefreshOrder extends OrderEvent {
  final String orderId;

  const RefreshOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}