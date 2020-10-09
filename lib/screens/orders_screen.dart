// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;
  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  // var _isLoading = false;

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();

    // _isLoading = true;
    // Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then(
    //       (_) => setState(() {
    //         _isLoading = false;
    //       }),
    //     );
  }

  @override
  Widget build(BuildContext context) {
    print('building orders');
    // final orderData=Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error != null) {
              return SnackBar(content: Text('Something went wrong'));
            } else {
              return Consumer<Orders>(
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
              );
            }
          }
        },
      ),
    );
  }
}
