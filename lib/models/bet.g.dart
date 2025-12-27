part of 'bet.dart';

class GameTypeAdapter extends TypeAdapter<GameType> {
  @override
  final int typeId = 0;

  @override
  GameType read(BinaryReader reader) {
    return GameType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, GameType obj) {
    writer.writeByte(obj.index);
  }
}

class BetTypeAdapter extends TypeAdapter<BetType> {
  @override
  final int typeId = 1;

  @override
  BetType read(BinaryReader reader) {
    return BetType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, BetType obj) {
    writer.writeByte(obj.index);
  }
}

class BetAdapter extends TypeAdapter<Bet> {
  @override
  final int typeId = 2;

  @override
  Bet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bet(
      bettorName: fields[0] as String,
      gameType: fields[1] as GameType,
      betType: fields[2] as BetType,
      numbers: fields[3] as String,
      amount: fields[4] as double,
      drawTime: fields[5] as String,
      createdAt: fields[6] as DateTime,
      isWinner: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Bet obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.bettorName)
      ..writeByte(1)
      ..write(obj.gameType)
      ..writeByte(2)
      ..write(obj.betType)
      ..writeByte(3)
      ..write(obj.numbers)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.drawTime)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isWinner);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BetAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
