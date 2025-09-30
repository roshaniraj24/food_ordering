// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      isVegetarian: json['isVegetarian'] as bool,
      isVegan: json['isVegan'] as bool,
      isSpicy: json['isSpicy'] as bool,
      allergens: (json['allergens'] as List<dynamic>).map((e) => e as String).toList(),
      preparationTime: json['preparationTime'] as int,
      isAvailable: json['isAvailable'] as bool,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      customizations: (json['customizations'] as List<dynamic>?)
          ?.map((e) => MenuItemCustomization.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'isVegetarian': instance.isVegetarian,
      'isVegan': instance.isVegan,
      'isSpicy': instance.isSpicy,
      'allergens': instance.allergens,
      'preparationTime': instance.preparationTime,
      'isAvailable': instance.isAvailable,
      'discountPercentage': instance.discountPercentage,
      'customizations': instance.customizations,
    };

MenuItemCustomization _$MenuItemCustomizationFromJson(Map<String, dynamic> json) =>
    MenuItemCustomization(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      isRequired: json['isRequired'] as bool,
      options: (json['options'] as List<dynamic>)
          .map((e) => CustomizationOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MenuItemCustomizationToJson(MenuItemCustomization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'isRequired': instance.isRequired,
      'options': instance.options,
    };

CustomizationOption _$CustomizationOptionFromJson(Map<String, dynamic> json) =>
    CustomizationOption(
      id: json['id'] as String,
      name: json['name'] as String,
      additionalPrice: (json['additionalPrice'] as num).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$CustomizationOptionToJson(CustomizationOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'additionalPrice': instance.additionalPrice,
      'isDefault': instance.isDefault,
    };