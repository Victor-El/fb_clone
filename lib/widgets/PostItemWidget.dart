import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb_clone/models/Comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fb_clone/utils/Util.dart' as Util;

class PostItemWidget extends StatelessWidget {
  final String email;
  final String name;
  final Timestamp time;
  final String imageUrl;
  final bool liked;
  final String postContent;
  final List<Comment> comments;
  final List<String> likes;

  PersistentBottomSheetController _persistentBottomSheetController;
  TextEditingController _commentController =
      new TextEditingController(text: "");

  PostItemWidget({
    this.email,
    this.name,
    this.postContent,
    this.time,
    this.imageUrl,
    this.liked,
    this.comments,
    this.likes,
  });

  int getHoursAgoFromTimestamp(Timestamp timestamp) {
    int value = Timestamp.now().millisecondsSinceEpoch -
        timestamp.millisecondsSinceEpoch;
    double retVal = value / (1000 * 60 * 60);
    return retVal.round().toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.grey,
      color: Colors.white,
      margin: EdgeInsets.all(8.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Util.getUsernameFromEmail(email),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 23.0,
                  ),
                ),
                Text("${getHoursAgoFromTimestamp(time)} hours ago"),
                Text(
                  postContent,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 23.0,
                  ),
                ),
              ],
            ),
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                return Container(height: 200, child: child);
              },
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: FlatButton.icon(
                    onPressed: () {
                      // TODO: Write like logic here
                    },
                    icon: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    label: Text("${likes.length} likes"),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      _persistentBottomSheetController = Scaffold.of(context)
                          .showBottomSheet((context) => Container(
                                padding: EdgeInsets.all(16.0),
                                height: 300.0,
                                color: Colors.white70,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: ListView.builder(
                                        itemBuilder:
                                            (BuildContext context, int index) =>
                                                ListTile(
                                          title: Text(comments
                                              .elementAt(index)
                                              .commenterId),
                                          subtitle: Text(
                                              comments[index].commentContent),
                                        ),
                                        itemCount: comments.length,
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: TextField(
                                            controller: _commentController,
                                            decoration:
                                                InputDecoration.collapsed(
                                              hintText: "Write comment",
                                              border: OutlineInputBorder(
                                                gapPadding: 20.0,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            child: IconButton(
                                          icon: Transform.rotate(
                                            angle: -45,
                                            child: Icon(Icons.send),
                                          ),
                                          onPressed: () {
                                            // TODO: write logic to add comment
                                            _persistentBottomSheetController
                                                .close();
                                          },
                                        ))
                                      ],
                                    ),
                                  ],
                                ),
                              ));
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: IgnorePointer(
                        child: TextField(
                          enabled: false,
                          showCursor: false,
                          decoration: InputDecoration(
                            hintText: "Write a comment",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 5.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
