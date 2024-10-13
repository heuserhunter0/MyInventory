 // ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api

 import 'package:flutter/material.dart';
import 'package:my_inventory_app/screens/add_item_screen.dart';
import 'package:my_inventory_app/screens/edit_item_screen.dart';
import 'package:my_inventory_app/screens/item_details_screen.dart';
import 'package:my_inventory_app/models/item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This would be a list fetched from your database or stored locally
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    // TODO: Fetch items from Firebase or local storage
    // For now, we're just using mock data.
    items = [
      Item(name: 'Item 1', quantity: 10, id: ''),
      Item(name: 'Item 2', quantity: 5, id: ''),
      // Add more mock items or fetch them from Firebase
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Inventory'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  onTap: () {
                    // Navigate to item details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailsScreen(item: item),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to edit item screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditItemScreen(item: item),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to add item screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItemScreen()),
                );
              },
              child: Text('Add New Item'),
            ),
          ),
        ],
      ),
    );
  }
}