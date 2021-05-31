import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class UserModel{
  final String email;
  final String name;
  final String id;

  UserModel(this.email, this.id, this.name);

  factory UserModel.fromJson(Map<String, dynamic> parsedJson){
    return new UserModel(
        parsedJson['email'] ?? '',
        parsedJson['id'] ?? '',
        parsedJson['name'] ?? ','

    );
  }

  Map<String, dynamic> toJSon(){
    return{
      'name':this.name,
      'email':this.email,
      'id':this.id
    };
  }

  static Future<UserModel> getCurrentUser(String uid) async{
    DocumentSnapshot userDocument = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if(userDocument != null && userDocument.exists){
      return UserModel.fromJson(userDocument.data());
    }else{
      return null;
    }
  }

  static Future<UserModel> updateCurrentUser(UserModel user) async{
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(user.id)
        .set(user.toJSon())
        .then((value){
          return user;
        });
  }


}