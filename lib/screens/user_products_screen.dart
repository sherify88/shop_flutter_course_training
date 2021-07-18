import 'package:flutter/material.dart';
import 'package:shop_flutter_app/widgets/app_drawer.dart';
import 'package:shop_flutter_app/widgets/user_product_item.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user_products";
  Future<void> refreshProducts(BuildContext context)async{
    await Provider.of<Products>(context,listen: false).fetchAndSetProducts(true);
  }
  @override
  Widget build(BuildContext context) {
   // final productsData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Products"),
        // added const to not rebuild when provider calls
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            // added const to not rebuild when provider calls
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);

            },
          ),
        ],
      ),
      body: FutureBuilder(future: refreshProducts(context),
        builder: (ctx, snapshot)=> snapshot.connectionState==ConnectionState.waiting? Center(child: CircularProgressIndicator(),): RefreshIndicator(
          onRefresh: () => refreshProducts(context),
          child:
          Consumer<Products>(
            builder: (ctx,productsData,_ )=> Padding(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                  itemBuilder: (_, i) => Column(children: [UserProductItem(
                  productsData.items[i].id!,productsData.items[i].title, productsData.items[i].imageUrl),Divider(),],),
                  itemCount: productsData.items.length),
            ),
          ),
        ),
      ),drawer: AppDrawer(),
    );
  }
}
