// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PeriodRecordAdapter extends TypeAdapter<PeriodRecord> {
  @override
  final int typeId = 0;

  @override
  PeriodRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PeriodRecord(
      startDate: fields[0] as DateTime,
      endDate: fields[1] as DateTime?,
      symptoms: (fields[2] as Map?)?.cast<String, bool>(),
      flow: fields[3] as int,
      notes: fields[4] as String,
      mood: (fields[5] as Map?)?.cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, PeriodRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.endDate)
      ..writeByte(2)
      ..write(obj.symptoms)
      ..writeByte(3)
      ..write(obj.flow)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.mood);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
