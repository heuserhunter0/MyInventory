// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  QRViewController? controller; // QR View controller to manage scanner
  String? qrCodeResult; // To store scanned QR code data

  // Widget options based on the bottom navigation selection
  // ignore: unused_field
  static const List<Widget> _widgetOptions = <Widget>[
    Text('Home Screen'),  
    Text('QR Scanner'),
  ]; 

  // Handle navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // If QR Scanner is selected, navigate to the QR scanning functionality
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QRViewExample()),
      );
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: signOut,
          ),
        ]
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
            return ListTile(
              title: Text(doc['name']),
              subtitle: Text('Quantity: ${doc['quantity']}'),
              onTap: () {
                Navigator.pushNamed(context, '/item_details', arguments: doc.id);
              },
            );
          }).toList();

          return ListView(children: items);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_item'); // Navigate to the Add Item page
        },
        child: Icon(Icons.add),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// QRViewExample Screen for QR Scanning
class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrCodeResult;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (qrCodeResult != null)
                  ? Text('Scanned QR Code: $qrCodeResult')
                  : Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

void _onQRViewCreated(QRViewController controller) {
  this.controller = controller;
  controller.scannedDataStream.listen((scanData) async {
    final qrCodeResult = scanData.code;

    if (qrCodeResult != null) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('qrCode', isEqualTo: qrCodeResult)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var itemDoc = querySnapshot.docs.first;

        // Navigate directly to item details screen after a successful scan
        Navigator.pushNamed(
          context,
          '/item_details',
          arguments: itemDoc.id,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Item not found!'),
        ));
      }
    }
  });
}

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}