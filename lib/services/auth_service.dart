import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  static const userBoxName = "users";
  static const authBoxName = "authCache";

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(UserAdapter());
    }

    await Hive.openBox<User>(userBoxName);
    await Hive.openBox(authBoxName);
  }

  static Box<User> get _userBox => Hive.box<User>(userBoxName);
  static Box get _authBox => Hive.box(authBoxName);

  static final fb.FirebaseAuth _fb = fb.FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --------------------------------------------------
  // REGISTER (Firebase -> Firestore -> Hive)
  // --------------------------------------------------
  static Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Firebase Auth
      final cred = await _fb.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = cred.user!.uid;

      // Firestore profile
      await _db.collection("users").doc(uid).set({
        "name": name.trim(),
        "email": email.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Hive cache
      await _userBox.put(
        uid,
        User(
          id: uid,
          email: email.trim(),
          password: password.trim(),
          name: name.trim(),
        ),
      );

      await _authBox.put("currentUser", uid);

      return null;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") return "อีเมลถูกใช้งานแล้ว";
      if (e.code == "weak-password") return "รหัสผ่านอ่อนเกินไป";
      return e.message;
    } catch (e) {
      return "เกิดข้อผิดพลาด: $e";
    }
  }

  // --------------------------------------------------
  // LOGIN
  // --------------------------------------------------
  static Future<String?> login(String email, String password) async {
    try {
      final cred = await _fb.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final uid = cred.user!.uid;

      // ถ้ายังไม่มีใน Hive → ดึงจาก Firestore
      if (!_userBox.containsKey(uid)) {
        final doc = await _db.collection("users").doc(uid).get();

        if (doc.exists) {
          final data = doc.data()!;
          await _userBox.put(
            uid,
            User(
              id: uid,
              email: data["email"] ?? email.trim(),
              password: password.trim(),
              name: data["name"] ?? "",
            ),
          );
        }
      }

      await _authBox.put("currentUser", uid);
      return null;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == "wrong-password") return "รหัสผ่านไม่ถูกต้อง";
      if (e.code == "user-not-found") return "ไม่พบบัญชีนี้";
      return e.message;
    } catch (e) {
      return "เกิดข้อผิดพลาด: $e";
    }
  }

  // --------------------------------------------------
  // CURRENT USER
  // --------------------------------------------------
  static User? getCurrentUser() {
    final fbUser = _fb.currentUser;
    if (fbUser == null) return null;
    return _userBox.get(fbUser.uid);
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------
  static Future<void> logout() async {
    await _fb.signOut();
    await _authBox.delete("currentUser");
  }
}
