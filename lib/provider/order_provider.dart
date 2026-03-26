import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/order.dart';

class OrderProvider extends StateNotifier<List<Order>> {
  OrderProvider() : super([]);

  void setOrders(List<Order> orders) {
    state = orders;
  }

  void clearOrders() {
    state = [];
  }
  //remove an order by id
  void removeOrderById(String id) { 
    state = state.where((order) => order.id != id).toList();
  }
  
}

// ✅ يجب أن يكون هذا خارج الكلاس
final orderProvider = StateNotifierProvider<OrderProvider, List<Order>>(
  (ref) => OrderProvider(),
);