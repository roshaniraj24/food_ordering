import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'menu_item.g.dart';

@JsonSerializable()
class MenuItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isVegetarian;
  final bool isVegan;
  final bool isSpicy;
  final List<String> allergens;
  final int preparationTime;
  final bool isAvailable;
  final double? discountPercentage;
  final List<MenuItemCustomization>? customizations;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isVegetarian,
    required this.isVegan,
    required this.isSpicy,
    required this.allergens,
    required this.preparationTime,
    required this.isAvailable,
    this.discountPercentage,
    this.customizations,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemToJson(this);

  double get finalPrice {
    if (discountPercentage != null && discountPercentage! > 0) {
      return price * (1 - discountPercentage! / 100);
    }
    return price;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        category,
        isVegetarian,
        isVegan,
        isSpicy,
        allergens,
        preparationTime,
        isAvailable,
        discountPercentage,
        customizations,
      ];

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isVegetarian,
    bool? isVegan,
    bool? isSpicy,
    List<String>? allergens,
    int? preparationTime,
    bool? isAvailable,
    double? discountPercentage,
    List<MenuItemCustomization>? customizations,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isSpicy: isSpicy ?? this.isSpicy,
      allergens: allergens ?? this.allergens,
      preparationTime: preparationTime ?? this.preparationTime,
      isAvailable: isAvailable ?? this.isAvailable,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      customizations: customizations ?? this.customizations,
    );
  }
}

@JsonSerializable()
class MenuItemCustomization extends Equatable {
  final String id;
  final String name;
  final String type; // 'radio', 'checkbox', 'quantity'
  final bool isRequired;
  final List<CustomizationOption> options;

  const MenuItemCustomization({
    required this.id,
    required this.name,
    required this.type,
    required this.isRequired,
    required this.options,
  });

  factory MenuItemCustomization.fromJson(Map<String, dynamic> json) =>
      _$MenuItemCustomizationFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemCustomizationToJson(this);

  @override
  List<Object?> get props => [id, name, type, isRequired, options];
}

@JsonSerializable()
class CustomizationOption extends Equatable {
  final String id;
  final String name;
  final double additionalPrice;
  final bool isDefault;

  const CustomizationOption({
    required this.id,
    required this.name,
    required this.additionalPrice,
    this.isDefault = false,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) =>
      _$CustomizationOptionFromJson(json);

  Map<String, dynamic> toJson() => _$CustomizationOptionToJson(this);

  @override
  List<Object?> get props => [id, name, additionalPrice, isDefault];
}