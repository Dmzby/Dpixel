import 'package:dpixel/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../detail_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String? profilePhotoUrl;
  int _selectedIndex = 4;

  Future<void> _changeProfilePicture() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result == null) return;

      Uint8List? fileBytes = result.files.single.bytes;
      String fileName = '${user?.uid}_profile.jpg';

      if (fileBytes != null) {
        Reference ref = FirebaseStorage.instance.ref().child('profile_pictures').child(fileName);
        UploadTask uploadTask = ref.putData(fileBytes);

        await uploadTask.whenComplete(() async {
          String photoUrl = await ref.getDownloadURL();
          await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
            'profilePhoto': photoUrl,
          });

          setState(() {
            profilePhotoUrl = photoUrl;
          });
        });
      }
    } catch (e) {
      print("Error uploading profile picture: $e");
    }
  }

  Future<void> _removeProfilePicture() async {
    try {
      if (profilePhotoUrl != null) {
        Reference ref = FirebaseStorage.instance.refFromURL(profilePhotoUrl!);
        await ref.delete();
      }
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        'profilePhoto': FieldValue.delete(),
      });
      setState(() {
        profilePhotoUrl = null;
      });
    } catch (e) {
      print("Error removing profile picture: $e");
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
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data?.data() as Map<String, dynamic>;
          String username = userData['username'] ?? 'Anonymous';
          profilePhotoUrl = userData['profilePhoto'];

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 20),
                    
                    // Foto Profil
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profilePhotoUrl != null
                          ? NetworkImage(profilePhotoUrl!)
                          : AssetImage('assets/images/default_profile.png') as ImageProvider,
                    ),
                    SizedBox(height: 10),
                    Text(
                      username,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      user?.email ?? 'No Email Available',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Divider(color: Colors.grey[700], thickness: 0.5, indent: 30, endIndent: 30),
                    
                    SizedBox(height: 20),
                    
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16), // Batas kiri dan kanan
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('photos').where('userId', isEqualTo: user?.uid).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          var photoDocs = snapshot.data!.docs;
                          if (photoDocs.isEmpty) {
                            return Center(child: Text("Tidak ada foto yang diunggah", style: TextStyle(color: Colors.white)));
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12.0, // Jarak antar kolom
                              mainAxisSpacing: 12.0, // Jarak antar baris
                              childAspectRatio: 0.8,
                            ),
                            itemCount: photoDocs.length,
                            itemBuilder: (context, index) {
                              var photoData = photoDocs[index].data() as Map<String, dynamic>;
                              String photoUrl = photoData['imageUrl'];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(imageUrl: photoUrl),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(100, 100, 20, 0),
                      items: [
                        PopupMenuItem(
                          value: 'changeProfile',
                          child: Text('Ganti Foto Profil'),
                        ),
                        PopupMenuItem(
                          value: 'removeProfile',
                          child: Text('Hapus Foto Profil'),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Text('Logout'),
                        ),
                      ],
                    ).then((value) async {
                      if (value == 'logout') {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      } else if (value == 'changeProfile') {
                        _changeProfilePicture();
                      } else if (value == 'removeProfile') {
                        _removeProfilePicture();
                      }
                    });
                  },
                ),
              ),
            ],
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
