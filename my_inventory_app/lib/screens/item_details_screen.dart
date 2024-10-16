import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ItemDetailsScreen extends StatelessWidget {
  final String itemId;

  ItemDetailsScreen({required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('items').doc(itemId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var itemData = snapshot.data!.data() as Map<String, dynamic>;
          String itemName = itemData['name'];
          int itemQuantity = itemData['quantity'];

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Item Name: $itemName', style: TextStyle(fontSize: 22)),
                SizedBox(height: 10),
                Text('Quantity: $itemQuantity', style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),

                // QR Code generation section
                Center(
                  child: QrImageView(
                    data: itemId,  // You can change this to itemName or any unique data
                    version: QrVersions.auto,
                    size: 200.0,  // Size of the QR code
                    gapless: false,
                  ),
                ),

                SizedBox(height: 20),
                Text('Scan this QR code to quickly access the item.', style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}