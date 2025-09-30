import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final Restaurant? restaurant;

  const CartState({
    this.items = const [],
    this.restaurant,
  });

  @override
  List<Object?> get props => [items, restaurant];

  CartState copyWith({
    List<CartItem>? items,
    Restaurant? restaurant,
  }) {
    return CartState(
      items: items ?? this.items,
      restaurant: restaurant ?? this.restaurant,
    );
  }

  // Calculated properties
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get deliveryFee {
    return restaurant?.deliveryFee ?? 0.0;
  }

  double get tax {
    return subtotal * 0.08; // 8% tax
  }

  double get total {
    return subtotal + deliveryFee + tax;
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  bool get meetsMinimumOrder {
    if (restaurant == null) return true;
    return subtotal >= restaurant!.minimumOrder;
  }

  double get remainingForMinimumOrder {
    if (restaurant == null) return 0.0;
    final remaining = restaurant!.minimumOrder - subtotal;
    return remaining > 0 ? remaining : 0.0;
  }

  // Helper methods
  CartItem? getItemById(String itemId) {
    try {
      return items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  bool hasItem(String menuItemId) {
    return items.any((item) => item.menuItem.id == menuItemId);
  }

  int getItemQuantity(String menuItemId) {
    return items
        .where((item) => item.menuItem.id == menuItemId)
        .fold(0, (sum, item) => sum + item.quantity);
  }
}