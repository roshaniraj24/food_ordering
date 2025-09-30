import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';
import '../../../core/failures.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {
  const MenuInitial();
}

class MenuLoading extends MenuState {
  const MenuLoading();
}

class MenuLoaded extends MenuState {
  final List<MenuItem> menuItems;
  final String restaurantId;

  const MenuLoaded({
    required this.menuItems,
    required this.restaurantId,
  });

  @override
  List<Object?> get props => [menuItems, restaurantId];

  List<MenuItem> getItemsByCategory(String category) {
    return menuItems.where((item) => item.category == category).toList();
  }

  List<String> get categories {
    return menuItems.map((item) => item.category).toSet().toList()..sort();
  }
}

class MenuError extends MenuState {
  final Failure failure;

  const MenuError(this.failure);

  @override
  List<Object?> get props => [failure];
}