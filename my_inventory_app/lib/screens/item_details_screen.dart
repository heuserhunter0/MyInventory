// ignore_for_file: prefer_const_constructors, use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailsScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late DocumentSnapshot item;
  int quantity = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
  }

  Future<void> _fetchItemDetails() async {
    final doc = await FirebaseFirestore.instance.collection('items').doc(widget.itemId).get();
    setState(() {
      item = doc;
      quantity = doc['quantity'];
      isLoading = false;
    });
  }

  Future<void> _updateQuantity() async {
    await FirebaseFirestore.instance
        .collection('items')
        .doc(widget.itemId)
        .update({'quantity': quantity});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Quantity updated successfully!'),
    ));
  }

  void _incrementQuantity() {
    setState(() {
      quantity += 1;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (quantity > 0) quantity -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['name'] ?? 'Item Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item Name: ${item['name']}', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 16),
                  Text('Current Quantity: $quantity', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: _decrementQuantity,
                      ),
                      Text('$quantity', style: TextStyle(fontSize: 24)),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updateQuantity,
                    child: Text('Save Quantity'),
                  ),
                ],
              ),
            ),
    );
  }
}