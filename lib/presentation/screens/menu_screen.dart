import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/bloc.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/cart_floating_button.dart';
import '../../data/models/models.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final Restaurant restaurant;

  const MenuScreen({super.key, required this.restaurant});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Set restaurant in cart bloc and load menu
    context.read<CartBloc>().setRestaurant(widget.restaurant);
    context.read<MenuBloc>().add(LoadMenu(widget.restaurant.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Restaurant header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.restaurant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/italian.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Restaurant info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),

                  if (widget.restaurant.category.toLowerCase() == 'italian') ...[
                    const Text(
                      'Italian Food Links:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse('https://stock.adobe.com/search?k=italian+food'));
                      },
                      child: const Text(
                        'Italian Food Images on Adobe Stock',
                        style: TextStyle(
                          color: Color(0xFF74B9FF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse('https://ahwatukee411.com/phoenixs-italian-food-gems/'));
                      },
                      child: const Text(
                        'Phoenix\'s Italian Food Gems',
                        style: TextStyle(
                          color: Color(0xFF74B9FF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text('${widget.restaurant.rating}'),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${widget.restaurant.deliveryTime} min'),
                      const SizedBox(width: 16),
                      Icon(Icons.delivery_dining, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('₹${widget.restaurant.deliveryFee.toStringAsFixed(2)}'),
                    ],
                  ),
                  if (!widget.restaurant.isOpen) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'This restaurant is currently closed',
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Menu items
          BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              if (state is MenuLoading) {
                return const SliverFillRemaining(
                  child: LoadingWidget(message: 'Loading menu...'),
                );
              } else if (state is MenuError) {
                return SliverFillRemaining(
                  child: ErrorWidgetCustom(
                    message: state.failure.message,
                    onRetry: () {
                      context.read<MenuBloc>().add(LoadMenu(widget.restaurant.id));
                    },
                  ),
                );
              } else if (state is MenuLoaded) {
                final categories = state.categories;
                
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        // Category filter
                        return Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: const Text('All'),
                                  selected: selectedCategory == null,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedCategory = selected ? null : selectedCategory;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                ...categories.map((category) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(category),
                                      selected: selectedCategory == category,
                                      onSelected: (selected) {
                                        setState(() {
                                          selectedCategory = selected ? category : null;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      // Menu items
                      final menuItems = selectedCategory != null
                          ? state.getItemsByCategory(selectedCategory!)
                          : state.menuItems;
                      
                      if (menuItems.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('No items available in this category'),
                          ),
                        );
                      }
                      
                      final item = menuItems[index - 1];
                      return MenuItemCard(
                        menuItem: item,
                        onAddToCart: (menuItem, quantity, customizations, instructions) {
                          context.read<CartBloc>().add(AddToCart(
                            menuItem: menuItem,
                            quantity: quantity,
                            selectedCustomizations: customizations,
                            specialInstructions: instructions,
                          ));
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${menuItem.name} added to cart'),
                              action: SnackBarAction(
                                label: 'View Cart',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CartScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: (selectedCategory != null 
                        ? state.getItemsByCategory(selectedCategory!).length 
                        : state.menuItems.length) + 1,
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
      floatingActionButton: const CartFloatingButton(),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final Function(MenuItem, int, Map<String, List<String>>, String?) onAddToCart;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          _showMenuItemDetails(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: menuItem.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.restaurant),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.restaurant),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            menuItem.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!menuItem.isAvailable) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Unavailable',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      menuItem.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tags and allergens
                    Row(
                      children: [
                        if (menuItem.isVegetarian) ...[
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green.shade700),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (menuItem.isSpicy) ...[
                          Icon(Icons.local_fire_department, 
                               color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          '${menuItem.preparationTime} min',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Price and add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (menuItem.discountPercentage != null) ...[
                              Text(
                                '₹${menuItem.price.toStringAsFixed(2)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                            Text(
                              '₹${menuItem.finalPrice.toStringAsFixed(2)}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        BlocBuilder<CartBloc, CartState>(
                          builder: (context, cartState) {
                            final quantity = cartState.getItemQuantity(menuItem.id);
                            
                            if (quantity > 0) {
                              return Row(
                                children: [
                                  IconButton(
                                    onPressed: menuItem.isAvailable ? () {
                                      // Find and remove one item
                                      final cartItem = cartState.items.firstWhere(
                                        (item) => item.menuItem.id == menuItem.id,
                                      );
                                      context.read<CartBloc>().add(
                                        UpdateCartItemQuantity(
                                          cartItemId: cartItem.id,
                                          quantity: cartItem.quantity - 1,
                                        ),
                                      );
                                    } : null,
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: theme.primaryColor,
                                  ),
                                  Text(
                                    quantity.toString(),
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  IconButton(
                                    onPressed: menuItem.isAvailable ? () {
                                      onAddToCart(menuItem, 1, {}, null);
                                    } : null,
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: theme.primaryColor,
                                  ),
                                ],
                              );
                            }
                            
                            return ElevatedButton(
                              onPressed: menuItem.isAvailable ? () {
                                if (menuItem.customizations?.isNotEmpty == true) {
                                  _showMenuItemDetails(context);
                                } else {
                                  onAddToCart(menuItem, 1, {}, null);
                                }
                              } : null,
                              child: const Text('Add'),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenuItemDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuItemDetailsSheet(
        menuItem: menuItem,
        onAddToCart: onAddToCart,
      ),
    );
  }
}

class MenuItemDetailsSheet extends StatefulWidget {
  final MenuItem menuItem;
  final Function(MenuItem, int, Map<String, List<String>>, String?) onAddToCart;

  const MenuItemDetailsSheet({
    super.key,
    required this.menuItem,
    required this.onAddToCart,
  });

  @override
  State<MenuItemDetailsSheet> createState() => _MenuItemDetailsSheetState();
}

class _MenuItemDetailsSheetState extends State<MenuItemDetailsSheet> {
  int quantity = 1;
  Map<String, List<String>> selectedCustomizations = {};
  final TextEditingController instructionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: widget.menuItem.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Item name and price
                  Text(
                    widget.menuItem.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    widget.menuItem.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    '₹${widget.menuItem.finalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Customizations
                  if (widget.menuItem.customizations?.isNotEmpty == true) ...[
                    ...widget.menuItem.customizations!.map((customization) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customization.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (customization.isRequired)
                            Text(
                              'Required',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(height: 8),
                          ...customization.options.map((option) {
                            final isSelected = selectedCustomizations[customization.id]?.contains(option.id) ?? false;
                            return CheckboxListTile(
                              title: Text(option.name),
                              subtitle: option.additionalPrice > 0
                                  ? Text('+₹${option.additionalPrice.toStringAsFixed(2)}')
                                  : null,
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (customization.type == 'radio') {
                                    selectedCustomizations[customization.id] = value == true ? [option.id] : [];
                                  } else {
                                    selectedCustomizations[customization.id] ??= [];
                                    if (value == true) {
                                      selectedCustomizations[customization.id]!.add(option.id);
                                    } else {
                                      selectedCustomizations[customization.id]!.remove(option.id);
                                    }
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                  ],
                  
                  // Special instructions
                  TextField(
                    controller: instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Special Instructions',
                      hintText: 'Any special requests?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Bottom bar with quantity and add to cart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Quantity selector
                Row(
                  children: [
                    IconButton(
                      onPressed: quantity > 1 ? () {
                        setState(() {
                          quantity--;
                        });
                      } : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      quantity.toString(),
                      style: theme.textTheme.headlineSmall,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Add to cart button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onAddToCart(
                        widget.menuItem,
                        quantity,
                        selectedCustomizations,
                        instructionsController.text.isNotEmpty 
                            ? instructionsController.text 
                            : null,
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Add to Cart - ₹${(widget.menuItem.finalPrice * quantity).toStringAsFixed(2)}'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}