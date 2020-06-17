import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb_clone/models/Post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  FirebaseUser _firebaseUser;
  String imageDownloadUrl;
  bool uploadingPost;
  FirebaseAuth firebaseAuth;
  CollectionReference rootRef;
  CollectionReference postsRef;
  final StorageReference _storageReference =
      FirebaseStorage().ref().child("/post_images/");

  TextEditingController postController;

  PickedFile pickedImage;
  String pickedImagePath;
  final picker = ImagePicker();

  String postText;

  @override
  void initState() {
    firebaseAuth = FirebaseAuth.instance;
    uploadingPost = false;
    imageDownloadUrl = "";
    pickedImage = null;
    pickedImagePath = "";
    rootRef = Firestore.instance.collection("users");
    postsRef = Firestore.instance.collection("posts");
    postController = TextEditingController(text: "");
    postText = postController.text;
    getCurrentUser();
    super.initState();
  }

  Future<void> getCurrentUser() async {
    _firebaseUser = await firebaseAuth.currentUser();
  }

  Future<void> selectImage() async {
    pickedImage = await picker.getImage(source: ImageSource.gallery);
  }

  Future<void> uploadPost() async {
    print("Starting to upload post");
    Post post = new Post.construct(
      postId: Uuid().v1(),
      email: _firebaseUser.email,
      id: _firebaseUser.uid,
      imageUrl: imageDownloadUrl,
      postContent: postController.text,
      timestamp: Timestamp.now(),
    );
    var userId = (await firebaseAuth.currentUser()).uid;
    rootRef
        .document(userId)
        .collection("posts")
        .add(post.toMap())
        .then((DocumentReference value) {
          postsRef.add(post.toMap()).then((value) {
            print("Post content uploaded");
            setState(() {
              uploadingPost = false;
            });
            Navigator.pop(context);
          });
    }).catchError((error) {
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("Error"),
            content: Text("Check internet connection"),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ));
    });
  }

  Future<void> assignDownloadUrl(StorageTaskEvent event) async {
    imageDownloadUrl = await event.snapshot.ref.getDownloadURL();
  }

  Future<bool> uploadImage(File file) async {
    bool retVal = false;
    if (file.existsSync()) {
      StorageTaskEvent storageTaskEvent;
      StorageUploadTask task = _storageReference.child(Uuid().v1()).putFile(file);
      var evnt = task.events.listen(
            (StorageTaskEvent event) {
          if (event.type == StorageTaskEventType.success) {
            storageTaskEvent = event;
            retVal = true;
            print("Image download url is: $imageDownloadUrl");
            print('Upload successful');
          }
        },
      );

      await task.onComplete;
      evnt.cancel();
      await assignDownloadUrl(storageTaskEvent);
      print("Image download url is: $imageDownloadUrl");
      print(retVal);
    } else {
      retVal = true;
    }
    return retVal;
  }

  Future<void> runPost(BuildContext context) async {
    setState(() {
      uploadingPost = true;
    });
    bool uploaded = await uploadImage(new File(pickedImagePath));
    if (uploaded == false) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text("Error while posting, try again")));
    } else {
      await uploadPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white30,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Transform.scale(
            scale: 1.25,
            child: ClipOval(
                child: Container(
              padding: EdgeInsets.all(5.0),
              child: Icon(
                Icons.replay,
                color: Colors.white,
              ),
              color: Colors.blue,
            )),
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            tooltip: "Send Message",
            icon: Transform.rotate(
              angle: -45,
              child: Icon(
                Icons.send,
                color: postText == null
                    ? Colors.grey
                    : postText.isEmpty ? Colors.grey : Colors.blue,
              ),
            ),
            onPressed: postText.isEmpty
                ? null
                : () {
                    runPost(context);
                  },
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) => Container(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Stack(
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    TextField(
                      controller: postController,
                      onChanged: (string) {
                        setState(() {
                          postText = string;
                        });
                      },
                      autocorrect: true,
                      minLines: 10,
                      maxLines: 15,
                      decoration: InputDecoration(
                        hintText: "Write something...",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Colors.grey,
                          ),
                          gapPadding: 16.0,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: () {
                              setState(() {
                                selectImage().then((value) {
                                  setState(() {
                                    pickedImagePath = pickedImage.path;
                                  });
                                });
                              });
                            })
                      ],
                    ),
                    Image.file(
                      File(pickedImagePath),
                    )
                  ],
                ),
                uploadingPost
                    ? Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 5.0,
                          ),
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
