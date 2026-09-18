import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(
                labelText: 'Password (6 ตัวขึ้นไป)',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var user = await _auth.login(
                      _emailCtrl.text,
                      _passwordCtrl.text,
                    );
                    if (user == null)
                      setState(() => _errorMessage = 'ล็อกอินล้มเหลว');
                  },
                  child: const Text('Login'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var user = await _auth.register(
                      _emailCtrl.text,
                      _passwordCtrl.text,
                    );
                    if (user == null)
                      setState(() => _errorMessage = 'สมัครล้มเหลว');
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
