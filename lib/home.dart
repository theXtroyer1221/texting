import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> cards =
      FirebaseFirestore.instance.collection("cards").snapshots();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
        child: StreamBuilder<QuerySnapshot>(
            stream: cards,
            builder: (
              BuildContext context,
              AsyncSnapshot snapshot,
            ) {
              if (snapshot.hasError) {
                return const Text("Something went wrong.");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              final data = snapshot.requireData;
              return ListView.builder(
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Card(
                        margin: const EdgeInsets.all(3),
                        child: Column(
                          children: [
                            Image.network(data.docs[index]["image"].toString()),
                            ListTile(
                              title: Text(data.docs[index]["title"].toString()),
                              subtitle:
                                  Text(data.docs[index]["text"].toString()),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }));
  }
}
