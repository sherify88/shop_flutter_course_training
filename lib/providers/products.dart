import 'package:flutter/material.dart';
import 'package:shop_flutter_app/models/http_exception.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [];
   String? authToken;
   String? userId;
  Products.plain();
  Products(this.authToken,this._items,this.userId);
  List<Product> get items {
    return [..._items];
  }


  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false ]) async {
   final  filterString = filterByUser? "orderBy=\"creatorId\"&equalTo=\"$userId\"" : "";
    var url = Uri.parse(
        "https://flutter-update-f4868-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString");
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData==null){
        return;
      }
       url = Uri.parse(
          "https://flutter-update-f4868-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken");
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            isFavorite: favoriteData==null? false: favoriteData[prodId]?? false ,
            title: prodData["title"],
            description: prodData["description"],
            price: prodData["price"],
            imageUrl: prodData["imageUrl"]));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.parse(
        "https://flutter-update-f4868-default-rtdb.firebaseio.com/products.json?auth=$authToken");

    try {
      final response = await http.post(url,
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "price": product.price,
            "creatorId": userId,
          }));
      final newProduct = Product(
          id: json.decode(response.body)["name"],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _items.add(newProduct);
      print(response.body);

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    final url = Uri.parse(
        "https://flutter-update-f4868-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken");
    await http.patch(url,
        body: json.encode({
          "title": updatedProduct.title,
          "description": updatedProduct.description,
          "price": updatedProduct.price,
          "imageUrl": updatedProduct.imageUrl,
        }));
    final productIndex = _items.indexWhere((element) => element.id == id);
    _items[productIndex] = updatedProduct;
    notifyListeners();
  }

   Future<void> deleteProduct(String id)async {
    final url = Uri.parse(
        "https://flutter-update-f4868-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken");
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    await  http.delete(url).then((value) {
      if(value.statusCode>=400){
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException("Could not delete product.");

      }
      existingProduct=null as Product;

    });
  }
}
