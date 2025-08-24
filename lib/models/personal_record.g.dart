// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonalRecordAdapter extends TypeAdapter<PersonalRecord> {
  @override
  final int typeId = 3;

  @override
  PersonalRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalRecord(
      exerciseName: fields[0] as String,
      maxWeight: fields[1] as double,
      maxReps: fields[2] as int,
      totalVolume: fields[3] as double,
      achievedDate: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.exerciseName)
      ..writeByte(1)
      ..write(obj.maxWeight)
      ..writeByte(2)
      ..write(obj.maxReps)
      ..writeByte(3)
      ..write(obj.totalVolume)
      ..writeByte(4)
      ..write(obj.achievedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
