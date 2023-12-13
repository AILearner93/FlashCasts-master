import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FBStorage {
  Future<String?> uploadUint8ListAndGetLink(Uint8List data) async {
    try {
      String fileName = 'file_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('uploads/$fileName');

      UploadTask uploadTask = storageReference.putData(data);
      await uploadTask.whenComplete(() => null);

      String downloadUrl = await storageReference.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
