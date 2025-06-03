import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'login_page.dart';

/// Halaman untuk melakukan registrasi pengguna baru
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final user = User(
      id: const Uuid().v4(),
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      createdAt: DateTime.now().toIso8601String(),
    );
    final result = await UserService().register(user);
    setState(() {
      _loading = false;
    });
    if (result) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      setState(() {
        _error = 'Email sudah terdaftar atau error saat register';
      });
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.indigo),
          filled: true,
          fillColor: const Color(0xFFE8EAF6),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Register'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  'Inventario🤌',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(_nameController, 'Nama'),
                _buildTextField(_emailController, 'Email'),
                _buildTextField(
                  _passwordController,
                  'Password',
                  isPassword: true,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 20),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _register,
                      child: const Text(
                        'Register',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
