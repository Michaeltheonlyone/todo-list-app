import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController(); 
  bool _isLogin = true;
  bool _isLoading = false;

  void _submit() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;

    if (email.isEmpty || password.isEmpty) return;
    if (!_isLogin && username.isEmpty) return;

    setState(() => _isLoading = true);

    bool success;
    if (_isLogin) {
      final user = await AuthService.login(email, password);
      success = user != null;
    } else {
      success = await AuthService.register(username, email, password);
      if (success) {
        final user = await AuthService.login(email, password);
        success = user != null;
      }
    }

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/splash');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? 'Échec de connexion' : 'Échec d\'inscription'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Animated Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF007AFF), // Blue
                  Color(0xFF5856D6), // Purple
                  Color(0xFFFF2D55), // Pinkish Red
                ],
              ),
            ),
          ),

          // 2. Decorative Circles (Blur Effect)
          Positioned(
            top: -50,
            left: -50,
            child: _buildBlurCircle(200, Colors.white.withOpacity(0.2)),
          ),
          Positioned(
            bottom: -80,
            right: -20,
            child: _buildBlurCircle(300, Colors.white.withOpacity(0.15)),
          ),

          // 3. Glassmorphism Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // Transparent White
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App Logo or Icon
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          _isLogin ? 'Bon retour !' : 'Rejoignez-nous',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                         Text(
                          _isLogin ? 'Gérez vos tâches avec style.' : 'Commencez l\'aventure maintenant.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 32),

                        if (!_isLogin) ...[
                          _buildTextField(_usernameController, 'Nom d\'utilisateur', Icons.person_outline),
                          const SizedBox(height: 16),
                        ],

                        _buildTextField(_emailController, 'Email', Icons.email_outlined),
                        const SizedBox(height: 16),

                        _buildTextField(_passwordController, 'Mot de passe', Icons.lock_outline, obscureText: true),
                        const SizedBox(height: 32),

                        // Main Action Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF007AFF),
                            elevation: 5,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isLoading 
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF007AFF)),
                              )
                            : Text(
                                _isLogin ? 'SE CONNECTER' : 'S\'INSCRIRE',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  letterSpacing: 1.2,
                                ),
                              ),
                        ),
                        
                        const SizedBox(height: 20),

                        // Switch Mode Link
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                             _isLogin ? 'Créer un compte' : 'J\'ai déjà un compte',
                             style: const TextStyle(
                               fontWeight: FontWeight.w600,
                               decoration: TextDecoration.underline,
                               decorationColor: Colors.white,
                             ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: const Color(0xFF007AFF)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9), // Slightly transparent white
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
