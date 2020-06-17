import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb_clone/models/Comment.dart';
import 'package:fb_clone/models/Post.dart';
import 'package:fb_clone/widgets/PostItemWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Post> posts;
  FirebaseUser user;
  FocusNode focusNode;
  CollectionReference postCollectionReference;
  String stringUserId;
  String userEmail;

  Future<void> getCurrentUser() async {
    user = await FirebaseAuth.instance.currentUser();
    stringUserId = user.uid;
    userEmail = user.email;
  }

  @override
  void initState() {
    postCollectionReference = Firestore.instance.collection("posts");
    focusNode = FocusNode();
    user = null;
    stringUserId = null;
    userEmail = null;
    getCurrentUser();
//    posts = <Post>[];
//    Post post1 = new Post.construct(
//      postId: Uuid().v1(),
//      email: "victorelezua@gmail.com",
//      id: "1",
//      imageUrl: "https://image.com",
//      postContent: "Hello fam, Such a nice day",
//      timestamp: Timestamp.now(),
//      comments: [new Comment(commentContent: "Nice one", commenterId: "Abig")],
//      likes: ["ikdfog84t8jfg-tmrn8t", "jhdfyo783rjehf8-kf84mf-mkt408"],
//    );
//    posts.add(post1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.canPop(context)
            ? Navigator.pop(context)
            : SystemNavigator.pop(animated: true);
        return false;
      },
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 16.0),
          child: Center(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Facebook",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Clone Mode",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade800,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        PopupMenuButton(
                          itemBuilder: (BuildContext context) {
                            List<String> popupStrings = ["Sign Out"];
                            return popupStrings
                                .map((e) => PopupMenuItem(
                                      child: Text(e),
                                      value: e,
                                    ))
                                .toList();
                          },
                          onSelected: (selected) {
                            selected == "Sign Out"
                                ? FirebaseAuth.instance.signOut().then(
                                    (value) => Navigator.pushReplacementNamed(
                                        context, "/login-register"))
                                : null;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(20.0)),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed("/add-post");
                    FocusScope.of(context).requestFocus(focusNode);
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: TextField(
                        focusNode: focusNode,
                        showCursor: false,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 12.5,
                                color: Colors.grey,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: postCollectionReference.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text("Something went wrong");
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Waiting ...");
                        } else {
                          return ListView(
                            shrinkWrap: true,
                            semanticChildCount: 1,
                            children: snapshot.data.documents
                                .map((DocumentSnapshot e) => PostItemWidget(
                                      userEmail: userEmail,
                                      user: stringUserId,
                                      postId: e['post-id'],
                                      email: e['email'],
                                      name: e['user-id'],
                                      postContent: e['post-content'],
                                      imageUrl: e['image-url'],
                                      time: e['timestamp'],
                                      comments:
                                          List<Map<dynamic, dynamic>>.from(
                                              e['comments']),
                                      likes: List<String>.from(e['likes']),
                                    ))
                                .toList(),
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
