// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

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
                      child: Card(
                        margin: const EdgeInsets.all(3),
                        child: Column(
                          children: [
                            PinchZoomImage(
                              zoomedBackgroundColor:
                                  const Color.fromRGBO(240, 240, 240, 1.0),
                              image: Image.network(
                                data.docs[index]["image"].toString(),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                          data.docs[index]["title"].toString()),
                                      subtitle: Text(
                                          data.docs[index]["text"].toString()),
                                    ),
                                  ),
                                  LikeButton(
                                    likeCount: data.docs[index]["price"],
                                    onTap: (bool isLiked) async {
                                      var likes = data.docs[index]["price"];
                                      FirebaseFirestore.instance
                                          .collection("cards")
                                          .doc(data.docs[index].id)
                                          .update({"price": likes}).then(
                                              (value) => print(likes));

                                      return !isLiked;
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }));
  }
}
