import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_page.dart';
import 'screen/home_page.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();

    // Animasi untuk efek fade-in pada logo
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Mengecek status login setelah beberapa detik
    _checkLoginStatus();
  }

  // Fungsi untuk memeriksa status login
  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3)); // Perpanjang durasi sedikit

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Tema hitam
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Efek Fade-in pada Logo
            FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                'assets/123.png',
                width: 150,
                height: 150,
                color: Colors.white, // Warna putih untuk logo
              ),
            ),
            SizedBox(height: 30),

            // Animasi titik berjalan
            DotsLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Widget untuk animasi titik berjalan
class DotsLoadingIndicator extends StatefulWidget {
  @override
  _DotsLoadingIndicatorState createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<DotsLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900), // Kecepatan animasi titik
    )..repeat();

    // Membuat animasi untuk setiap titik dengan delay
    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.3, 1.0, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Opacity(
                opacity: _animations[index].value,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
