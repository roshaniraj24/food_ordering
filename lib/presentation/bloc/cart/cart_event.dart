import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final MenuItem menuItem;
  final int quantity;
  final Map<String, List<String>> selectedCustomizations;
  final String? specialInstructions;

  const AddToCart({
    required this.menuItem,
    this.quantity = 1,
    this.selectedCustomizations = const {},
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
        menuItem,
        quantity,
        selectedCustomizations,
        specialInstructions,
      ];
}

class RemoveFromCart extends CartEvent {
  final String cartItemId;

  const RemoveFromCart(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class UpdateCartItemQuantity extends CartEvent {
  final String cartItemId;
  final int quantity;

  const UpdateCartItemQuantity({
    required this.cartItemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

class UpdateCartItemInstructions extends CartEvent {
  final String cartItemId;
  final String? specialInstructions;

  const UpdateCartItemInstructions({
    required this.cartItemId,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [cartItemId, specialInstructions];
}