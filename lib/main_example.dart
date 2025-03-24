import 'package:dpixel/firebase_options.dart';
import 'package:dpixel/loading_screen.dart';
import 'package:dpixel/auth/login_page.dart';
import 'package:dpixel/auth/signup_page.dart';
import 'package:dpixel/screen/profile_page.dart';
import 'package:dpixel/screen/home_page.dart';
import 'package:dpixel/screen/upload_page.dart';
import 'package:dpixel/screen/search_page.dart';
import 'package:dpixel/screen/other_profile_page.dart';
import 'package:dpixel/auth/forgot_password_page.dart';
import 'package:dpixel/screen/notifikasi.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        appId: "YOUR_APP_ID",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        projectId: "YOUR_PROJECT_ID",
        authDomain: "YOUR_AUTH_DOMAIN",
        databaseURL: "YOUR_DATABASE_URL",
        storageBucket: "YOUR_STORAGE_BUCKET",
        measurementId: "YOUR_MEASUREMENT_ID",
      ),
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
    runApp(ErrorApp(errorMessage: e.toString()));
    return;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dpixel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoadingScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/profile': (context) => ProfilePage(),
        '/home': (context) => HomePage(),
        '/upload': (context) => UploadPage(),
        '/search': (context) => SearchPage(),
        '/other_profile': (context) => OtherProfilePage(userId: ''),
        '/forgot_password': (context) => ForgotPasswordPage(),
        '/notifikasi': (context) => NotificationPage(userId: ''),
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;

  const ErrorApp({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Gagal menginisialisasi Firebase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                SizedBox(height: 10),
                Text(
                  'Detail error:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
