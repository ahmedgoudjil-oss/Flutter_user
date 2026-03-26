// State notifier for delivered order count
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/controllers/order_controller.dart';

class DeliveredOrderCountProvider extends StateNotifier<int> {
  DeliveredOrderCountProvider() : super(0);

  // Method to fetch delivered orders count
  Future<void> fetchDeliveredOrderCount(String buyerId) async {
    try {
      // Create an instance of the Order controller class
      final OrderController orderController = OrderController();
      
      // Get delivered count
      final int count = await orderController.getDeliveredCount(buyerId);
      
      // Update the state with the count
      state = count;
    } catch (e) {
      // Quick note update the state with the count
      // Error handling - could show snackbar if needed
      print('Error fetching delivered order count: $e');
    }
  }

  // Method to reset the count
  void resetCount() {
    state = 0;
  }
}

// Expose the instance of this class so that we can use it within our application
final deliveredOrderCountProvider = StateNotifierProvider<DeliveredOrderCountProvider, int>(
  (ref) => DeliveredOrderCountProvider(),
); 