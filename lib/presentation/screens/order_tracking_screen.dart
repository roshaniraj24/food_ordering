import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../../data/models/models.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Load order details
    context.read<OrderBloc>().add(LoadOrder(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderBloc>().add(RefreshOrder(widget.orderId));
            },
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const LoadingWidget(message: 'Loading order details...');
          } else if (state is OrderError) {
            return ErrorWidgetCustom(
              message: state.failure.message,
              onRetry: () {
                context.read<OrderBloc>().add(LoadOrder(widget.orderId));
              },
            );
          } else if (state is OrderLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrderBloc>().add(RefreshOrder(widget.orderId));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order status card
                    _buildOrderStatusCard(state.order),
                    
                    const SizedBox(height: 16),
                    
                    // Order progress
                    _buildOrderProgress(state.order),
                    
                    const SizedBox(height: 16),
                    
                    // Restaurant info
                    _buildRestaurantInfo(state.order),
                    
                    const SizedBox(height: 16),
                    
                    // Order details
                    _buildOrderDetails(state.order),
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    _buildActionButtons(context, state.order),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderStatusCard(Order order) {
    final statusInfo = _getOrderStatusInfo(order.status);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              statusInfo.icon,
              size: 48,
              color: statusInfo.color,
            ),
            const SizedBox(height: 12),
            Text(
              statusInfo.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusInfo.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              statusInfo.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (order.estimatedDeliveryTime != null && 
                order.status != OrderStatus.delivered &&
                order.status != OrderStatus.cancelled) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Estimated delivery: ${_formatTime(order.estimatedDeliveryTime!)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderProgress(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Progress',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...OrderStatus.values.where((status) => status != OrderStatus.cancelled)
                .map((status) {
              final isCompleted = _isStatusCompleted(status, order.status);
              final isCurrent = status == order.status;
              
              return _buildProgressStep(
                title: _getStatusTitle(status),
                subtitle: _getStatusSubtitle(status),
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLast: status == OrderStatus.delivered,
              );
            }).toList(),
            
            if (order.status == OrderStatus.cancelled) ...[
              _buildProgressStep(
                title: 'Order Cancelled',
                subtitle: 'Your order has been cancelled',
                isCompleted: false,
                isCurrent: true,
                isLast: true,
                color: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    Color? color,
  }) {
    final stepColor = color ?? (isCompleted || isCurrent 
        ? Theme.of(context).primaryColor 
        : Colors.grey.shade400);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? stepColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: stepColor, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : (isCurrent 
                      ? Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: stepColor,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null),
            ),
            if (!isLast) ...[
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? stepColor : Colors.grey.shade300,
              ),
            ],
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? stepColor : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                if (!isLast) const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantInfo(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.restaurant, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.restaurant.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    order.restaurant.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // Show restaurant contact options
                _showRestaurantContact(context, order.restaurant);
              },
              child: const Text('Contact'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Text('Order ID: ${order.id.substring(0, 8).toUpperCase()}'),
            if (order.trackingId != null)
              Text('Tracking ID: ${order.trackingId}'),
            Text('Order Time: ${_formatDateTime(order.orderTime)}'),
            Text('Payment: ${_getPaymentMethodName(order.paymentMethod)}'),
            Text('Total: \$${order.total.toStringAsFixed(2)}'),
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            
            Text(
              'Items (${order.totalItems})',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text('${item.quantity}x'),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.menuItem.name)),
                    Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
    return Column(
      children: [
        if (order.status != OrderStatus.delivered && 
            order.status != OrderStatus.cancelled &&
            order.status != OrderStatus.outForDelivery) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showCancelOrderDialog(context, order);
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showOrderSummary(context, order);
            },
            icon: const Icon(Icons.receipt),
            label: const Text('View Order Summary'),
          ),
        ),
      ],
    );
  }

  OrderStatusInfo _getOrderStatusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return OrderStatusInfo(
          icon: Icons.hourglass_empty,
          color: Colors.orange,
          title: 'Order Pending',
          subtitle: 'Waiting for restaurant confirmation',
        );
      case OrderStatus.confirmed:
        return OrderStatusInfo(
          icon: Icons.check_circle_outline,
          color: Colors.blue,
          title: 'Order Confirmed',
          subtitle: 'Your order has been confirmed by the restaurant',
        );
      case OrderStatus.preparing:
        return OrderStatusInfo(
          icon: Icons.restaurant,
          color: Colors.orange,
          title: 'Preparing',
          subtitle: 'The restaurant is preparing your order',
        );
      case OrderStatus.ready:
        return OrderStatusInfo(
          icon: Icons.done_all,
          color: Colors.green,
          title: 'Ready for Pickup',
          subtitle: 'Your order is ready and will be picked up soon',
        );
      case OrderStatus.outForDelivery:
        return OrderStatusInfo(
          icon: Icons.delivery_dining,
          color: Colors.blue,
          title: 'Out for Delivery',
          subtitle: 'Your order is on the way!',
        );
      case OrderStatus.delivered:
        return OrderStatusInfo(
          icon: Icons.celebration,
          color: Colors.green,
          title: 'Delivered',
          subtitle: 'Your order has been delivered. Enjoy your meal!',
        );
      case OrderStatus.cancelled:
        return OrderStatusInfo(
          icon: Icons.cancel,
          color: Colors.red,
          title: 'Order Cancelled',
          subtitle: 'Your order has been cancelled',
        );
    }
  }

  bool _isStatusCompleted(OrderStatus checkStatus, OrderStatus currentStatus) {
    final statusOrder = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];
    
    final checkIndex = statusOrder.indexOf(checkStatus);
    final currentIndex = statusOrder.indexOf(currentStatus);
    
    return checkIndex <= currentIndex;
  }

  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getStatusSubtitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Your order has been placed';
      case OrderStatus.confirmed:
        return 'Restaurant confirmed your order';
      case OrderStatus.preparing:
        return 'Your food is being prepared';
      case OrderStatus.ready:
        return 'Order is ready for pickup';
      case OrderStatus.outForDelivery:
        return 'Driver is on the way';
      case OrderStatus.delivered:
        return 'Order delivered successfully';
      case OrderStatus.cancelled:
        return 'Order was cancelled';
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.cash:
        return 'Cash on Delivery';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.wallet:
        return 'Digital Wallet';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }

  void _showCancelOrderDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(CancelOrder(order.id));
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRestaurantContact(BuildContext context, Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact ${restaurant.name}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Restaurant'),
              subtitle: const Text('+1 (555) 987-6543'),
              onTap: () {
                Navigator.pop(context);
                // Handle phone call
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat with Restaurant'),
              subtitle: const Text('Send a message'),
              onTap: () {
                Navigator.pop(context);
                // Handle chat
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderSummary(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...order.items.map((item) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Text('${item.quantity}x'),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.menuItem.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    if (item.selectedCustomizations.isNotEmpty) ...[
                                      Text(
                                        item.selectedCustomizations.values
                                            .expand((list) => list)
                                            .join(', '),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 16),
                    
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal'),
                                Text('\$${order.subtotal.toStringAsFixed(2)}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Delivery Fee'),
                                Text('\$${order.deliveryFee.toStringAsFixed(2)}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tax'),
                                Text('\$${order.tax.toStringAsFixed(2)}'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${order.total.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderStatusInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  OrderStatusInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}