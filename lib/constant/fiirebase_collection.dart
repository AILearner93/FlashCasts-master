import 'package:cloud_firestore/cloud_firestore.dart';

class FBCollections {
  static FirebaseFirestore db = FirebaseFirestore.instance;
  static CollectionReference users = db.collection("users");
}
