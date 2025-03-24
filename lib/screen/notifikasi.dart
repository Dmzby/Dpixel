import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dpixel/detail_page.dart';
import 'package:flutter/material.dart';
import '../comment.dart';

class NotificationPage extends StatefulWidget {
  final String userId;

  NotificationPage({required this.userId});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 3;

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
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Color(0xFF121212),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('comments')
            .where('userId', isEqualTo: widget.userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text("Belum ada komentar.",
                    style: TextStyle(color: Colors.white)));
          }

          var comments = snapshot.data!.docs.map((doc) {
            return Comment.fromDocument(doc);
          }).toList();

          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              var comment = comments[index];

              return ListTile(
                title: Text(comment.userName, style: TextStyle(color: Colors.white)),
                subtitle: Text(comment.comment, style: TextStyle(color: Colors.grey)),
                trailing: Text(
                  "${comment.timestamp.toDate().toLocal()}",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () async {
                  var photoDoc = await FirebaseFirestore.instance
                      .collection('photos')
                      .doc(comment.photoId)
                      .get();

                  if (photoDoc.exists) {
                    var photoData = photoDoc.data();
                    String photoUrl = photoData?['imageUrl'] ?? '';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          imageUrl: photoUrl,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
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
