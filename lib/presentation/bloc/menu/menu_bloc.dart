import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/restaurant_repository.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final RestaurantRepository _restaurantRepository;
  String? _currentRestaurantId;

  MenuBloc({
    required RestaurantRepository restaurantRepository,
  })  : _restaurantRepository = restaurantRepository,
        super(const MenuInitial()) {
    on<LoadMenu>(_onLoadMenu);
    on<RefreshMenu>(_onRefreshMenu);
  }

  Future<void> _onLoadMenu(
    LoadMenu event,
    Emitter<MenuState> emit,
  ) async {
    _currentRestaurantId = event.restaurantId;
    emit(const MenuLoading());

    final result = await _restaurantRepository.getMenuItems(event.restaurantId);

    result.fold(
      (failure) => emit(MenuError(failure)),
      (menuItems) => emit(MenuLoaded(
        menuItems: menuItems,
        restaurantId: event.restaurantId,
      )),
    );
  }

  Future<void> _onRefreshMenu(
    RefreshMenu event,
    Emitter<MenuState> emit,
  ) async {
    if (_currentRestaurantId != null) {
      add(LoadMenu(_currentRestaurantId!));
    }
  }
}