import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../detail_page.dart'; // Import DetailPage

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  List<String> _sliderImages = [];
  bool isLoading = false;
  int _selectedIndex = 1;
  String userName = "";

  @override
  void initState() {
    super.initState();
    _getUserName();
    _fetchSliderImages();
  }

  Future<void> _getUserName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          if (mounted) {
            setState(() {
              userName = userDoc['username'] ?? "Pengguna";
            });
          }
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _fetchSliderImages() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('photos')
        .orderBy('tanggalUnggah', descending: true)
        .limit(5)
        .get();

    List<String> images = snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();

    if (mounted) {
      setState(() {
        _sliderImages = images;
      });
    }
  }

  Future<void> _searchPhotos() async {
    String query = _searchController.text.trim().toLowerCase();
    setState(() => isLoading = true);

    if (query.isNotEmpty) {
      try {
        var snapshot = await FirebaseFirestore.instance
            .collection('photos')
            .where('judulFoto', isGreaterThanOrEqualTo: query)
            .where('judulFoto', isLessThanOrEqualTo: query + '\uf8ff')
            .get();

        if (mounted) {
          setState(() => _searchResults = snapshot.docs);
        }
      } catch (e) {
        print("Error fetching search results: $e");
      }
    } else {
      if (mounted) {
        setState(() => _searchResults = []);
      }
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
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
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Color.fromARGB(167, 22, 19, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $userName",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _searchPhotos(),
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari inspirasi...',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.black,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

          if (_sliderImages.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  enlargeCenterPage: true,
                ),
                items: _sliderImages.map((imageUrl) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[900],
                          child: Icon(Icons.broken_image, color: Colors.red),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : _searchResults.isEmpty
                    ? Center(child: Text("Temukan ide menarik", style: TextStyle(color: Colors.grey)))
                    : Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            var resultData = _searchResults[index].data() as Map<String, dynamic>;
                            String photoUrl = resultData['imageUrl'] ?? '';
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(
                                      imageUrl: photoUrl,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(child: CircularProgressIndicator(color: Colors.white));
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
                      ),
          ),
        ],
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
      ),
    );
  }
}
