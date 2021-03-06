import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:wei_pei_yang_demo/feedback/model/comment.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/official_logo.dart';

import 'blank_space.dart';

// ignore: must_be_immutable
class CommentCard extends StatefulWidget {
  Comment comment;
  bool official;
  bool detail;
  String title;
  void Function() onContentPressed = () {};
  void Function() onLikePressed = () {};

  @override
  _CommentCardState createState() => _CommentCardState(
      comment, official, detail, onContentPressed, title, onLikePressed);

  CommentCard(comment,
      {void Function() onContentPressed, void Function() onLikePressed}) {
    this.comment = comment;
    this.official = false;
    this.detail = false;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
  }

  CommentCard.official(comment,
      {void Function() onContentPressed, void Function() onLikePressed}) {
    this.comment = comment;
    this.official = true;
    this.detail = false;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
  }

  CommentCard.detail(comment,
      {@required title,
      void Function() onContentPressed,
      void Function() onLikePressed}) {
    this.comment = comment;
    this.official = true;
    this.detail = true;
    this.title = title;
    this.onContentPressed = onContentPressed;
    this.onLikePressed = onLikePressed;
  }
}

class _CommentCardState extends State<CommentCard> {
  final Comment comment;
  final bool official;
  final bool detail;
  final String title;
  final void Function() onContentPressed;
  final void Function() onLikePressed;

  _CommentCardState(this.comment, this.official, this.detail,
      this.onContentPressed, this.title, this.onLikePressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail)
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: ColorUtil.boldTextColor,
              ),
            ),
          if (detail) BlankSpace.height(8),
          if (detail)
            Divider(
              height: 0.6,
              color: Color(0xffacaeba),
            ),
          if (detail) BlankSpace.height(8),
          Row(
            children: [
              if (official)
                OfficialLogo()
              else
                ClipOval(
                  child: Image.asset(
                    'assets/images/user_image.jpg',
                    fit: BoxFit.cover,
                    width: 20,
                    height: 20,
                  ),
                ),
              if (!official) BlankSpace.width(5),
              if (!official)
                Expanded(
                  child: Text(
                    comment.userName,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        fontSize: 14, color: ColorUtil.lightTextColor),
                  ),
                ),
              Spacer(),
              Text(
                comment.createTime.substring(0, 10) +
                    '  ' +
                    (comment.createTime
                            .substring(11)
                            .split('.')[0]
                            .startsWith('0')
                        ? comment.createTime
                            .substring(12)
                            .split('.')[0]
                            .substring(0, 4)
                        : comment.createTime
                            .substring(11)
                            .split('.')[0]
                            .substring(0, 5)),
                style: TextStyle(
                  color: ColorUtil.lightTextColor,
                ),
              ),
            ],
          ),
          BlankSpace.height(8),
          if (official && !detail)
            GestureDetector(
              child: Text(
                comment.content
                    .replaceAll('<p>', '')
                    .replaceAll('</p>', '\n')
                    .replaceAll('<img.*?>', ''),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1,
                  color: ColorUtil.boldTextColor,
                ),
              ),
              onTap: onContentPressed,
            )
          else if (official && detail)
            HtmlWidget(
              comment.content,
              textStyle: TextStyle(
                color: ColorUtil.boldTextColor,
                height: 1,
              ),
            )
          else
            Text(
              comment.content,
              style: TextStyle(
                height: 1,
                color: ColorUtil.boldTextColor,
              ),
            ),
          BlankSpace.height(5),
          Row(
            children: [
              if (official && comment.rating == -1)
                Text(
                  '提问者未评分',
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorUtil.lightTextColor,
                  ),
                ),
              if (official && comment.rating != -1)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '提问者评分:',
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorUtil.lightTextColor,
                      ),
                    ),
                    RatingBar.builder(
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: ColorUtil.mainColor,
                      ),
                      allowHalfRating: true,
                      glow: false,
                      initialRating: (comment.rating.toDouble() / 2),
                      itemCount: 5,
                      itemSize: 16,
                      ignoreGestures: true,
                      unratedColor: ColorUtil.lightTextColor,
                      onRatingUpdate: (_) {},
                    ),
                  ],
                ),
              Spacer(),
              // Like count.
              GestureDetector(
                onTap: onLikePressed,
                child: Row(
                  children: [
                    ClipOval(
                      child: Icon(
                        !comment.isLiked
                            ? Icons.thumb_up_outlined
                            : Icons.thumb_up,
                        size: 16,
                        color: !comment.isLiked
                            ? ColorUtil.lightTextColor
                            : Colors.red,
                      ),
                    ),
                    BlankSpace.width(8),
                    Text(
                      comment.likeCount.toString(),
                      style: TextStyle(
                          fontSize: 14, color: ColorUtil.lightTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              blurRadius: 5,
              color: Color.fromARGB(64, 236, 237, 239),
              offset: Offset(0, 0),
              spreadRadius: 3),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    );
  }
}
