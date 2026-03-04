import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rescuer_forgot_password_screen.dart';

class RescuerLoginScreen extends StatefulWidget {
  const RescuerLoginScreen({super.key});

  @override
  State<RescuerLoginScreen> createState() => _RescuerLoginScreenState();
}

class _RescuerLoginScreenState extends State<RescuerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final doc = await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).get();
      final userType = doc.data()?['user_type'] ?? '';
      if (userType != 'rescuer') {
        await FirebaseAuth.instance.signOut();
        if (mounted) _showErrorDialog('غير مصرح لك', 'هذا الحساب غير مسجل كمنقذ.\nتواصل مع المسؤول للحصول على الصلاحية.');
        return;
      }
      if (mounted) Navigator.of(context).pushReplacementNamed('/rescuer/home');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = 'خطأ في تسجيل الدخول';
        if (e.code == 'user-not-found') msg = 'البريد غير مسجل في النظام';
        if (e.code == 'wrong-password') msg = 'كلمة المرور غير صحيحة';
        if (e.code == 'invalid-email') msg = 'البريد الإلكتروني غير صحيح';
        if (e.code == 'too-many-requests') msg = 'تم تجاوز عدد المحاولات، حاول لاحقاً';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            const Icon(Icons.block, color: Color(0xFFEF5350), size: 28),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          content: Text(message, style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF555555))),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3D5A6C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('حسناً', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity, height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3D5A6C),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 16, top: 20,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        ),
                      ),
                      const Center(
                        child: Text('دخول فريق الإنقاذ',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF3D5A6C).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.security, size: 48, color: Color(0xFF3D5A6C)),
                ),
                const SizedBox(height: 12),
                const Text('للمنقذين المعتمدين فقط', style: TextStyle(fontSize: 14, color: Color(0xFF757575))),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('البريد الإلكتروني', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                              hintText: 'أدخل البريد الإلكتروني',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
                              filled: true, fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
                          ),

                          const SizedBox(height: 20),

                          const Text('كلمة المرور', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'أدخل كلمة المرور',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
                              filled: true, fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
                          ),

                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RescuerForgotPasswordScreen())),
                              child: const Text('نسيت كلمة المرور؟', style: TextStyle(fontSize: 13, color: Color(0xFF3D5A6C))),
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity, height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3D5A6C),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('تسجيل الدخول',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFE082)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 18),
                                SizedBox(width: 8),
                                Expanded(child: Text('الدخول مقتصر على المنقذين المعتمدين من الإدارة',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
