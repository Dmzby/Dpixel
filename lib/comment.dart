import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String photoId;
  final String userId;
  final String userName;
  final String comment;
  final Timestamp timestamp;

  Comment({
    required this.photoId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.timestamp,
  });

  // Fungsi untuk memetakan data dari DocumentSnapshot menjadi objek Comment
  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      photoId: doc['photoId'],
      userId: doc['userId'],
      userName: doc['userName'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }
}
