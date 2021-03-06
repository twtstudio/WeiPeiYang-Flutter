import 'package:hive/hive.dart';
import 'area.dart';
import 'building.dart';
import 'classroom.dart';

enum ResultType { room, area, building }

class ResultEntry {
  final Area area;
  final Classroom room;
  final Building building;

  ResultEntry({this.area, this.room, this.building});
}

class HistoryEntry {
  String bName;
  String cName;
  String aId;
  String bId;
  String cId;
  String date;

  HistoryEntry(
      [this.bName, this.cName, this.aId, this.bId, this.cId, this.date]);

  Map toJson() =>
      {"aId": aId, "bId": bId, "cId": cId, "cName": cName, "bName": bName};
}

class SearchHistoryAdapter extends TypeAdapter<HistoryEntry> {
  @override
  final int typeId = 6;

  @override
  HistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryEntry(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.bName)
      ..writeByte(1)
      ..write(obj.cName)
      ..writeByte(2)
      ..write(obj.aId)
      ..writeByte(3)
      ..write(obj.bId)
      ..writeByte(4)
      ..write(obj.cId)
      ..writeByte(5)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
