import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mpr_admin/screens/scanqr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instance firebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Data user
  String name = '';
  String uid = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
  }

  // Get current user data
  void getCurrentUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        uid = user.uid;

        DocumentSnapshot userDocSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDocSnapshot.exists) {
          Map<String, dynamic> userData =
              userDocSnapshot.data() as Map<String, dynamic>;
          setState(() {
            role = userData['role'];
            name = userData['name'];
          });
        } else {
          _showSnackBarIfError('Dokumen tidak ditemukan');
        }
      }
    } catch (error) {
      _showSnackBarIfError('Terjadi kesalahan: $error');
    }
  }

  // Signout logic
  Future<void> _logoutWithEmailAndPassword() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      _showSnackBarIfError(e.code);
    }
  }

  // Snackbar popup
  void _showSnackBarIfError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        actions: [
          IconButton(
            onPressed: _logoutWithEmailAndPassword,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(10)),
                      child: Image.asset(
                        'assets/images/mpr_logo_3.png',
                        width: 70,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi $name',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Mari kerja hari ini!',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 45),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ScanQRScreen(
                                  id: uid,
                                  name: name,
                                )));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 4.5,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/exchange.png',
                              height: 30,
                              width: 30,
                            ),
                            const SizedBox(height: 10),
                            const Text('Penukaran'),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 4.5,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/celsius.png',
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(height: 10),
                          const Text('Temperatur'),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 4.5,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/humidity.png',
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(height: 10),
                          const Text('Kelembaban'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 45),
                const Text(
                  'Terima kasih kamu sudah berkontribusi atas kebersihan lingkungan sekitar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
