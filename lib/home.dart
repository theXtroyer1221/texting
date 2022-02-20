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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Hero(
                        tag: data.docs[index]["title"].toString(),
                        child: Card(
                          margin: const EdgeInsets.all(3),
                          child: Column(
                            children: [
                              Image.network(
                                data.docs[index]["image"].toString(),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: Text(data.docs[index]["title"]
                                            .toString()),
                                        subtitle: Text(data.docs[index]["text"]
                                            .toString()),
                                      ),
                                    ),
                                    Text(
                                      data.docs[index]["price"].toString(),
                                      style: const TextStyle(
                                          color: Colors.green, fontSize: 30),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }));
  }
}
