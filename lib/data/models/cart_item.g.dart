// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
      id: json['id'] as String,
      menuItem: MenuItem.fromJson(json['menuItem'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedCustomizations: Map<String, List<String>>.from(
        (json['selectedCustomizations'] as Map<String, dynamic>).map(
          (k, e) => MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
        ),
      ),
      specialInstructions: json['specialInstructions'] as String?,
    );

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
      'id': instance.id,
      'menuItem': instance.menuItem,
      'quantity': instance.quantity,
      'selectedCustomizations': instance.selectedCustomizations,
      'specialInstructions': instance.specialInstructions,
    };