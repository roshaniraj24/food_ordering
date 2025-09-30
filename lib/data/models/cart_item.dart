import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'menu_item.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem extends Equatable {
  final String id;
  final MenuItem menuItem;
  final int quantity;
  final Map<String, List<String>> selectedCustomizations;
  final String? specialInstructions;

  const CartItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.selectedCustomizations,
    this.specialInstructions,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  double get totalPrice {
    double basePrice = menuItem.finalPrice * quantity;
    double customizationPrice = 0.0;

    // Calculate customization price
    if (menuItem.customizations != null) {
      for (final customization in menuItem.customizations!) {
        final selectedOptions = selectedCustomizations[customization.id] ?? [];
        for (final optionId in selectedOptions) {
          final option = customization.options.firstWhere(
            (o) => o.id == optionId,
            orElse: () => const CustomizationOption(
              id: '',
              name: '',
              additionalPrice: 0,
            ),
          );
          customizationPrice += option.additionalPrice * quantity;
        }
      }
    }

    return basePrice + customizationPrice;
  }

  @override
  List<Object?> get props => [
        id,
        menuItem,
        quantity,
        selectedCustomizations,
        specialInstructions,
      ];

  CartItem copyWith({
    String? id,
    MenuItem? menuItem,
    int? quantity,
    Map<String, List<String>>? selectedCustomizations,
    String? specialInstructions,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      selectedCustomizations: selectedCustomizations ?? this.selectedCustomizations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}