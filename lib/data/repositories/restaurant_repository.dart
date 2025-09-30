import '../models/models.dart';
import '../../core/result.dart';

abstract class RestaurantRepository {
  Future<Result<List<Restaurant>>> getRestaurants({
    String? category,
    String? searchQuery,
    double? minRating,
  });
  
  Future<Result<Restaurant>> getRestaurantById(String id);
  
  Future<Result<List<MenuItem>>> getMenuItems(String restaurantId);
  
  Future<Result<MenuItem>> getMenuItemById(String restaurantId, String itemId);
}