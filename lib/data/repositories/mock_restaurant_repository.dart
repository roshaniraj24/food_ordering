import 'dart:convert';
import 'dart:math';
import '../models/models.dart';
import '../../core/result.dart';
import '../../core/failures.dart';
import 'restaurant_repository.dart';

class MockRestaurantRepository implements RestaurantRepository {
  // Simulated network delay
  static const Duration _networkDelay = Duration(milliseconds: 800);
  
  // Mock data
  static final List<Restaurant> _mockRestaurants = [
    Restaurant(
      id: '1',
      name: 'Pizza Palace',
      description: 'Authentic Italian pizza and pasta',
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
      rating: 4.5,
      reviewCount: 324,
      category: 'Italian',
      deliveryTime: 30,
      deliveryFee: 2.99,
      minimumOrder: 15.0,
      isOpen: true,
      tags: ['Pizza', 'Pasta', 'Italian', 'Fast'],
    ),
    Restaurant(
      id: '2',
      name: 'Burger Barn',
      description: 'Juicy burgers and crispy fries',
      imageUrl: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500',
      rating: 4.2,
      reviewCount: 189,
      category: 'American',
      deliveryTime: 25,
      deliveryFee: 1.99,
      minimumOrder: 12.0,
      isOpen: true,
      tags: ['Burgers', 'Fries', 'American', 'Quick'],
    ),
    Restaurant(
      id: '3',
      name: 'Sushi Zen',
      description: 'Fresh sushi and Japanese cuisine',
      imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
      rating: 4.8,
      reviewCount: 456,
      category: 'Japanese',
      deliveryTime: 40,
      deliveryFee: 3.99,
      minimumOrder: 20.0,
      isOpen: true,
      tags: ['Sushi', 'Japanese', 'Fresh', 'Premium'],
    ),
    Restaurant(
      id: '4',
      name: 'Taco Fiesta',
      description: 'Authentic Mexican tacos and burritos',
      imageUrl: 'https://images.unsplash.com/photo-1565299585323-38174c684d37?w=500',
      rating: 4.3,
      reviewCount: 267,
      category: 'Mexican',
      deliveryTime: 35,
      deliveryFee: 2.49,
      minimumOrder: 10.0,
      isOpen: false,
      tags: ['Tacos', 'Mexican', 'Spicy', 'Authentic'],
    ),
  ];

  static final Map<String, List<MenuItem>> _mockMenuItems = {
    '1': [
      MenuItem(
        id: '1_1',
        name: 'Margherita Pizza',
        description: 'Classic pizza with tomato sauce, mozzarella, and fresh basil',
        price: 14.99,
        imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500',
        category: 'Pizza',
        isVegetarian: true,
        isVegan: false,
        isSpicy: false,
        allergens: ['Gluten', 'Dairy'],
        preparationTime: 15,
        isAvailable: true,
        customizations: [
          MenuItemCustomization(
            id: 'size',
            name: 'Size',
            type: 'radio',
            isRequired: true,
            options: [
              CustomizationOption(id: 'small', name: 'Small', additionalPrice: 0, isDefault: true),
              CustomizationOption(id: 'medium', name: 'Medium', additionalPrice: 3.0),
              CustomizationOption(id: 'large', name: 'Large', additionalPrice: 6.0),
            ],
          ),
          MenuItemCustomization(
            id: 'toppings',
            name: 'Extra Toppings',
            type: 'checkbox',
            isRequired: false,
            options: [
              CustomizationOption(id: 'pepperoni', name: 'Pepperoni', additionalPrice: 2.0),
              CustomizationOption(id: 'mushrooms', name: 'Mushrooms', additionalPrice: 1.5),
              CustomizationOption(id: 'olives', name: 'Olives', additionalPrice: 1.0),
            ],
          ),
        ],
      ),
      MenuItem(
        id: '1_2',
        name: 'Pepperoni Pizza',
        description: 'Classic pepperoni pizza with mozzarella cheese',
        price: 16.99,
        imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500',
        category: 'Pizza',
        isVegetarian: false,
        isVegan: false,
        isSpicy: false,
        allergens: ['Gluten', 'Dairy'],
        preparationTime: 15,
        isAvailable: true,
        discountPercentage: 10.0,
      ),
      MenuItem(
        id: '1_3',
        name: 'Spaghetti Carbonara',
        description: 'Creamy pasta with bacon, eggs, and parmesan cheese',
        price: 12.99,
        imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=500',
        category: 'Pasta',
        isVegetarian: false,
        isVegan: false,
        isSpicy: false,
        allergens: ['Gluten', 'Dairy', 'Eggs'],
        preparationTime: 20,
        isAvailable: true,
      ),
    ],
    '2': [
      MenuItem(
        id: '2_1',
        name: 'Classic Cheeseburger',
        description: 'Beef patty with cheese, lettuce, tomato, and pickles',
        price: 9.99,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        category: 'Burgers',
        isVegetarian: false,
        isVegan: false,
        isSpicy: false,
        allergens: ['Gluten', 'Dairy'],
        preparationTime: 12,
        isAvailable: true,
        customizations: [
          MenuItemCustomization(
            id: 'patty',
            name: 'Patty Type',
            type: 'radio',
            isRequired: true,
            options: [
              CustomizationOption(id: 'beef', name: 'Beef', additionalPrice: 0, isDefault: true),
              CustomizationOption(id: 'chicken', name: 'Chicken', additionalPrice: 0),
              CustomizationOption(id: 'veggie', name: 'Veggie', additionalPrice: -1.0),
            ],
          ),
        ],
      ),
      MenuItem(
        id: '2_2',
        name: 'Crispy Fries',
        description: 'Golden crispy french fries with sea salt',
        price: 4.99,
        imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500',
        category: 'Sides',
        isVegetarian: true,
        isVegan: true,
        isSpicy: false,
        allergens: [],
        preparationTime: 8,
        isAvailable: true,
      ),
    ],
    '3': [
      MenuItem(
        id: '3_1',
        name: 'Salmon Roll',
        description: 'Fresh salmon with avocado and cucumber',
        price: 12.99,
        imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
        category: 'Sushi',
        isVegetarian: false,
        isVegan: false,
        isSpicy: false,
        allergens: ['Fish'],
        preparationTime: 15,
        isAvailable: true,
      ),
      MenuItem(
        id: '3_2',
        name: 'California Roll',
        description: 'Crab, avocado, and cucumber roll',
        price: 8.99,
        imageUrl: 'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=500',
        category: 'Sushi',
        isVegetarian: false,
        isVegan: false,
        isSpicy: false,
        allergens: ['Shellfish'],
        preparationTime: 12,
        isAvailable: true,
      ),
    ],
    '4': [
      MenuItem(
        id: '4_1',
        name: 'Beef Tacos',
        description: 'Three soft tacos with seasoned beef, onions, and cilantro',
        price: 10.99,
        imageUrl: 'https://images.unsplash.com/photo-1565299585323-38174c684d37?w=500',
        category: 'Tacos',
        isVegetarian: false,
        isVegan: false,
        isSpicy: true,
        allergens: ['Gluten'],
        preparationTime: 15,
        isAvailable: true,
      ),
    ],
  };

  @override
  Future<Result<List<Restaurant>>> getRestaurants({
    String? category,
    String? searchQuery,
    double? minRating,
  }) async {
    try {
      await Future.delayed(_networkDelay);
      
      // Simulate occasional network failure
      if (Random().nextInt(10) == 0) {
        return failure(const NetworkFailure('Failed to load restaurants'));
      }

      List<Restaurant> filteredRestaurants = List.from(_mockRestaurants);

      // Apply filters
      if (category != null && category.isNotEmpty) {
        filteredRestaurants = filteredRestaurants
            .where((restaurant) => restaurant.category.toLowerCase() == category.toLowerCase())
            .toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        filteredRestaurants = filteredRestaurants
            .where((restaurant) =>
                restaurant.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                restaurant.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
                restaurant.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase())))
            .toList();
      }

      if (minRating != null) {
        filteredRestaurants = filteredRestaurants
            .where((restaurant) => restaurant.rating >= minRating)
            .toList();
      }

      return success(filteredRestaurants);
    } catch (e) {
      return failure(ServerFailure('Error loading restaurants: $e'));
    }
  }

  @override
  Future<Result<Restaurant>> getRestaurantById(String id) async {
    try {
      await Future.delayed(_networkDelay);
      
      final restaurant = _mockRestaurants.firstWhere(
        (r) => r.id == id,
        orElse: () => throw Exception('Restaurant not found'),
      );
      
      return success(restaurant);
    } catch (e) {
      return failure(const NotFoundFailure('Restaurant not found'));
    }
  }

  @override
  Future<Result<List<MenuItem>>> getMenuItems(String restaurantId) async {
    try {
      await Future.delayed(_networkDelay);
      
      final menuItems = _mockMenuItems[restaurantId];
      if (menuItems == null) {
        return failure(const NotFoundFailure('Menu not found for this restaurant'));
      }
      
      return success(menuItems);
    } catch (e) {
      return failure(ServerFailure('Error loading menu items: $e'));
    }
  }

  @override
  Future<Result<MenuItem>> getMenuItemById(String restaurantId, String itemId) async {
    try {
      await Future.delayed(_networkDelay);
      
      final menuItems = _mockMenuItems[restaurantId];
      if (menuItems == null) {
        return failure(const NotFoundFailure('Menu not found for this restaurant'));
      }
      
      final menuItem = menuItems.firstWhere(
        (item) => item.id == itemId,
        orElse: () => throw Exception('Menu item not found'),
      );
      
      return success(menuItem);
    } catch (e) {
      return failure(const NotFoundFailure('Menu item not found'));
    }
  }
}