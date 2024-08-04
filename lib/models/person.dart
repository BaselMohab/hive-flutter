import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 0)
class Person extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int age;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String gender;

  Person({
    required this.name,
    required this.age,
    required this.email,
    required this.gender,
  });
}
