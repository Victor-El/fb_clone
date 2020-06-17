class Comment {
  String commentContent;
  String commenterId;

  Comment({this.commentContent, this.commenterId});

  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      "commenter-email": this.commenterId,
      "comment-content": this.commentContent
    };
  }


}