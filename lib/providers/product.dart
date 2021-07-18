import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier{
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
   this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
     this.isFavorite = false   ,
  });

  Future<void> toggleFavoriteStatus(String authToken, String userId)async{
   var favorite;
    favorite= isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
        "https://flutter-update-f4868-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken");
    try {
    final response=   await http.put(url,
          body: json.encode(
            isFavorite
          ));
    if(response.statusCode>=400){
      print("4442");
      isFavorite = favorite;
      notifyListeners();
    }
    //  favorite=null as boo(l;
    }catch (error){
      print("4442"+ error.toString());
      isFavorite = favorite;
      notifyListeners();
    }
  }
}
