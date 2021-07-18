import 'package:flutter/material.dart';
import 'package:shop_flutter_app/providers/auth.dart';
import 'package:shop_flutter_app/providers/cart.dart';
import 'package:shop_flutter_app/providers/orders.dart';
import 'package:shop_flutter_app/screens/auth_screen.dart';
import 'package:shop_flutter_app/screens/cart_screen.dart';
import 'package:shop_flutter_app/screens/edit_product_screen.dart';
import 'package:shop_flutter_app/screens/orders_screen.dart';
import 'package:shop_flutter_app/screens/product_detail_screen.dart';
import 'package:shop_flutter_app/screens/products_overview_screen.dart';
import 'package:shop_flutter_app/screens/splash_screen.dart';
import 'package:shop_flutter_app/screens/user_products_screen.dart';
import 'package:shop_flutter_app/widgets/user_product_item.dart';
import 'providers/products.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products.plain(),
          update: (BuildContext context, auth, Products? previous) =>
              Products(
                auth.token,
                previous == null ? [] : previous.items, auth.userId,
              ),
        ),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders.plain(),
          update: (BuildContext context, auth, Orders? previous) =>
              Orders(
                auth.token,
                previous == null ? [] : previous.orders, auth.userId,
              ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) =>
            MaterialApp(
                title: 'MyShop',
                theme: ThemeData(
                  primarySwatch: Colors.purple,
                  accentColor: Colors.deepOrange,
                  fontFamily: 'Lato',
                ),
                home: auth.isAuth ? ProductOverviewScreen() : FutureBuilder(
                  builder: (ctx, authResultSnapshot) => authResultSnapshot
                      .connectionState == ConnectionState.waiting?  SplashScreen() : AuthScreen(),
                  future: auth.tryAutoLogin(),),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
          UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
        },
      ),
    ),);
  }
}
