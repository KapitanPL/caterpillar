// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rules.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RulesAdapter extends TypeAdapter<Rules> {
  @override
  final int typeId = 1;

  @override
  Rules read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Rules()
      ..appendInGap = fields[0] as bool
      ..canColideWithSelf = fields[1] as bool
      ..semiAutonome = fields[2] as bool
      ..shootingEnabled = fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, Rules obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.appendInGap)
      ..writeByte(1)
      ..write(obj.canColideWithSelf)
      ..writeByte(2)
      ..write(obj.semiAutonome)
      ..writeByte(3)
      ..write(obj.shootingEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RulesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
