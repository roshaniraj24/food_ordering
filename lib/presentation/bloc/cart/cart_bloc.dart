import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/models.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  static const _uuid = Uuid();

  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<ClearCart>(_onClearCart);
    on<UpdateCartItemInstructions>(_onUpdateCartItemInstructions);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final currentItems = List<CartItem>.from(state.items);
    
    // Check if we need to clear cart (different restaurant)
    if (state.restaurant != null && 
        currentItems.isNotEmpty &&
        currentItems.first.menuItem.id.split('_')[0] != event.menuItem.id.split('_')[0]) {
      // Different restaurant - clear cart first
      currentItems.clear();
    }

    // Create new cart item
    final cartItem = CartItem(
      id: _uuid.v4(),
      menuItem: event.menuItem,
      quantity: event.quantity,
      selectedCustomizations: event.selectedCustomizations,
      specialInstructions: event.specialInstructions,
    );

    currentItems.add(cartItem);

    // Determine restaurant from menu item ID
    Restaurant? restaurant;
    // This is a simplified approach - in a real app, you'd get this from the menu item
    // For now, we'll leave it null and handle it in the UI
    
    emit(state.copyWith(
      items: currentItems,
      restaurant: restaurant,
    ));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final currentItems = List<CartItem>.from(state.items);
    currentItems.removeWhere((item) => item.id == event.cartItemId);
    
    emit(state.copyWith(
      items: currentItems,
      restaurant: currentItems.isEmpty ? null : state.restaurant,
    ));
  }

  void _onUpdateCartItemQuantity(UpdateCartItemQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(event.cartItemId));
      return;
    }

    final currentItems = List<CartItem>.from(state.items);
    final itemIndex = currentItems.indexWhere((item) => item.id == event.cartItemId);
    
    if (itemIndex != -1) {
      currentItems[itemIndex] = currentItems[itemIndex].copyWith(
        quantity: event.quantity,
      );
      
      emit(state.copyWith(items: currentItems));
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState());
  }

  void _onUpdateCartItemInstructions(UpdateCartItemInstructions event, Emitter<CartState> emit) {
    final currentItems = List<CartItem>.from(state.items);
    final itemIndex = currentItems.indexWhere((item) => item.id == event.cartItemId);
    
    if (itemIndex != -1) {
      currentItems[itemIndex] = currentItems[itemIndex].copyWith(
        specialInstructions: event.specialInstructions,
      );
      
      emit(state.copyWith(items: currentItems));
    }
  }

  // Helper method to set restaurant
  void setRestaurant(Restaurant restaurant) {
    emit(state.copyWith(restaurant: restaurant));
  }
}