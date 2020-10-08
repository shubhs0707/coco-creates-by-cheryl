import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    description: '',
    id: null,
    imageUrl: '',
    price: 0,
    title: '',
  );
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (
          // _imageUrlController.text.isEmpty ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https'))
          // || (!_imageUrlController.text.endsWith('png') &&
          //     !_imageUrlController.text.endsWith('jpg') &&
          //     !_imageUrlController.text.endsWith('jpeg'))
          ) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    // print(_editedProduct.description);
    // print(_editedProduct.id);
    // print(_editedProduct.imageUrl);
    // print(_editedProduct.price);
    // print(_editedProduct.title);
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
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
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      initialValue: _editedProduct.title,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          description: _editedProduct.description,
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          imageUrl: _editedProduct.imageUrl,
                          price: _editedProduct.price,
                          title: value,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Price'),
                      initialValue: _editedProduct.price.toString(),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) <= 0) {
                          return "Please enter a number greater than zero";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          description: _editedProduct.description,
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          imageUrl: _editedProduct.imageUrl,
                          price: int.parse(value),
                          title: _editedProduct.title,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      initialValue: _editedProduct.description,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Enter a description";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          description: value,
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          imageUrl: _editedProduct.imageUrl,
                          price: _editedProduct.price,
                          title: _editedProduct.title,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Center(
                                  child: Text(
                                    'Enter a URL',
                                  ),
                                )
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            // initialValue: _editedProduct.imageUrl,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            focusNode: _imageUrlFocusNode,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter an image URL";
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return "Please enter a valid URL";
                              }
                              // if (!value.endsWith('png') &&
                              //     !value.endsWith('jpg') &&
                              //     !value.endsWith('jpeg')) {
                              //   return "Please enter a valid URL";
                              // }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                description: _editedProduct.description,
                                id: _editedProduct.id,
                                isFavourite: _editedProduct.isFavourite,
                                imageUrl: value,
                                price: _editedProduct.price,
                                title: _editedProduct.title,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
