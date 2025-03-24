import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'dart:html' as html; // Untuk web

class DetailPage extends StatefulWidget {
  final String imageUrl;

  DetailPage({required this.imageUrl});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? photoData;
  String? photoId;
  bool isLoading = true;
  TextEditingController _commentController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchPhotoData();
  }

  Future<void> fetchPhotoData() async {
    final photoSnapshot = await FirebaseFirestore.instance
        .collection('photos')
        .where('imageUrl', isEqualTo: widget.imageUrl)
        .limit(1)
        .get();

    if (photoSnapshot.docs.isNotEmpty) {
      var doc = photoSnapshot.docs.first;
      setState(() {
        photoData = doc.data();
        photoId = doc.id;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void shareImage() {
    Share.share(widget.imageUrl);
  }

  void downloadImage() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final taskId = await FlutterDownloader.enqueue(
        url: widget.imageUrl,
        savedDir: '/storage/emulated/0/Download/',
        showNotification: true,
        openFileFromNotification: true,
      );
      if (taskId != null) {
        Fluttertoast.showToast(msg: "Gambar berhasil diunduh");
      }
    } else if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      Fluttertoast.showToast(msg: "Unduhan hanya didukung di Android/iOS");
    } else {
      html.AnchorElement anchorElement = html.AnchorElement(href: widget.imageUrl);
      anchorElement.download = "downloaded_image.jpg";
      anchorElement.click();
    }
  }

  void addComment() async {
    if (_commentController.text.trim().isEmpty || photoId == null) return;

    await FirebaseFirestore.instance
        .collection('photos')
        .doc(photoId)
        .collection('comments')
        .add({
      'username': user?.displayName ?? user?.email?.split('@')[0] ?? 'Anonim',
      'text': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
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
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 80), // Beri ruang untuk input komentar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 10),

                  // Foto
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),

                  // Informasi Foto
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            photoData?['judulFoto'] ?? 'Tanpa Judul',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          (photoData?['tanggalUnggah'] != null)
                              ? DateFormat('dd MMM yyyy, HH:mm').format((photoData?['tanggalUnggah'] as Timestamp).toDate())
                              : "Tidak diketahui",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Deskripsi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                    child: Text(
                      photoData?['deskripsiFoto'] ?? 'Tidak ada deskripsi',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),

                  // Komentar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                    child: Text("Komentar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: photoId != null
                        ? FirebaseFirestore.instance
                            .collection('photos')
                            .doc(photoId)
                            .collection('comments')
                            .orderBy('timestamp', descending: true)
                            .snapshots()
                        : null,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || photoId == null) return Center(child: CircularProgressIndicator());
                      var comments = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          var comment = comments[index].data() as Map<String, dynamic>;
                          return ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person, color: Colors.white)),
                            title: Text(comment['username'], style: TextStyle(color: Colors.white)),
                            subtitle: Text(comment['text'], style: TextStyle(color: Colors.grey)),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Input Komentar Fixed
          Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: addComment,
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
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
