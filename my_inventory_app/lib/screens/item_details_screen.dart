// ignore_for_file: prefer_const_constructors, use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailsScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  DocumentSnapshot? item; // Nullable to handle loading state
  int quantity = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
  }

  Future<void> _fetchItemDetails() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('items').doc(widget.itemId).get();
      setState(() {
        item = doc;
        quantity = doc['quantity'];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching item details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  
Future<void> updateItem(String itemId, String newName, int newQuantity) async {
  // Get the reference to the Firestore document
  DocumentReference docRef = FirebaseFirestore.instance.collection('items').doc(itemId);

  // Update the item details (name and quantity)
  await docRef.update({
    'name': newName,
    'quantity': newQuantity,
  });

  // Update the qrCode field with the document ID (or use another unique value)
  String qrCodeData = docRef.id; // This is the document ID (you can also use custom values if needed)
  await docRef.update({
    'qrCode': qrCodeData,
  });

  print("Item updated with QR code: $qrCodeData");
}
  Future<void> _deleteItem() async {
    await FirebaseFirestore.instance.collection('items').doc(widget.itemId).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Item deleted successfully!'),
    ));
    Navigator.pop(context); // Navigate back to the previous screen
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _deleteItem(); // Perform delete
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item != null ? (item!['name'] ?? 'Item Details') : 'Loading...'),
        actions: [
          if (item != null)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : item == null
              ? Center(child: Text('Failed to load item details.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Item Name: ${item!['name']}', style: TextStyle(fontSize: 24)),
                      SizedBox(height: 16),
                      Text('Current Quantity: $quantity', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (quantity > 0) quantity -= 1;
                              });
                            },
                          ),
                          Text('$quantity', style: TextStyle(fontSize: 24)),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                quantity += 1;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('items')
                              .doc(widget.itemId)
                              .update({'quantity': quantity});
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Quantity updated successfully!'),
                          ));
                        },
                        child: Text('Save Quantity'),
                      ),
                      SizedBox(height: 32),
                      // QR Code Section
                      Center(
                        child: Column(
                          children: [
                            Text('QR Code for this Item', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 16),
                            QrImageView(
                              data: widget.itemId, // Using the item ID as QR code data
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}