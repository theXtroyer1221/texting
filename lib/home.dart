// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:like_button/like_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class Post {
  final String id;
  final String title;
  final String text;
  final String image;
  final int price;
  final Timestamp date;

  const Post(this.id, this.title, this.text, this.image, this.price, this.date);
}

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
                    Post post = Post(
                        data.docs[index].id,
                        data.docs[index]["title"],
                        data.docs[index]["text"],
                        data.docs[index]["image"],
                        data.docs[index]["price"],
                        data.docs[index]["date"]);
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        margin: const EdgeInsets.all(3),
                        child: InkWell(
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ImagePreview(),
                                  settings: RouteSettings(arguments: post)),
                            )
                          },
                          child: Column(
                            children: [
                              PinchZoomImage(
                                zoomedBackgroundColor:
                                    const Color.fromRGBO(240, 240, 240, 1.0),
                                image: Image.network(
                                  post.image,
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
                                        title: Text(post.title),
                                        subtitle: Text(post.text),
                                      ),
                                    ),
                                    LikeButton(
                                      likeCount: post.price,
                                      onTap: (bool isLiked) async {
                                        var likes = post.price;
                                        FirebaseFirestore.instance
                                            .collection("cards")
                                            .doc(post.id)
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
                      ),
                    );
                  });
            }));
  }
}

class ImagePreview extends StatelessWidget {
  const ImagePreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final post = ModalRoute.of(context)!.settings.arguments as Post;
    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Image.network(
              post.image,
              height: 300,
              width: double.infinity,
              fit: BoxFit.fitHeight,
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              post.text,
              style: const TextStyle(),
            )
          ],
        ),
      ),
    );
  }
}
