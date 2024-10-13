// lib/models/item.dart
class Item {
  final String id;
  final String name;
  int quantity;

  Item({required this.id, required this.name, required this.quantity});

  // Convert item data to a string to encode in the QR code
  String toQrData() {
    return '{"id": "$id", "name": "$name", "quantity": $quantity}';
  }
}