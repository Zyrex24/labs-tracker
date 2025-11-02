import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(AppDatabase db) : super(db);

  // Get local user (single user)
  Future<User?> getLocalUser() => select(users).getSingleOrNull();

  // Get all users
  Future<List<User>> getAllUsers() => select(users).get();

  // Insert user
  Future<void> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  // Update user
  Future<void> updateUser(User user) {
    return update(users).replace(user);
  }

  // Watch local user
  Stream<User?> watchLocalUser() => select(users).watchSingleOrNull();
}

