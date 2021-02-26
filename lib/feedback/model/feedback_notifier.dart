import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/feedback/model/comment.dart';
import 'package:wei_pei_yang_demo/feedback/model/post.dart';
import 'package:wei_pei_yang_demo/feedback/model/tag.dart';
import 'package:wei_pei_yang_demo/feedback/util/http_util.dart';

class FeedbackNotifier with ChangeNotifier {
  List<Tag> _tagList = List();
  List<Post> _homePostList = List();
  List<Post> _profilePostList = List();
  List<Comment> _officialCommentList = List();
  List<Comment> _commentList = List();
  List<String> _searchHistoryList = List();
  int _homeTotalPage = 0;
  bool _hitLikeLock = false;
  int _myUserId;

  List<Tag> get tagList => _tagList;

  List<Post> get homePostList => _homePostList;

  List<Post> get profilePostList => _profilePostList;

  List<Comment> get officialCommentList => _officialCommentList;

  List<Comment> get commentList => _commentList;

  List<String> get searchHistoryList => _searchHistoryList;

  int get homeTotalPage => _homeTotalPage;

  int get myUserId => _myUserId;

  getMyUserId() async {
    // TODO: Fake user id.
    _myUserId = 1;
    notifyListeners();
  }

  initSearchHistory() async {
    final _prefs = await SharedPreferences.getInstance();
    if (_prefs.getStringList('feedback_search_history') == null) {
      _prefs.setStringList('feedback_search_history', List());
      _searchHistoryList = List();
    } else {
      _searchHistoryList = _prefs.getStringList('feedback_search_history');
    }
  }

  clearTagList() {
    _tagList.clear();
    notifyListeners();
  }

  clearHomePostList() {
    _homePostList.clear();
    notifyListeners();
  }

  clearCommentList() {
    _officialCommentList.clear();
    _commentList.clear();
  }

  updateRating(rating, index) {
    _officialCommentList[index].rating = rating;
    notifyListeners();
  }

  addSearchHistory(content) async {
    final _prefs = await SharedPreferences.getInstance();
    if (_searchHistoryList.contains(content)) {
      _searchHistoryList.remove(content);
    }
    _searchHistoryList.insert(0, content);
    _prefs.setStringList('feedback_search_history', _searchHistoryList);
    notifyListeners();
  }

  clearSearchHistory() async {
    searchHistoryList.clear();
    final _prefs = await SharedPreferences.getInstance();
    _prefs.setStringList('feedback_search_history', List());
    notifyListeners();
  }

  /// Get tags.
  Future getTags() async {
    try {
      await HttpUtil().get('tag/get/all').then((value) {
        if (0 != value['data'][0]['children'].length) {
          for (Map<String, dynamic> json in value['data'][0]['children']) {
            _tagList.add(Tag.fromJson(json));
          }
          notifyListeners();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  /// Get posts.
  Future getPosts(tagId, page, {keyword}) async {
    try {
      await HttpUtil().get(
        'question/search',
        {
          'searchString': keyword ?? '',
          'tagList': '[$tagId]',
          'limits': '20',
          'user_id': _myUserId,
          'page': '$page',
        },
      ).then((value) {
        _homeTotalPage = value['data']['total'];
        for (Map<String, dynamic> json in value['data']['data']) {
          _homePostList.add(Post.fromJson(json));
        }
        int i = 0;
        for (Post post in _homePostList) {
          print('${post.title}\t\t${post.id}');
          i++;
        }
        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
  }

  /// Get my posts.
  Future getMyPosts() async {
    try {
      await HttpUtil().get(
        'question/get/myQuestion',
        {
          'limits': 0,
          'user_id': _myUserId,
          'page': 1,
        },
      ).then((value) {
        print(json.encode(value));
        for (Map<String, dynamic> map in value['data']) {
          print(json.encode(map));
          _profilePostList.add(Post.fromJson(map));
        }
        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
  }

  /// Get official comments.
  Future getOfficialComments(id, userId) async {
    try {
      await HttpUtil().get(
        'question/get/answer',
        {
          'question_id': '$id',
          'user_id': '$userId',
        },
      ).then((value) {
        for (Map<String, dynamic> comment in value['data']) {
          _officialCommentList.add(Comment.fromJson(comment));
        }
        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
  }

  /// Get user comments.
  Future getComments(id, userId) async {
    try {
      await HttpUtil().get(
        'question/get/commit',
        {
          'question_id': '$id',
          'user_id': '$userId',
        },
      ).then((value) {
        print('success!');
        for (Map<String, dynamic> comment in value['data']) {
          _commentList.add(Comment.fromJson(comment));
        }
        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
  }

  /// Like or dislike the post.
  Future homePostHitLike(index, id, userId) async {
    if (!_hitLikeLock) {
      _hitLikeLock = true;
      try {
        await HttpUtil()
            .post(
          _homePostList[index].isLiked ? 'question/dislike' : 'question/like',
          FormData.fromMap({
            'id': '$id',
            'user_id': '$userId',
          }),
        )
            .then(
          (value) {
            if (value['ErrorCode'] == 0) {
              if (_homePostList[index].isLiked) {
                _homePostList[index].likeCount--;
                _homePostList[index].isLiked = false;
              } else {
                _homePostList[index].likeCount++;
                _homePostList[index].isLiked = true;
              }
              print(json.encode(value));
              notifyListeners();
            } else {
              ToastProvider.error('点赞失败');
            }
            _hitLikeLock = false;
          },
        );
      } catch (e) {
        print(e);
      }
    }
  }

  /// Like or dislike the post.
  Future profilePostHitLike(index, id, userId) async {
    if (!_hitLikeLock) {
      _hitLikeLock = true;
      try {
        await HttpUtil()
            .post(
          _profilePostList[index].isLiked
              ? 'question/dislike'
              : 'question/like',
          FormData.fromMap({
            'id': '$id',
            'user_id': '$userId',
          }),
        )
            .then(
          (value) {
            print('like!');
            if (value['ErrorCode'] == 0) {
              if (_profilePostList[index].isLiked) {
                _profilePostList[index].likeCount--;
                _profilePostList[index].isLiked = false;
              } else {
                _profilePostList[index].likeCount++;
                _profilePostList[index].isLiked = true;
              }
              notifyListeners();
            } else {
              ToastProvider.error('点赞失败');
            }
            _hitLikeLock = false;
          },
        );
      } catch (e) {
        print(e);
      }
    }
  }

  /// Like or dislike the comment.
  Future commentHitLike(index, id, userId) async {
    if (!_hitLikeLock) {
      _hitLikeLock = true;
      await HttpUtil()
          .post(
        _commentList[index].isLiked ? 'commit/dislike' : 'commit/like',
        FormData.fromMap({
          'id': '$id',
          'user_id': '$userId',
        }),
      )
          .then((value) {
        print('like!');
        if (value['ErrorCode'] == 0) {
          if (_commentList[index].isLiked) {
            _commentList[index].likeCount--;
            _commentList[index].isLiked = false;
          } else {
            _commentList[index].likeCount++;
            _commentList[index].isLiked = true;
          }
          notifyListeners();
        } else {
          ToastProvider.error('点赞失败');
        }
        _hitLikeLock = false;
      });
    }
  }

  /// Like or dislike the comment.
  Future officialCommentHitLike(index, id, userId) async {
    if (!_hitLikeLock) {
      _hitLikeLock = true;
      await HttpUtil()
          .post(
        _officialCommentList[index].isLiked ? 'answer/dislike' : 'answer/like',
        FormData.fromMap({
          'id': '$id',
          'user_id': '$userId',
        }),
      )
          .then((value) {
        print('like!');
        if (value['ErrorCode'] == 0) {
          if (_officialCommentList[index].isLiked) {
            _officialCommentList[index].likeCount--;
            _officialCommentList[index].isLiked = false;
          } else {
            _officialCommentList[index].likeCount++;
            _officialCommentList[index].isLiked = true;
          }
          notifyListeners();
        } else {
          ToastProvider.error('点赞失败');
        }
        _hitLikeLock = false;
      });
    }
  }

  /// Send comment.
  Future sendComment(content, id, userId, onSuccess) async {
    try {
      await HttpUtil()
          .post(
        'commit/add/question',
        FormData.fromMap({
          'user_id': userId,
          'question_id': id,
          'contain': content,
        }),
      )
          .then((value) {
        if (value['ErrorCode'] == 0) {
          ToastProvider.success('评论成功');
          onSuccess();
        } else {
          ToastProvider.error('评论失败');
        }
      });
    } catch (e) {
      print(e);
    }
  }

  /// Upload picture.
  Future uploadImage(Asset data, id, index) async {
    try {
      ByteData byteData = await data.getByteData();
      await HttpUtil()
          .post(
        'image/add',
        FormData.fromMap({
          'user_id': 1,
          'newImg': MultipartFile.fromBytes(
            byteData.buffer.asUint8List(),
            filename: 'p${id}i$index.jpg',
            contentType: MediaType("image", "jpg"),
          ),
          'question_id': id,
        }),
      )
          .then((value) {
        return value['data']['url'];
      });
    } catch (e) {
      print(e);
    }
  }

  /// Send post.
  Future sendPost(title, content, tagId, userId, List<Asset> imgList) async {
    try {
      await HttpUtil()
          .post(
        'question/add',
        FormData.fromMap({
          'user_id': userId,
          'name': title,
          'description': content,
          'tagList': '[$tagId]',
          'campus': 0,
        }),
      )
          .then((value) async {
        for (int index = 0; index < imgList.length; index++) {
          await uploadImage(
              imgList[index], value['data']['question_id'], index);
        }
        return value['data']['question_id'];
      }).then((value) => value);
    } catch (e) {
      print(e);
    }
  }

  /// Rate the official comment.
  Future rate(rating, id, userId, index) async {
    try {
      await HttpUtil()
          .post(
        'answer/commit',
        FormData.fromMap({
          'user_id': userId,
          'answer_id': id,
          'score': rating,
          'commit': '',
        }),
      )
          .then((value) {
        if (value['ErrorCode'] == 0) {
          ToastProvider.success('评价成功');
        } else {
          ToastProvider.error('评价失败');
        }
      });
    } catch (e) {
      print(e);
    }
  }
}