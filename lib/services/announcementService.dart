import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  String path = '/announcements';

  Future<List<Map<dynamic, dynamic>>> getData(String path) async {
    DataSnapshot dataSnapshot = await _databaseReference.child(path).get();
    if (dataSnapshot.exists) {
      List<Map<dynamic, dynamic>> dataList = [];
      dataSnapshot.children.forEach((childSnapshot) {
        dataList.add(Map<dynamic, dynamic>.from(childSnapshot.value as Map));
      });
      return dataList;
    } else {
      throw Exception('No data available at path: $path');
    }
  }
}
