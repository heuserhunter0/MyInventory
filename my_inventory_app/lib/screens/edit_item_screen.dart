import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditItemScreen extends StatefulWidget {
  final String itemId;

  EditItemScreen({required this.itemId});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String itemName = '';
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('items')
        .doc(widget.itemId)
        .get();
    setState(() {
      itemName = doc['name'];
      quantity = doc['quantity'];
    });
  }

  Future<void> _editItemInFirestore(String name, int quantity) async {
    try {
      await FirebaseFirestore.instance.collection('items').doc(widget.itemId).update({
        'name': name,
        'quantity': quantity,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Item updated successfully!'),
      ));
    } catch (e) {
      print('Error updating item: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update item'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: itemName,
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
                initialValue: quantity.toString(),
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
                    _editItemInFirestore(itemName, quantity);
                    Navigator.pop(context); // Go back after editing
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}