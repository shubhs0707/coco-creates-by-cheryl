import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  @override
  Widget build(BuildContext context) {
    // final orderData=Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      drawer: AppDrawer(),
      body: Consumer<Orders>(
        builder: (context, ordersData, child) {
          if (ordersData.orders.isEmpty) {
            return Center(child: Text('No Orders found!'));
          }
          return ListView.builder(
            itemCount: ordersData.orders.length,
            itemBuilder: (context, index) =>
                OrderItem(ordersData.orders[index]),
          );
        },
      ),
    );
  }
}
