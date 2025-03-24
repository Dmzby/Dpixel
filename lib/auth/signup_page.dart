import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../loading_screen.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String _errorMessage = '';

  // Fungsi untuk sign up
  Future<void> _signUp() async {
    try {
      String username = _usernameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // Membuat akun baru dengan email dan password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Menyimpan data pengguna ke Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'username': username,
        'email': email,
      });

      // Setelah berhasil signup, arahkan ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Signup failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Latar belakang hitam
      body: Stack(
        children: [
          // Lingkaran atas
          Positioned(
            top: -70,
            left: -10,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[700]?.withOpacity(0.5), // Warna abu-abu tua
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: -90,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[500]?.withOpacity(0.5), // Warna abu-abu tua
              ),
            ),
          ),
          // Lingkaran bawah
          Positioned(
            bottom: -350,
            right: -170,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[700]?.withOpacity(0.5), // Warna abu-abu tua
              ),
            ),
          ),
          Positioned(
            bottom: -350,
            right: 10,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[500]?.withOpacity(0.5), // Warna abu-abu tua
              ),
            ),
          ),
          // Konten SignUp
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Image.asset('assets/123.png', height: 150, color: Colors.white),
                    const SizedBox(height: 20),

                    // Kolom input
                    Container(
                      width: 300, // Membatasi lebar kolom input
                      child: Column(
                        children: <Widget>[
                          // Username input field
                          TextField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Enter your username',
                              labelStyle: const TextStyle(color: Colors.white),
                              hintStyle: const TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              prefixIcon: const Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email input field
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              labelStyle: const TextStyle(color: Colors.white),
                              hintStyle: const TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              prefixIcon: const Icon(Icons.email, color: Colors.white),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),

                          // Password input field
                          TextField(
                            controller: _passwordController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              labelStyle: const TextStyle(color: Colors.white),
                              hintStyle: const TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              prefixIcon: const Icon(Icons.lock, color: Colors.white),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Tampilkan pesan kesalahan jika ada
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 20),

                    // Tombol sign up
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Warna putih
                        foregroundColor: Colors.black, // Teks hitam
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: _signUp,
                      child: const Text('Sign Up'),
                    ),
                    const SizedBox(height: 20),

                    // Tombol untuk beralih ke halaman login
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoadingScreen()),
                        ).then((_) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        });
                      },
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
