import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_model.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/service/repository.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/lounge_time_model.dart';

class RoomFavouriteModel extends ChangeNotifier {
  static final Map<String, Classroom> _map = Map();

  Map<String, Classroom> get favourList => _map;

  static final Map<String, Map<String, List<String>>> _classPlan = {};

  Map<String, Map<String, List<String>>> get classPlan => _classPlan;

  refreshData({bool init = false, DateTime dateTime}) async {
    var instance = HiveManager.instance;
    var localData = await instance.getFavourList();

    if (init) {
      List<String> remoteIds = await LoungeRepository.favouriteList;

      // 添加新的收藏到本地
      for (var id in remoteIds) {
        if (!localData.containsKey(id)) {
          var room = await instance.addFavourite(id: id.toString());
          _map[id] = room;
          continue;
        }
        _map[id] = localData[id];
      }

      // 从本地删除旧的收藏
      for (var room in _map.values) {
        if (!remoteIds.contains(room.id)) {
          await LoungeRepository.collect(id: room.id);
        }
      }
    } else {
      _map.clear();
      _map.addAll(localData);
    }

    for (var room in _map.values) {
      _classPlan[room.id] = await instance.getRoomPlans(
        r: room,
        dateTime: dateTime,
      );
    }
  }

  addFavourite({@required Classroom room}) async {
    var instance = HiveManager.instance;
    await instance.addFavourite(clearRoom: room);
    _map.putIfAbsent(room.id, () => room);
    notifyListeners();
  }

  removeFavourite({@required String cId}) async {
    await HiveManager.instance.removeFavourite(cId: cId);
    _map.removeWhere((key, _) => key == cId);
    notifyListeners();
  }

  /// 用于切换用户后,将该用户所有收藏的文章
  replaceAll({@required List<Classroom> list}) async {
    _map.clear();
    await HiveManager.instance.replaceFavourite(list: list);
    list.forEach((room) {
      _map[room.id] = room;
    });
    notifyListeners();
  }

  bool contains({@required String cId}) {
    return _map.containsKey(cId);
  }
}

/// 收藏/取消收藏
class FavouriteModel extends ViewStateModel {
  RoomFavouriteModel globalFavouriteModel;

  FavouriteModel({@required this.globalFavouriteModel});

  collect({@required Classroom room}) async {
    setBusy();
    try {
      debugPrint('++++++++++++++++ collect data: ${room.toJson()} +++++++++++++++++++');
      if (globalFavouriteModel.contains(cId: room.id)) {
        await LoungeRepository.unCollect(id: room.id);
        await globalFavouriteModel.removeFavourite(cId: room.id);
      } else {
        await LoungeRepository.collect(id: room.id);
        await globalFavouriteModel.addFavourite(room: room);
      }
      setIdle();
    } catch (e, s) {
      setError(e, s);
    }
  }
}

class FavouriteListModel extends ViewStateListModel<Classroom> {
  FavouriteListModel._({this.timeModel, this.favouriteModel}) {
    timeModel.addListener(refresh);
    favouriteModel.addListener(refresh);
  }

  static FavouriteListModel _instance;

  factory FavouriteListModel(
          {LoungeTimeModel timeModel, RoomFavouriteModel favouriteModel}) =>
      _init(timeModel, favouriteModel);

  static _init(LoungeTimeModel timeModel, RoomFavouriteModel favouriteModel) {
    if (_instance == null) {
      _instance = FavouriteListModel._(
          timeModel: timeModel, favouriteModel: favouriteModel);
    }
    return _instance;
  }

  final LoungeTimeModel timeModel;
  final RoomFavouriteModel favouriteModel;

  int get currentDay => timeModel.dateTime.weekday;

  List<ClassTime> get classTime => timeModel.classTime;

  List<Classroom> get favourList => favouriteModel.favourList.values.toList();

  Map<String, Map<String, List<String>>> get classPlan =>
      favouriteModel.classPlan;

  @override
  void dispose() {
    timeModel.removeListener(refresh);
    super.dispose();
  }

  @override
  refresh() {
    setBusy();
    if (timeModel.state == ViewState.idle) {
      debugPrint('++++++++++++++++ favourite list get data +++++++++++++++++++');
      super.refresh();
    } else if (timeModel.state == ViewState.error){
      viewState = ViewState.error;
    }
  }

  @override
  Future<List<Classroom>> loadData() async {
    await favouriteModel.refreshData(init: true, dateTime: timeModel.dateTime);
    var list = favouriteModel.favourList.values.toList();
    return list;
  }
}

addFavourites(BuildContext context,
    {Classroom room,
    FavouriteModel model,
    Object tag: 'addFavourite',
    bool playAnim: true}) async {
  await model.collect(room: room);
  if (model.isError) {
    model.showErrorMessage();
  }
}
