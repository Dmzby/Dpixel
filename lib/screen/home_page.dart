import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> imageUrls = [];
  final User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('uploads');
      final ListResult result = await storageRef.listAll();

      List<String> urls = [];
      for (var item in result.items) {
        String url = await item.getDownloadURL();
        urls.add(url);
      }

      urls.shuffle();

      setState(() {
        imageUrls = urls;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching images: $e");
    }
  }

  Future<Map<String, String>> fetchPhotoData(String imageUrl) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('photos')
          .where('imageUrl', isEqualTo: imageUrl)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        return {
          'photoUrl': doc['imageUrl'] ?? '',
          'photoTitle': doc['judulFoto'] ?? 'No Title',
          'photoDescription': doc['deskripsiFoto'] ?? 'No Description',
        };
      } else {
        return {
          'photoUrl': '',
          'photoTitle': 'No Title',
          'photoDescription': 'No Description',
        };
      }
    } catch (e) {
      print("Error fetching photo data: $e");
      return {
        'photoUrl': '',
        'photoTitle': 'Error fetching title',
        'photoDescription': 'Error fetching description',
      };
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/upload');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/notifikasi');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(167, 22, 19, 24),
        elevation: 0,
        title: Text(
          "Untuk Anda",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: fetchImages,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
            : imageUrls.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 16.0, 10, 8.0),
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  imageUrl: imageUrls[index],
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrls[index],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(color: Colors.pinkAccent),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[900],
                                  child: Icon(Icons.error, color: Colors.red),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      "Temukan ide menarik",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF1E1B22),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, color: Colors.white, size: 40), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
        elevation: 0,
      ),
    );
  }
}
