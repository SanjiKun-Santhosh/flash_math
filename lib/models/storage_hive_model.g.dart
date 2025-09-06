// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserHiveStorageAdapter extends TypeAdapter<UserHiveStorage> {
  @override
  final int typeId = 1;

  @override
  UserHiveStorage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserHiveStorage(
      id: fields[0] as String,
      profilePicture: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserHiveStorage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profilePicture);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHiveStorageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
