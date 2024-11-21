// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, unused_local_variable, use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterScreen extends StatefulWidget {
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _orgCodeController = TextEditingController();
  String? _errorMessage;
  bool _isCreatingOrg = false; // Flag to toggle between options

  Future<void> _register() async {
    try {
      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final userId = userCredential.user!.uid;

      if (_isCreatingOrg) {
        // Create a new organization
        DocumentReference orgRef = await FirebaseFirestore.instance.collection('organizations').add({
          'name': 'Organization for ${_emailController.text}',
          'createdBy': userId,
        });
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'orgId': orgRef.id,
          'email': _emailController.text,
        });
      } else {
        // Join an existing organization
        final orgCode = _orgCodeController.text.trim();
        final orgSnapshot = await FirebaseFirestore.instance
            .collection('organizations')
            .doc(orgCode)
            .get();

        if (!orgSnapshot.exists) {
          throw Exception('Organization code not found.');
        }

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'orgId': orgCode,
          'email': _emailController.text,
        });
      }

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            if (_isCreatingOrg)
              TextField(
                decoration: InputDecoration(labelText: 'Organization Name'),
              )
            else
              TextField(
                controller: _orgCodeController,
                decoration: InputDecoration(labelText: 'Organization Code'),
              ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isCreatingOrg = true;
                    });
                  },
                  child: Text('Create Organization'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isCreatingOrg = false;
                    });
                  },
                  child: Text('Join Organization'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}