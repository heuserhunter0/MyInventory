import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs.map((doc) {
            final itemId = doc.id;
            final itemName = doc['name'];
            final itemQuantity = doc['quantity'];

            return ListTile(
              title: Text(itemName),
              subtitle: Text('Quantity: $itemQuantity'),
              // Tapping on the list item will navigate to the item details screen
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/item_details',
                  arguments: itemId,  // Pass the itemId to the details screen
                );
              },
              // Option to edit the item
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/edit_item',
                    arguments: itemId,  // Pass the itemId to the edit screen
                  );
                },
              ),
            );
          }).toList();

          return ListView(children: items);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_item');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}