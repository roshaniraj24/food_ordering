import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/bloc.dart';
import '../widgets/animated_cart_item.dart';
import '../widgets/animated_widgets.dart';
import '../../data/models/models.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Cart'),
                        content: const Text('Are you sure you want to remove all items from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<CartBloc>().add(const ClearCart());
                              Navigator.pop(context);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Clear'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return const EmptyCartWidget();
          }

          return Column(
            children: [
              // Restaurant info
              if (state.restaurant != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.restaurant, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.restaurant!.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Delivery in ${state.restaurant!.deliveryTime} min',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],

              // Minimum order warning
              if (!state.meetsMinimumOrder && state.restaurant != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Add \$${state.remainingForMinimumOrder.toStringAsFixed(2)} more to meet the minimum order of \$${state.restaurant!.minimumOrder.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],

              // Cart items
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final cartItem = state.items[index];
                    return FadeInAnimation(
                      delay: Duration(milliseconds: index * 100),
                      child: AnimatedCartItem(
                        cartItem: cartItem,
                        onIncrement: () {
                          context.read<CartBloc>().add(UpdateCartItemQuantity(
                            cartItemId: cartItem.id,
                            quantity: cartItem.quantity + 1,
                          ));
                        },
                        onDecrement: () {
                          if (cartItem.quantity > 1) {
                            context.read<CartBloc>().add(UpdateCartItemQuantity(
                              cartItemId: cartItem.id,
                              quantity: cartItem.quantity - 1,
                            ));
                          } else {
                            context.read<CartBloc>().add(RemoveFromCart(cartItem.id));
                          }
                        },
                        onRemove: () {
                          context.read<CartBloc>().add(RemoveFromCart(cartItem.id));
                        },
                      ),
                    );
                  },
                ),
              ),

              // Order summary
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    OrderSummaryRow(
                      label: 'Subtotal',
                      value: '\$${state.subtotal.toStringAsFixed(2)}',
                    ),
                    OrderSummaryRow(
                      label: 'Delivery Fee',
                      value: '\$${state.deliveryFee.toStringAsFixed(2)}',
                    ),
                    OrderSummaryRow(
                      label: 'Tax',
                      value: '\$${state.tax.toStringAsFixed(2)}',
                    ),
                    const Divider(),
                    OrderSummaryRow(
                      label: 'Total',
                      value: '\$${state.total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.meetsMinimumOrder ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CheckoutScreen(),
                            ),
                          );
                        } : null,
                        child: Text('Proceed to Checkout (${state.totalItems} items)'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items from a restaurant to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Browse Restaurants'),
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final ValueChanged<String?> onUpdateInstructions;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onUpdateInstructions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: cartItem.menuItem.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.menuItem.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  if (cartItem.selectedCustomizations.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ...cartItem.selectedCustomizations.entries.map((entry) {
                      return Text(
                        entry.value.join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      );
                    }).toList(),
                  ],

                  if (cartItem.specialInstructions?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${cartItem.specialInstructions}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (cartItem.quantity > 1) {
                                onQuantityChanged(cartItem.quantity - 1);
                              } else {
                                onRemove();
                              }
                            },
                            icon: Icon(
                              cartItem.quantity > 1 
                                  ? Icons.remove_circle_outline 
                                  : Icons.delete_outline,
                            ),
                            color: cartItem.quantity > 1 
                                ? theme.primaryColor 
                                : Colors.red,
                          ),

                          Text(
                            cartItem.quantity.toString(),
                            style: theme.textTheme.headlineSmall,
                          ),

                          IconButton(
                            onPressed: () {
                              onQuantityChanged(cartItem.quantity + 1);
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            color: theme.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        // Special instructions button
        TextButton.icon(
          onPressed: () {
            _showInstructionsDialog(context);
          },
          icon: const Icon(Icons.edit_note, size: 16),
          label: Text(
            cartItem.specialInstructions?.isNotEmpty == true 
                ? 'Edit instructions' 
                : 'Add instructions',
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 32),
          ),
        ),
      ],
    );
  }

  void _showInstructionsDialog(BuildContext context) {
    final controller = TextEditingController(text: cartItem.specialInstructions ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Special Instructions'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Any special requests for this item?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onUpdateInstructions(
                controller.text.isNotEmpty ? controller.text : null,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class OrderSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const OrderSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
                ? theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyLarge,
          ),
          Text(
            value,
            style: isTotal 
                ? theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  )
                : theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}