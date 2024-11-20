// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, duplicate_ignore, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String itemName = '';
  int quantity = 0;

  Future<void> _addItemToFirestore(String name, int quantity) async {
    try {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('items').add({
        'name': name,
        'quantity': quantity,
        'createdAt': Timestamp.now(),
      });
      String qrCodeData = docRef.id;
      await docRef.update({'qrCode': qrCodeData});
      // ignore: prefer_const_constructors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Item added successfully!'),
      ));
    } catch (e) {
      print('Error adding item: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add item'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
                onSaved: (value) {
                  itemName = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  return null;
                },
                onSaved: (value) {
                  quantity = int.parse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _addItemToFirestore(itemName, quantity);
                    Navigator.pop(context); // Go back to home screen after saving
                  }
                },
                child: Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}