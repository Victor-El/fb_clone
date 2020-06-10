import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb_clone/models/Comment.dart';
import 'package:fb_clone/models/Post.dart';
import 'package:fb_clone/widgets/PostItemWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Post> posts;
  FirebaseUser user;
  FocusNode focusNode;

  @override
  void initState() {
    focusNode = FocusNode();
    user = null;
    posts = <Post>[];
    Post post1 = new Post.construct(
      email: "victorelezua@gmail.com",
      id: "1",
      imageUrl: "https://image.com",
      postContent: "Hello fam, Such a nice day",
      timestamp: Timestamp.now(),
      comments: [new Comment(commentContent: "Nice one", commenterId: "Abig")],
      likes: ["ikdfog84t8jfg-tmrn8t", "jhdfyo783rjehf8-kf84mf-mkt408"],
    );
    posts.add(post1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> argsMap =
    ModalRoute
        .of(context)
        .settings
        .arguments as Map<String, dynamic>;
    user = argsMap["firebase-user"] as FirebaseUser;
    return WillPopScope(
      onWillPop: () async {
        Navigator.canPop(context) ? Navigator.pop(context) : SystemNavigator
            .pop(animated: true);
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
                  child: ListView(
                    shrinkWrap: true,
                    semanticChildCount: 1,
                    children: <Widget>[
                      PostItemWidget(
                        liked: posts[0].likes.contains(user.uid),
                        likes: posts[0].likes,
                        time: Timestamp.now(),
                        postContent: posts[0].postContent,
                        comments: posts[0].comments,
                        imageUrl:
                        "https://guardian.ng/wp-content/uploads/2019/05/Victor-AD.jpg",
                        name: posts[0].id,
                        email: posts[0].email,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
