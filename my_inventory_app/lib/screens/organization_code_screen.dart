// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // For Clipboard functionality

class OrganizationCodeScreen extends StatefulWidget {
  @override
  _OrganizationCodeScreenState createState() => _OrganizationCodeScreenState();
}

class _OrganizationCodeScreenState extends State<OrganizationCodeScreen> {
  String? _orgId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrgId();
  }

  Future<void> _fetchOrgId() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          _orgId = userDoc['orgId'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching organization code: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load organization code'),
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organization Code'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Organization Code:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _orgId ?? 'N/A',
                          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy),
                        tooltip: 'Copy Organization Code',
                        onPressed: () {
                          if (_orgId != null) {
                            Clipboard.setData(ClipboardData(text: _orgId!));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Organization code copied to clipboard!'),
                            ));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}