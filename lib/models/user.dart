import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password; // 🔐 (เก็บแบบ raw หรือแฮชได้)

  @HiveField(3)
  String name;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
  });
}
