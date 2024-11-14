// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final int typeId = 0;

  @override
  Person read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Person(
      user_name: fields[0] as String,
      selfInfo: fields[1] as String,
      gender: fields[2] as String,
      avatar: fields[3] as String,
      user_id: fields[4] as String,
      password: fields[6] as String,
      email: fields[5] as String,
      likes_num: fields[7] as int,
      birthday: fields[8] as String,
      collects_num: fields[9] as int,
      followers_num: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.user_name)
      ..writeByte(1)
      ..write(obj.selfInfo)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.user_id)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.password)
      ..writeByte(7)
      ..write(obj.likes_num)
      ..writeByte(8)
      ..write(obj.birthday)
      ..writeByte(9)
      ..write(obj.collects_num)
      ..writeByte(10)
      ..write(obj.followers_num);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
