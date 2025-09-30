import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'cart_item.dart';
import 'restaurant.dart';

part 'order.g.dart';

enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('preparing')
  preparing,
  @JsonValue('ready')
  ready,
  @JsonValue('out_for_delivery')
  outForDelivery,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
}

enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('card')
  card,
  @JsonValue('upi')
  upi,
  @JsonValue('wallet')
  wallet,
}

@JsonSerializable()
class Order extends Equatable {
  final String id;
  final Restaurant restaurant;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String deliveryAddress;
  final String? specialInstructions;
  final DateTime orderTime;
  final DateTime? estimatedDeliveryTime;
  final String? trackingId;

  const Order({
    required this.id,
    required this.restaurant,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.specialInstructions,
    required this.orderTime,
    this.estimatedDeliveryTime,
    this.trackingId,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        id,
        restaurant,
        items,
        subtotal,
        deliveryFee,
        tax,
        total,
        status,
        paymentMethod,
        deliveryAddress,
        specialInstructions,
        orderTime,
        estimatedDeliveryTime,
        trackingId,
      ];

  Order copyWith({
    String? id,
    Restaurant? restaurant,
    List<CartItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    double? total,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    String? deliveryAddress,
    String? specialInstructions,
    DateTime? orderTime,
    DateTime? estimatedDeliveryTime,
    String? trackingId,
  }) {
    return Order(
      id: id ?? this.id,
      restaurant: restaurant ?? this.restaurant,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      orderTime: orderTime ?? this.orderTime,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      trackingId: trackingId ?? this.trackingId,
    );
  }
}