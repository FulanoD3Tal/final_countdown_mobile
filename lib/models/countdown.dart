final String tableName = 'countdown';
final String columnId = 'id';
final String columnName = 'name';
final String columnCount = 'count';
final String columnGoal = 'goal';
final String columnType = 'type';
final String columnDescription = 'description';

final List<String> columnsCountdown = [
  columnId,
  columnName,
  columnCount,
  columnGoal,
  columnType,
  columnDescription,
];

class Countdown {
  int? id;
  String? name;
  int? count;
  int? goal;
  String? type;
  String? description;

  Countdown();

  Countdown.empty({
    this.name = '',
    this.count = 0,
    this.goal = 0,
    this.type = '',
    this.description = '',
  });

  Countdown.fromMap({required Map<String, Object?> map}) {
    id = int.parse(map[columnId].toString());
    name = map[columnName].toString();
    count = int.parse(map[columnCount].toString());
    goal = int.parse(map[columnGoal].toString());
    type = map[columnType].toString();
    description = map[columnDescription].toString();
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnId: id,
      columnName: name,
      columnCount: count,
      columnGoal: goal,
      columnType: type,
      columnDescription: description,
    };
    return map;
  }
}
