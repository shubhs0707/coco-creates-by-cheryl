import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './cart.dart';

class OrderItem {
  final String id;
  final int amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.amount,
      @required this.dateTime,
      @required this.id,
      @required this.products});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, int total) async {
    final url =
        'https://coco-creates.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList(),
        }));

    _orders.insert(
      0,
      OrderItem(
        amount: total,
        dateTime: timestamp,
        id: json.decode(response.body)['name'],
        products: cartProducts,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://coco-creates.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      _orders = [];
      notifyListeners();
      return;
    }
    final List<OrderItem> loadedOrders = [];
    extractedData.forEach((key, value) {
      loadedOrders.add(
        OrderItem(
          amount: value['amount'],
          dateTime: DateTime.parse(value['dateTime']),
          id: key,
          products: (value['products'] as List<dynamic>)
              .map(
                (e) => CartItem(
                  id: e['id'],
                  price: e['price'],
                  quantity: e['quantity'],
                  title: e['title'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
