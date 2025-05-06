import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Pacientes extends StatelessWidget {

  void hola(){
    print("hola");
    // return "hola";
  }

  Pacientes({super.key});
  

   static var db = FirebaseFirestore.instance;
   final users = db.collection('users');

 Future<void> fetchData() async {
   await db.collection("users").get().then((event) {
   for (var doc in event.docs) {
     print("${doc.id} => ${doc.data()}");
   }
 });

 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
        //children: [ElevatedButton(onPressed: hola, child: Text("Ver usuarios"))]
          children: [ElevatedButton(onPressed: fetchData, child: Text("Ver usuarios"))]
        )
      )
    );
  }
}