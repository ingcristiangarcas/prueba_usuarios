import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../register/register_screen.dart';
import '../user_detail/user_detail_screen.dart';
import 'package:collection/collection.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UserProvider>();
    await provider.fetchUsers();

    // Usando firstWhereOrNull para evitar errores de tipo
    final user = provider.users.entries.firstWhereOrNull(
      (e) =>
          e.value["email"] == _emailController.text.trim() &&
          e.value["password"] == _passwordController.text.trim(),
    );

    if (user != null) {
      // Usuario encontrado, navegar
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetailScreen(userId: user.key),
          ),
        );
      }
    } else {
      // Usuario no encontrado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Usuario o contraseña incorrectos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Correo"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true,
                validator: (v) =>
                    v == null || v.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text("Ingresar")),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("¿No tienes cuenta? Regístrate"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
