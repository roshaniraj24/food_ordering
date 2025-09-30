import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:food_order_app/core/failures.dart';
import 'package:food_order_app/data/models/models.dart';
import 'package:food_order_app/data/repositories/restaurant_repository.dart';
import 'package:food_order_app/presentation/bloc/menu/menu_bloc.dart';

class MockRestaurantRepository extends Mock implements RestaurantRepository {}

void main() {
  group('MenuBloc Tests', () {
    late MenuBloc menuBloc;
    late MockRestaurantRepository mockRepository;

    final testMenuItems = [
      MenuItem(
        id: '1',
        name: 'Margherita Pizza',
        description: 'Classic pizza with tomato and mozzarella',
        price: 15.99,
        imageUrl: 'https://test.com/margherita.jpg',
        category: 'Pizza',
        isVegetarian: true,
        isVegan: false,
        isSpicy: false,
        allergens: const ['Gluten', 'Dairy'],
        preparationTime: 20,
        isAvailable: true,
      ),
      MenuItem(
        id: '2',
        name: 'Chicken Caesar Salad',
        description: 'Fresh romaine with grilled chicken',
        price: 12.99,
        imageUrl: 'https://test.com/caesar.jpg',
        category: 'Salads',
        isVegetarian: false,
        isVegan: false,
        isSpicy: false,
        allergens: const ['Dairy'],
        preparationTime: 10,
        isAvailable: true,
      ),
      MenuItem(
        id: '3',
        name: 'Spicy Wings',
        description: 'Buffalo chicken wings',
        price: 9.99,
        imageUrl: 'https://test.com/wings.jpg',
        category: 'Appetizers',
        isVegetarian: false,
        isVegan: false,
        isSpicy: true,
        allergens: const [],
        preparationTime: 15,
        isAvailable: false, // Not available
      ),
    ];

    const testRestaurantId = 'restaurant-1';

    setUp(() {
      mockRepository = MockRestaurantRepository();
      menuBloc = MenuBloc(restaurantRepository: mockRepository);
    });

    tearDown(() {
      menuBloc.close();
    });

    test('initial state is MenuInitial', () {
      expect(menuBloc.state, const MenuInitial());
    });

    group('LoadMenuItems', () {
      blocTest<MenuBloc, MenuState>(
        'emits [MenuLoading, MenuLoaded] when LoadMenuItems succeeds',
        build: () {
          when(() => mockRepository.getMenuItems(testRestaurantId))
              .thenAnswer((_) async => Right(testMenuItems));
          return menuBloc;
        },
        act: (bloc) => bloc.add(const LoadMenuItems(restaurantId: testRestaurantId)),
        expect: () => [
          const MenuLoading(),
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: testMenuItems,
            selectedCategory: null,
            showVegetarianOnly: false,
            showAvailableOnly: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getMenuItems(testRestaurantId)).called(1);
        },
      );

      blocTest<MenuBloc, MenuState>(
        'emits [MenuLoading, MenuError] when LoadMenuItems fails',
        build: () {
          when(() => mockRepository.getMenuItems(testRestaurantId))
              .thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return menuBloc;
        },
        act: (bloc) => bloc.add(const LoadMenuItems(restaurantId: testRestaurantId)),
        expect: () => [
          const MenuLoading(),
          const MenuError(message: 'Server error'),
        ],
        verify: (_) {
          verify(() => mockRepository.getMenuItems(testRestaurantId)).called(1);
        },
      );
    });

    group('FilterByCategory', () {
      blocTest<MenuBloc, MenuState>(
        'filters menu items by category when menu is already loaded',
        build: () {
          when(() => mockRepository.getMenuItems(testRestaurantId))
              .thenAnswer((_) async => Right(testMenuItems));
          return menuBloc;
        },
        seed: () => MenuLoaded(
          menuItems: testMenuItems,
          filteredItems: testMenuItems,
          selectedCategory: null,
          showVegetarianOnly: false,
          showAvailableOnly: false,
        ),
        act: (bloc) => bloc.add(const FilterByCategory(category: 'Pizza')),
        expect: () => [
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: [testMenuItems[0]], // Only Margherita Pizza
            selectedCategory: 'Pizza',
            showVegetarianOnly: false,
            showAvailableOnly: false,
          ),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'shows all items when category is null',
        build: () => menuBloc,
        seed: () => MenuLoaded(
          menuItems: testMenuItems,
          filteredItems: [testMenuItems[0]], // Previously filtered
          selectedCategory: 'Pizza',
          showVegetarianOnly: false,
          showAvailableOnly: false,
        ),
        act: (bloc) => bloc.add(const FilterByCategory(category: null)),
        expect: () => [
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: testMenuItems, // All items
            selectedCategory: null,
            showVegetarianOnly: false,
            showAvailableOnly: false,
          ),
        ],
      );
    });

    group('ToggleVegetarianFilter', () {
      blocTest<MenuBloc, MenuState>(
        'filters vegetarian items when toggled on',
        build: () => menuBloc,
        seed: () => MenuLoaded(
          menuItems: testMenuItems,
          filteredItems: testMenuItems,
          selectedCategory: null,
          showVegetarianOnly: false,
          showAvailableOnly: false,
        ),
        act: (bloc) => bloc.add(const ToggleVegetarianFilter()),
        expect: () => [
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: [testMenuItems[0]], // Only Margherita Pizza is vegetarian
            selectedCategory: null,
            showVegetarianOnly: true,
            showAvailableOnly: false,
          ),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'shows all items when vegetarian filter is toggled off',
        build: () => menuBloc,
        seed: () => MenuLoaded(
          menuItems: testMenuItems,
          filteredItems: [testMenuItems[0]], // Previously filtered to vegetarian
          selectedCategory: null,
          showVegetarianOnly: true,
          showAvailableOnly: false,
        ),
        act: (bloc) => bloc.add(const ToggleVegetarianFilter()),
        expect: () => [
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: testMenuItems, // All items
            selectedCategory: null,
            showVegetarianOnly: false,
            showAvailableOnly: false,
          ),
        ],
      );
    });

    group('ToggleAvailabilityFilter', () {
      blocTest<MenuBloc, MenuState>(
        'filters available items when toggled on',
        build: () => menuBloc,
        seed: () => MenuLoaded(
          menuItems: testMenuItems,
          filteredItems: testMenuItems,
          selectedCategory: null,
          showVegetarianOnly: false,
          showAvailableOnly: false,
        ),
        act: (bloc) => bloc.add(const ToggleAvailabilityFilter()),
        expect: () => [
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: [testMenuItems[0], testMenuItems[1]], // Available items only
            selectedCategory: null,
            showVegetarianOnly: false,
            showAvailableOnly: true,
          ),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'shows all items when availability filter is toggled off',
        build: () => menuBloc,
        seed: () => MenuLoaded(
          menuItems: testMenuItems,
          filteredItems: [testMenuItems[0], testMenuItems[1]], // Previously filtered to available
          selectedCategory: null,
          showVegetarianOnly: false,
          showAvailableOnly: true,
        ),
        act: (bloc) => bloc.add(const ToggleAvailabilityFilter()),
        expect: () => [
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: testMenuItems, // All items
            selectedCategory: null,
            showVegetarianOnly: false,
            showAvailableOnly: false,
          ),
        ],
      );
    });

    group('Combined Filters', () {
      blocTest<MenuBloc, MenuState>(
        'applies multiple filters correctly',
        build: () => menuBloc,
        seed: () => MenuLoaded(
          menuItems: testMenuItems,
          filteredItems: testMenuItems,
          selectedCategory: null,
          showVegetarianOnly: false,
          showAvailableOnly: false,
        ),
        act: (bloc) {
          bloc.add(const ToggleVegetarianFilter()); // Show vegetarian only
          bloc.add(const ToggleAvailabilityFilter()); // Show available only
        },
        expect: () => [
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: [testMenuItems[0]], // Only Margherita Pizza is vegetarian
            selectedCategory: null,
            showVegetarianOnly: true,
            showAvailableOnly: false,
          ),
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: [testMenuItems[0]], // Margherita Pizza is vegetarian AND available
            selectedCategory: null,
            showVegetarianOnly: true,
            showAvailableOnly: true,
          ),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'applies category and vegetarian filters together',
        build: () => menuBloc,
        seed: () => MenuLoaded(
          menuItems: testMenuItems,
          filteredItems: testMenuItems,
          selectedCategory: null,
          showVegetarianOnly: false,
          showAvailableOnly: false,
        ),
        act: (bloc) {
          bloc.add(const FilterByCategory(category: 'Pizza'));
          bloc.add(const ToggleVegetarianFilter());
        },
        expect: () => [
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: [testMenuItems[0]], // Only Pizza items
            selectedCategory: 'Pizza',
            showVegetarianOnly: false,
            showAvailableOnly: false,
          ),
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: [testMenuItems[0]], // Pizza items that are vegetarian
            selectedCategory: 'Pizza',
            showVegetarianOnly: true,
            showAvailableOnly: false,
          ),
        ],
      );
    });

    group('ClearFilters', () {
      blocTest<MenuBloc, MenuState>(
        'clears all filters and shows all menu items',
        build: () => menuBloc,
        seed: () => MenuLoaded(
          menuItems: testMenuItems,
          filteredItems: [testMenuItems[0]], // Previously filtered
          selectedCategory: 'Pizza',
          showVegetarianOnly: true,
          showAvailableOnly: true,
        ),
        act: (bloc) => bloc.add(const ClearFilters()),
        expect: () => [
          MenuLoaded(
            menuItems: testMenuItems,
            filteredItems: testMenuItems, // All items
            selectedCategory: null,
            showVegetarianOnly: false,
            showAvailableOnly: false,
          ),
        ],
      );
    });

    group('Edge Cases', () {
      blocTest<MenuBloc, MenuState>(
        'handles empty menu items list',
        build: () {
          when(() => mockRepository.getMenuItems(testRestaurantId))
              .thenAnswer((_) async => const Right([]));
          return menuBloc;
        },
        act: (bloc) => bloc.add(const LoadMenuItems(restaurantId: testRestaurantId)),
        expect: () => [
          const MenuLoading(),
          const MenuLoaded(
            menuItems: [],
            filteredItems: [],
            selectedCategory: null,
            showVegetarianOnly: false,
            showAvailableOnly: false,
          ),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'handles filter events when menu is not loaded',
        build: () => menuBloc,
        act: (bloc) => bloc.add(const FilterByCategory(category: 'Pizza')),
        expect: () => [],
      );

      blocTest<MenuBloc, MenuState>(
        'handles repository exceptions gracefully',
        build: () {
          when(() => mockRepository.getMenuItems(testRestaurantId))
              .thenThrow(Exception('Unexpected error'));
          return menuBloc;
        },
        act: (bloc) => bloc.add(const LoadMenuItems(restaurantId: testRestaurantId)),
        expect: () => [
          const MenuLoading(),
          const MenuError(message: 'An unexpected error occurred'),
        ],
      );
    });
  });
}