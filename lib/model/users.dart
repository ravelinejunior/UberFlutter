import 'package:firebase_database/firebase_database.dart';

class Users {
  String id;
  String email;
  String name;
  String phone;

  Users({this.email, this.id, this.name, this.phone});
  Users.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    email = snapshot.value['email'];
    name = snapshot.value['name'];
    phone = snapshot.value['phone'];
  }
}
