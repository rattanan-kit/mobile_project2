import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ฟังก์ชันสมัครสมาชิก
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Error Register: $e");
      return null;
    }
  }

  // ฟังก์ชันล็อกอิน
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> logout() async {
    await _auth.signOut();
  }
}
