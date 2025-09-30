import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_app/data/models/models.dart';
import 'package:food_order_app/presentation/bloc/cart/cart_bloc.dart';

void main() {
  group('CartBloc Tests', () {
    late CartBloc cartBloc;

    final testMenuItem1 = MenuItem(
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
    );

    final testMenuItem2 = MenuItem(
      id: '2',
      name: 'Caesar Salad',
      description: 'Fresh romaine with Caesar dressing',
      price: 12.99,
      imageUrl: 'https://test.com/caesar.jpg',
      category: 'Salads',
      isVegetarian: true,
      isVegan: false,
      isSpicy: false,
      allergens: const ['Dairy'],
      preparationTime: 10,
      isAvailable: true,
    );

    final testCartItem1 = CartItem(
      id: 'cart-1',
      menuItem: testMenuItem1,
      quantity: 2,
      customizations: const {'size': ['Large']},
    );

    final testCartItem2 = CartItem(
      id: 'cart-2',
      menuItem: testMenuItem2,
      quantity: 1,
    );

    setUp(() {
      cartBloc = CartBloc();
    });

    tearDown(() {
      cartBloc.close();
    });

    test('initial state is CartEmpty', () {
      expect(cartBloc.state, const CartEmpty());
    });

    group('AddToCart', () {
      blocTest<CartBloc, CartState>(
        'adds item to empty cart',
        build: () => cartBloc,
        act: (bloc) => bloc.add(AddToCart(
          menuItem: testMenuItem1,
          quantity: 2,
          customizations: const {'size': ['Large']},
          specialInstructions: 'No onions',
        )),
        expect: () => [
          CartLoaded(
            items: [
              CartItem(
                id: 'cart-1', // Generated ID will vary, so we check structure
                menuItem: testMenuItem1,
                quantity: 2,
                customizations: const {'size': ['Large']},
                specialInstructions: 'No onions',
              ).copyWith(id: cartBloc.state is CartLoaded ? (cartBloc.state as CartLoaded).items.first.id : 'cart-1'),
            ],
            totalAmount: 31.98, // 15.99 * 2
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'adds second item to existing cart',
        build: () => cartBloc,
        seed: () => CartLoaded(
          items: [testCartItem1],
          totalAmount: testCartItem1.totalPrice,
        ),
        act: (bloc) => bloc.add(AddToCart(
          menuItem: testMenuItem2,
          quantity: 1,
        )),
        expect: () => [
          CartLoaded(
            items: [
              testCartItem1,
              CartItem(
                id: 'cart-2', // ID will be generated
                menuItem: testMenuItem2,
                quantity: 1,
              ).copyWith(id: 'cart-2'), // We'll verify structure rather than exact ID
            ],
            totalAmount: 44.97, // 31.98 + 12.99
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as CartLoaded;
          expect(state.items.length, 2);
          expect(state.totalAmount, 44.97);
        },
      );

      blocTest<CartBloc, CartState>(
        'increases quantity when adding same item with same customizations',
        build: () => cartBloc,
        seed: () => CartLoaded(
          items: [testCartItem1],
          totalAmount: testCartItem1.totalPrice,
        ),
        act: (bloc) => bloc.add(AddToCart(
          menuItem: testMenuItem1,
          quantity: 1,
          customizations: const {'size': ['Large']}, // Same customizations
        )),
        expect: () => [
          CartLoaded(
            items: [
              testCartItem1.copyWith(quantity: 3), // Quantity increased from 2 to 3
            ],
            totalAmount: 47.97, // 15.99 * 3
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'adds separate item when customizations are different',
        build: () => cartBloc,
        seed: () => CartLoaded(
          items: [testCartItem1],
          totalAmount: testCartItem1.totalPrice,
        ),
        act: (bloc) => bloc.add(AddToCart(
          menuItem: testMenuItem1,
          quantity: 1,
          customizations: const {'size': ['Medium']}, // Different customizations
        )),
        expect: () => [
          CartLoaded(
            items: [
              testCartItem1,
              CartItem(
                id: 'cart-2',
                menuItem: testMenuItem1,
                quantity: 1,
                customizations: const {'size': ['Medium']},
              ).copyWith(id: 'cart-2'),
            ],
            totalAmount: 47.97, // 31.98 + 15.99
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as CartLoaded;
          expect(state.items.length, 2);
        },
      );
    });

    group('RemoveFromCart', () {
      blocTest<CartBloc, CartState>(
        'removes item from cart',
        build: () => cartBloc,
        seed: () => CartLoaded(
          items: [testCartItem1, testCartItem2],
          totalAmount: testCartItem1.totalPrice + testCartItem2.totalPrice,
        ),
        act: (bloc) => bloc.add(RemoveFromCart(itemId: testCartItem1.id)),
        expect: () => [
          CartLoaded(
            items: [testCartItem2],
            totalAmount: testCartItem2.totalPrice,
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'transitions to CartEmpty when removing last item',
        build: () => cartBloc,
        seed: () => CartLoaded(
          items: [testCartItem1],
          totalAmount: testCartItem1.totalPrice,
        ),
        act: (bloc) => bloc.add(RemoveFromCart(itemId: testCartItem1.id)),
        expect: () => [
          const CartEmpty(),
        ],
      );

      blocTest<CartBloc, CartState>(
        'does nothing when removing non-existent item',
        build: () => cartBloc,
        seed: () => CartLoaded(
          items: [testCartItem1],
          totalAmount: testCartItem1.totalPrice,
        ),
        act: (bloc) => bloc.add(const RemoveFromCart(itemId: 'non-existent')),
        expect: () => [],
      );
    });

    group('UpdateCartItemQuantity', () {
      blocTest<CartBloc, CartState>(
        'updates item quantity',
        build: () => cartBloc,
        seed: () => CartLoaded(
          items: [testCartItem1],
          totalAmount: testCartItem1.totalPrice,
        ),
        act: (bloc) => bloc.add(UpdateCartItemQuantity(
          itemId: testCartItem1.id,
          quantity: 3,
        )),
        expect: () => [
          CartLoaded(
            items: [testCartItem1.copyWith(quantity: 3)],
            totalAmount: 47.97, // 15.99 * 3
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'removes item when quantity is set to 0',
        build: () => cartBloc,
        seed: () => CartLoaded(
          items: [testCartItem1, testCartItem2],
          totalAmount: testCartItem1.totalPrice + testCartItem2.totalPrice,
        ),
        act: (bloc) => bloc.add(UpdateCartItemQuantity(
          itemId: testCartItem1.id,
          quantity: 0,
        )),
        expect: () => [
          CartLoaded(
            items: [testCartItem2],
            totalAmount: testCartItem2.totalPrice,
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'transitions to CartEmpty when last item quantity is set to 0',
        build: () => cartBloc,
        seed: () => CartLoaded(
          items: [testCartItem1],
          totalAmount: testCartItem1.totalPrice,
        ),
        act: (bloc) => bloc.add(UpdateCartItemQuantity(
          itemId: testCartItem1.id,
          quantity: 0,
        )),
        expect: () => [
          const CartEmpty(),
        ],
      );

      blocTest<CartBloc, CartState>(
        'does nothing when updating non-existent item',
        build: () => cartBloc,
        seed: () => CartLoaded(
          items: [testCartItem1],
          totalAmount: testCartItem1.totalPrice,
        ),
        act: (bloc) => bloc.add(const UpdateCartItemQuantity(
          itemId: 'non-existent',
          quantity: 5,
        )),
        expect: () => [],
      );
    });

    group('ClearCart', () {
      blocTest<CartBloc, CartState>(
        'clears all items from cart',
        build: () => cartBloc,
        seed: () => CartLoaded(
          items: [testCartItem1, testCartItem2],
          totalAmount: testCartItem1.totalPrice + testCartItem2.totalPrice,
        ),
        act: (bloc) => bloc.add(const ClearCart()),
        expect: () => [
          const CartEmpty(),
        ],
      );

      blocTest<CartBloc, CartState>(
        'does nothing when cart is already empty',
        build: () => cartBloc,
        act: (bloc) => bloc.add(const ClearCart()),
        expect: () => [],
      );
    });

    group('Total Calculation', () {
      test('calculates total correctly for multiple items', () {
        // Arrange
        final items = [testCartItem1, testCartItem2];
        final expectedTotal = testCartItem1.totalPrice + testCartItem2.totalPrice;

        // Act
        cartBloc.add(AddToCart(menuItem: testMenuItem1, quantity: 2, customizations: const {'size': ['Large']}));
        cartBloc.add(AddToCart(menuItem: testMenuItem2, quantity: 1));

        // Wait for bloc to process
        expectLater(
          cartBloc.stream,
          emitsInOrder([
            isA<CartLoaded>(),
            isA<CartLoaded>().having((state) => state.totalAmount, 'totalAmount', closeTo(expectedTotal, 0.01)),
          ]),
        );
      });
    });

    group('Cart Item Management', () {
      blocTest<CartBloc, CartState>(
        'maintains cart item IDs consistently',
        build: () => cartBloc,
        act: (bloc) {
          bloc.add(AddToCart(menuItem: testMenuItem1, quantity: 1));
          bloc.add(AddToCart(menuItem: testMenuItem2, quantity: 1));
        },
        verify: (bloc) {
          final state = bloc.state as CartLoaded;
          expect(state.items.length, 2);
          expect(state.items[0].id, isNotEmpty);
          expect(state.items[1].id, isNotEmpty);
          expect(state.items[0].id, isNot(equals(state.items[1].id)));
        },
      );

      blocTest<CartBloc, CartState>(
        'preserves item customizations and special instructions',
        build: () => cartBloc,
        act: (bloc) => bloc.add(AddToCart(
          menuItem: testMenuItem1,
          quantity: 1,
          customizations: const {
            'size': ['Large'],
            'toppings': ['Extra Cheese', 'Pepperoni'],
          },
          specialInstructions: 'Extra crispy crust',
        )),
        verify: (bloc) {
          final state = bloc.state as CartLoaded;
          final item = state.items.first;
          expect(item.customizations['size'], ['Large']);
          expect(item.customizations['toppings'], ['Extra Cheese', 'Pepperoni']);
          expect(item.specialInstructions, 'Extra crispy crust');
        },
      );
    });
  });
}