import 'package:flutter/material.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
  
void main() { 
  runApp(const MyApp()); 
} 
  
class Item { 
  final String name; 
  final int quantity; 
  
  Item({required this.name, required this.quantity}); 
} 
  
class Inventory { 
  List<Item> items; 
  
  Inventory(this.items); 
  
  void addItem(Item item) { 
    items.add(item); 
  } 
  
  void editItem(int index, Item item) { 
    items[index] = item; 
  } 
  
  void deleteItem(int index) { 
    items.removeAt(index); 
  } 
} 
  
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override 
  Widget build(BuildContext context) { 
    return MaterialApp( 
      debugShowCheckedModeBanner: false, 
      title: 'My Inventory', 
      theme: ThemeData( 
        primarySwatch: Colors.green, 
      ), 
      home: const InventoryScreen(), 
    ); 
  } 
} 
  
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
 
  @override 
  // ignore: library_private_types_in_public_api
  _InventoryScreenState createState() => _InventoryScreenState(); 
} 
  
class _InventoryScreenState extends State<InventoryScreen> { 
  late Inventory inventory; 
  final itemNameController = TextEditingController(); 
  final quantityController = TextEditingController(); 
  
 int selectedIndex = -1; 
  
  @override 
  void initState() { 
    super.initState(); 
    loadInventory(); 
  } 
  
  Future<void> loadInventory() async { 
    final prefs = await SharedPreferences.getInstance(); 
    final items = prefs.getStringList('inventory') ?? []; 
    setState(() { 
      inventory = Inventory( 
        items.map((item) { 
          final parts = item.split(':'); 
          return Item(name: parts[0], quantity: int.parse(parts[1])); 
        }).toList(), 
      ); 
    }); 
  } 
  
  Future<void> saveInventory() async { 
    final prefs = await SharedPreferences.getInstance(); 
    final items = inventory.items.map((item) => '${item.name}:${item.quantity}').toList(); 
    prefs.setStringList('inventory', items); 
  } 
  
  void addItem() { 
    final name = itemNameController.text; 
    final quantity = int.tryParse(quantityController.text) ?? 0; 
  
    if (name.isNotEmpty && quantity > 0) { 
      setState(() { 
        inventory.addItem(Item(name: name, quantity: quantity)); 
        itemNameController.clear(); 
        quantityController.clear(); 
        saveInventory(); 
      }); 
    } 
  } 
  
  void editItem() { 
    final name = itemNameController.text; 
    final quantity = int.tryParse(quantityController.text) ?? 0; 
  
    if (name.isNotEmpty && quantity > 0) { 
      setState(() { 
        inventory.editItem(selectedIndex, Item(name: name, quantity: quantity)); 
        itemNameController.clear(); 
        quantityController.clear(); 
        saveInventory(); 
        selectedIndex = -1; 
      }); 
    } 
  } 
  
  void deleteItem(int index) { 
    setState(() { 
      inventory.deleteItem(index); 
      saveInventory(); 
    }); 
  } 
  
  void showEditDialog(int index) { 
    itemNameController.text = inventory.items[index].name; 
    quantityController.text = inventory.items[index].quantity.toString(); 
    selectedIndex = index; 
  
    showDialog( 
      context: context, 
      builder: (BuildContext context) { 
        return AlertDialog( 
          title: const Text('Edit Item'), 
          content: SingleChildScrollView( 
            child: Column( 
              children: [ 
                TextField( 
                  controller: itemNameController, 
                  decoration: const InputDecoration(labelText: 'Item Name'), 
                ), 
                TextField( 
                  controller: quantityController, 
                  keyboardType: TextInputType.number, 
                  decoration: const InputDecoration(labelText: 'Quantity'), 
                ), 
              ], 
            ), 
          ), 
          actions: [ 
            TextButton( 
              onPressed: () { 
                Navigator.of(context).pop(); 
              }, 
              child: const Text('Cancel'), 
            ), 
            ElevatedButton( 
              onPressed: () { 
                editItem(); 
                Navigator.of(context).pop(); 
              }, 
              child: const Text('Save'), 
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
        title: const Text('My Inventory'), 
      ), 
      body: Column( 
        children: [ 
          Expanded( 
            child: ListView.builder( 
              itemCount: inventory.items.length, 
              itemBuilder: (context, index) { 
                final item = inventory.items[index]; 
                return Card( 
                  child: ListTile( 
                    title: Text(item.name), 
                    subtitle: Text('Quantity: ${item.quantity}'), 
                    trailing: Row( 
                      mainAxisSize: MainAxisSize.min, 
                      children: [ 
                        IconButton( 
                          icon: const Icon(Icons.edit), 
                          onPressed: () { 
                            showEditDialog(index); 
                          }, 
                        ), 
                        IconButton( 
                          icon: const Icon(Icons.delete), 
                          onPressed: () { 
                            deleteItem(index); 
                          }, 
                        ), 
                      ], 
                    ), 
                  ), 
                ); 
              }, 
            ), 
          ), 
          Padding( 
            padding: const EdgeInsets.all(16.0), 
            child: Column( 
              children: [ 
                TextField( 
                  controller: itemNameController, 
                  decoration: const InputDecoration( 
                      
    border: OutlineInputBorder(), 
                     labelText: 'Item Name'), 
                ), 
                const SizedBox(height: 20), 
                TextField( 
                  controller: quantityController, 
                    
                  keyboardType: TextInputType.number, 
                  decoration: const InputDecoration( 
                    border: OutlineInputBorder(), 
                    labelText: 'Quantity'), 
                ), 
                const SizedBox(height: 16), 
                ElevatedButton( 
                  onPressed: selectedIndex == -1 ? addItem : editItem, 
                  child: Text(selectedIndex == -1 ? 'Add Item' : 'Save'), 
                ), 
              ], 
            ), 
          ), 
        ], 
      ), 
    ); 
  } 
} 