// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:my_inventory_app/models/item.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Item item;

  ItemDetailsScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${item.name} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              item.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Quantity: ${item.quantity}'),
            SizedBox(height: 20),
            QrImageView(
              data: item.name,  // Replace with actual data you want to encode
              size: 200,
            ),
          ],
        ),
      ),
    );
  }
}