import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.description,
    @required this.id,
    @required this.imageUrl,
    this.isFavourite = false,
    @required this.price,
    @required this.title,
  });

  void _setfavValue(bool newValue) {
    isFavourite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavouriteStatus(String token, String userId) async {
    final url =
        'https://coco-creates.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();

    try {
      final response = await http.put(
        url,
        body: json.encode(isFavourite),
      );
      notifyListeners();
      if (response.statusCode >= 400) {
        _setfavValue(oldStatus);
        throw HttpException('Network Problem Probably');
      }
    } catch (error) {
      _setfavValue(oldStatus);
    }
  }
}
