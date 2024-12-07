// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, prefer_const_constructors_in_immutables

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; // For sharing files
import 'package:csv/csv.dart';
import 'organization_code_screen.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currentOrgId; // To store the organization ID
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrgId(); // Fetch organization ID when the screen is initialized
  }

  Future<void> _fetchOrgId() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          _currentOrgId = userDoc['orgId']; // Set the organization ID
        });
      }
    } catch (e) {
      print('Error fetching organization ID: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      if (_currentOrgId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Organization not loaded. Please wait.'),
        ));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRViewExample(orgId: _currentOrgId),
          ),
        ).then((_) {
          // Reset selected index after returning
          setState(() {
            _selectedIndex = 0;
          });
        });
      }
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrganizationCodeScreen()),
      ).then((_) {
        // Reset selected index after returning
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _exportToCsv() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('orgId', isEqualTo: _currentOrgId)
          .get();

      // Convert items to CSV rows
      List<List<String>> csvData = [
        ['Item Name', 'Quantity', 'QR Code'] // Header row
      ];
      for (var doc in querySnapshot.docs) {
        csvData.add([
          doc['name'],
          doc['quantity'].toString(),
          doc['qrCode'] ?? 'N/A',
        ]);
      }

      // Generate CSV file content
      String csv = const ListToCsvConverter().convert(csvData);

      // Save CSV file to temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/items.csv';
      final file = File(filePath);
      await file.writeAsString(csv);

      // Share the file
      await Share.shareFiles([filePath], text: 'Exported Items');
    } catch (e) {
      print('Error exporting CSV: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to export CSV'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportToCsv, // Export CSV functionality
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: signOut,
          ),
        ],
      ),
      body: _currentOrgId == null
          ? Center(child: CircularProgressIndicator()) // Show a loader while fetching the orgId
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .where('orgId', isEqualTo: _currentOrgId) // Filter by organization
                  .snapshots(),
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
          Navigator.pushNamed(context, '/add_item');
        },
        child: Icon(Icons.add),
      ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Org Code',
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
  final String? orgId;
  QRViewExample({this.orgId});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _scanning = false; // To prevent multiple scans

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
              child: Text(
                'Scan a QR Code',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (!_scanning && scanData.code != null) {
        _scanning = true; // Mark as scanning to prevent duplicates
        await controller.pauseCamera();

        final qrCodeResult = scanData.code;
        final querySnapshot = await FirebaseFirestore.instance
            .collection('items')
            .where('qrCode', isEqualTo: qrCodeResult)
            .where('orgId', isEqualTo: widget.orgId) // Match orgId
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final itemDoc = querySnapshot.docs.first;

          // Navigate to item details and reset camera after returning
          await Navigator.pushNamed(
            context,
            '/item_details',
            arguments: itemDoc.id,
          );

          await controller.resumeCamera(); // Reset camera after returning
          _scanning = false; // Allow next scan
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Item not found!'),
          ));

          await controller.resumeCamera(); // Resume camera for next scan
          _scanning = false; // Allow next scan
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