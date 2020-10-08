import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../providers/products.dart';

enum FilterOptions {
  Favourites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFavourites = false;
  var _isLoading = false;
  // var _isInit = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .catchError((error) {
      showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred'),
          content: Text('Something went wrong :('),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('OK'))
          ],
        ),
      );
    }).then((value) {
      setState(() {
        _isLoading = false;
      });
    });
    // Future.delayed(Duration.zero).then((value) {
    //   Provider.of<Products>(context, listen: false).fetchAndSetProducts();
    // });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (_isInit) {
  //     Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  //   }
  //   _isInit = false;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Coco Creates by Cheryl',
          softWrap: true,
          overflow: TextOverflow.fade,
          // textScaleFactor: ,
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favourites'),
                value: FilterOptions.Favourites,
              ),
              PopupMenuItem(
                child: Text('Show all'),
                value: FilterOptions.All,
              ),
            ],
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favourites) {
                  _showOnlyFavourites = true;
                } else {
                  _showOnlyFavourites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
              builder: (ctx, cart, ch) => Badge(
                    child: ch,
                    value: cart.itemCount.toString(),
                  ),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              )),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavourites),
    );
  }
}
