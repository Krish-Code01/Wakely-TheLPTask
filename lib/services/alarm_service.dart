import 'dart:developer';

import 'package:lp_task/model/alarm_model.dart';
import 'package:sqflite/sqflite.dart';

const String tableAlarm = 'alarm';
const String columnId = 'id';
const String columnUserId = 'userId';
const String columnLabel = 'label';
const String columnDateTime = 'alarmDateTime';
const String columnIsActive = 'isActive';
const String columnRepeatOption = 'repeatOption';
const String columnCustomRepeatDays = 'customRepeatDays';

class AlarmService {
  static Database? _database;
  static AlarmService? _alarm;

  AlarmService._createInstance();

  factory AlarmService() {
    if (_alarm == null) {
      _alarm = AlarmService._createInstance();
    }
    return _alarm!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "alarm.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableAlarm ( 
          $columnId integer primary key autoincrement, 
          $columnUserId text not null,
          $columnLabel text not null,
          $columnDateTime text not null,
          $columnIsActive integer not null,
          $columnRepeatOption text not null,
          $columnCustomRepeatDays text)
        ''');
      },
    );
    log("--------Initialized Database----------");
    return database;
  }

  void insertAlarm(AlarmModel alarmInfo) async {
    var db = await this.database;
    var result = await db.insert(
      tableAlarm,
      alarmInfo.toMap(),
    );
    print('result : $result');
  }

  Future<List<AlarmModel>> getAlarmsForUser(String userId) async {
    List<AlarmModel> _alarms = [];
    var db = await this.database;
    var result = await db.query(
      tableAlarm,
      where: '$columnUserId = ?',
      whereArgs: [userId],
    );
    result.forEach((element) {
      var alarmInfo = AlarmModel.fromMap(element);
      _alarms.add(alarmInfo);
    });
    return _alarms;
  }

  Future<int> updateAlarm(AlarmModel alarmInfo) async {
    var db = await this.database;
    return await db.update(
      tableAlarm,
      alarmInfo.toMap(),
      where: '$columnId = ?',
      whereArgs: [alarmInfo.id],
    );
  }

  Future<int> delete(int id) async {
    var db = await this.database;
    return await db.delete(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
  }
}
