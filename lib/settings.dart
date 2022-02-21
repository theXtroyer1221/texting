// ignore_for_file: avoid_print, unused_import
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseStorage firebaseStorage = FirebaseStorage.instance;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          children: const [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                "Publish a new service",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            PostForm(),
          ],
        ));
  }
}

class PostForm extends StatefulWidget {
  const PostForm({Key? key}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();

  var title = "";
  var text = "";
  var price = 0;
  var image = "";
  XFile? upload;

  pickPicture(selectedMethod) async {
    upload = await ImagePicker().pickImage(source: selectedMethod);

    var imageFile = File(upload!.path);
    var storageRef = firebaseStorage.ref().child("card/$imageFile");
    var uploadTask = storageRef.putFile(imageFile);
    var taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
      (value) {
        setState(() {
          image = value;
        });
      },
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference cards = FirebaseFirestore.instance.collection("cards");
    return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                  hintText: "What is the title of the post?",
                  labelText: "Title"),
              onChanged: (value) => title = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "You cant leave the field empty";
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                  hintText: "What is the body of the post?", labelText: "Body"),
              onChanged: (value) => text = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "You cant leave the field empty";
                }
                return null;
              },
            ),
            TextButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: 100,
                          child: Column(
                            children: [
                              TextButton(
                                child: Row(
                                  children: const [
                                    Icon(Icons.camera_alt),
                                    Text('Camera')
                                  ],
                                ),
                                onPressed: () =>
                                    pickPicture(ImageSource.camera),
                              ),
                              TextButton(
                                child: Row(
                                  children: const [
                                    Icon(Icons.photo),
                                    Text('Gallery')
                                  ],
                                ),
                                onPressed: () =>
                                    pickPicture(ImageSource.gallery),
                              )
                            ],
                          ),
                        );
                      });
                },
                child: const Text("Upload image")),
            Image.network(
              image,
              height: 200,
              width: 250,
              errorBuilder: (context, url, error) =>
                  const Text("Preview of your image..."),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Processing the data")));
                        var dateToday = DateTime.now();
                        cards
                            .add({
                              "title": title,
                              "text": text,
                              "price": 0,
                              "image": image,
                              "date": dateToday
                            })
                            .then((value) => print("Post Added"))
                            .catchError(
                                (error) => print("Failed to add post: $error"));
                      }
                    },
                    child: const Text("Submit"))
              ],
            )
          ],
        ));
  }
}
