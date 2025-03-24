import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../detail_page.dart'; // Pastikan DetailPage diimpor
import 'home_page.dart'; // Pastikan HomePage diimpor

class OtherProfilePage extends StatelessWidget {
  final String userId;

  OtherProfilePage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Hilangkan bayangan pada AppBar
        leading: GestureDetector(
          onTap: () {
            // Arahkan ke HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red, // Warna tombol kembali
              shape: BoxShape.circle, // Bentuk bulat
            ),
            child: Icon(
              Icons.arrow_back, // Ikon kembali
              color: Colors.white, // Warna ikon
            ),
          ),
        ),
        title: Text("User Profile"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data?.data() as Map<String, dynamic>;
          String username = userData['username'] ?? 'Anonymous';
          String profilePhotoUrl = userData['profilePhoto'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                // Gambar Profil
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profilePhotoUrl.isNotEmpty
                      ? NetworkImage(profilePhotoUrl)
                      : AssetImage('assets/images/default_profile.png') as ImageProvider,
                ),
                SizedBox(height: 10),
                // Nama Pengguna
                Text(
                  username,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(userData['email'] ?? 'No Email Available', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 20),
                Divider(),
                // Daftar Foto yang Diunggah Pengguna
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('photos')
                      .where('userId', isEqualTo: userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var photoDocs = snapshot.data!.docs;
                    if (photoDocs.isEmpty) {
                      return Center(child: Text("No photos uploaded yet."));
                    }

                    return GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Jumlah kolom
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.75, // Rasio tinggi vs lebar
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
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
