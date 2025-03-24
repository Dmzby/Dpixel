import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String _errorMessage = '';
  bool _isLoading = false;

  // Fungsi untuk mengirim email reset password
  Future<void> _sendResetEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear error message
    });

    try {
      String email = _emailController.text.trim();
      await _auth.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset password email sent to $email'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Kembali ke halaman login setelah reset email terkirim
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = 'Failed to send reset email: ${e.message}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Latar belakang hitam
      body: Stack(
        children: [
          // 🔹 Lingkaran Atas (Bertumpuk)
          Positioned(
            top: -70,
            left: -10,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[700]?.withOpacity(0.5), // Abu-abu gelap
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
                color: Colors.grey[500]?.withOpacity(0.5), // Abu-abu terang
              ),
            ),
          ),

          // 🔹 Lingkaran Bawah (Bertumpuk)
          Positioned(
            bottom: -295,
            right: -170,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[700]?.withOpacity(0.5), // Abu-abu gelap
              ),
            ),
          ),
          Positioned(
            bottom: -300,
            right: 10,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[500]?.withOpacity(0.5), // Abu-abu terang
              ),
            ),
          ),

          // 🔹 Tombol Kembali (Lingkaran Putih)
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Warna lingkaran tombol kembali
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black, // Ikon hitam agar kontras
                  size: 30,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // 🔹 Form Reset Password
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Image.asset(
  'assets/123.png',
  height: 150,
  color: Colors.white, // Mengubah warna logo menjadi putih
  colorBlendMode: BlendMode.srcIn, // Memastikan perubahan warna berlaku
),

                    const SizedBox(height: 20),

                    // 🔹 Input Email
                    Container(
                      width: 300,
                      child: TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintStyle: const TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          prefixIcon: const Icon(Icons.email, color: Colors.white),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Pesan Kesalahan
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 20),

                    // 🔹 Tombol Kirim Reset Email
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendResetEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Tombol putih
                        foregroundColor: Colors.black, // Teks hitam
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            )
                          : const Text('Send Reset Email'),
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
