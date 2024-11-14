// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FirstPostAdapter extends TypeAdapter<FirstPost> {
  @override
  final int typeId = 2;

  @override
  FirstPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FirstPost(
      data: (fields[0] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, FirstPost obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirstPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
