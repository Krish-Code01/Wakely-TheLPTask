import 'dart:convert';

class AlarmModel {
  String? id;
  String userId;
  DateTime alarmDateTime;
  String label;
  bool isActive;
  RepeatOption repeatOption;
  List<int> customRepeatDays;

  AlarmModel({
    this.id,
    required this.userId,
    required this.alarmDateTime,
    required this.label,
    required this.isActive,
    this.repeatOption = RepeatOption.noRepeat,
    required this.customRepeatDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'alarmDateTime': alarmDateTime.toIso8601String(),
      'label': label,
      'isActive': isActive ? 1 : 0,
      'repeatOption': repeatOption.toString().split('.').last,
      'customRepeatDays': customRepeatDays.toString(),
    };
  }

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'].toString(),
      userId: map['userId'].toString(),
      alarmDateTime: DateTime.parse(map['alarmDateTime'] as String),
      label: map['label'] as String,
      isActive: map['isActive'] == 1 ? true : false,
      repeatOption: RepeatOption.values.firstWhere(
        (e) => e.toString().split('.').last == map['repeatOption'],
        orElse: () => RepeatOption.noRepeat,
      ),
      customRepeatDays: (jsonDecode(map['customRepeatDays']) as List<dynamic>)!
          .map((e) => e as int)
          .toList(),
    );
  }
}

enum RepeatOption { noRepeat, daily, custom }
