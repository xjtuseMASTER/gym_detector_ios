// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 1;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      isInApp_Reminder: fields[0] as bool?,
      outInApp_Reminder: fields[1] as bool?,
      isLightTheme: fields[2] as bool?,
      isReleaseVisible: fields[4] as bool?,
      isCollectsVisible: fields[5] as bool?,
      isLikesVisible: fields[3] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.isInApp_Reminder)
      ..writeByte(1)
      ..write(obj.outInApp_Reminder)
      ..writeByte(2)
      ..write(obj.isLightTheme)
      ..writeByte(3)
      ..write(obj.isLikesVisible)
      ..writeByte(4)
      ..write(obj.isReleaseVisible)
      ..writeByte(5)
      ..write(obj.isCollectsVisible);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
