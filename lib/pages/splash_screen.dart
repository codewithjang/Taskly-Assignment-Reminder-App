import 'package:flutter/material.dart';
import 'package:assignment_reminder_app/pages/login_page.dart';
import 'package:assignment_reminder_app/pages/register_page.dart';
import 'package:assignment_reminder_app/pages/home_page.dart';
import 'package:assignment_reminder_app/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  bool _checkingLogin = true; // 👈 ใช้เพื่อรอโหลดข้อมูลล็อกอิน

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 1),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // ให้ splash animation ทำงานแป๊บหนึ่งก่อน
      await Future.delayed(const Duration(seconds: 2));

      // ลองโหลด user
      final user = AuthService.getCurrentUser();

      if (!mounted) return;

      if (user != null) {
        // พบผู้ใช้ → ไปหน้า Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        // ไม่พบผู้ใช้ → แสดงปุ่ม Login/Register
        setState(() {
          _checkingLogin = false;
        });
      }
    } catch (e) {
      // ถ้า error → แสดงปุ่มแทน
      if (mounted) {
        setState(() {
          _checkingLogin = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/bg_loading.png',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.3),
            colorBlendMode: BlendMode.darken,
          ),

          Center(
            child: Image.asset(
              'assets/note.gif',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),

          // LOGO + ANIMATION
          Align(
            alignment: Alignment.topCenter, // เปลี่ยนเป็นด้านบน
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.only(top: 120.0), // ระยะจากด้านบน
                child: const Text(
                  'Taskly',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(2, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔥 หากยังโหลดสถานะ → ซ่อนปุ่ม
          if (!_checkingLogin)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGIN BUTTON
                    SizedBox(
                      width: 260,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "เข้าสู่ระบบ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // REGISTER BUTTON
                    SizedBox(
                      width: 260,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "สมัครสมาชิก",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // SKIP BUTTON
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      },
                      child: const Text(
                        "ข้าม",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
