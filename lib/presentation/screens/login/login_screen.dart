import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../domain/entities/user.dart';
import '../address/address_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _birthdate;

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  bool _isLogin = true; // 🔑 alterna entre login y registro

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _birthdate = date);
    }
  }

  Future<void> _loginUser() async {
    try {
      final snapshot = await _db.child("users").get();

      if (snapshot.exists) {
        final users = Map<String, dynamic>.from(snapshot.value as Map);

        bool found = false;
        users.forEach((key, value) {
          final user = Map<String, dynamic>.from(value);
          if (user["email"] == _emailController.text.trim() &&
              user["password"] == _passwordController.text.trim()) {
            found = true;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddressScreen(userId: key),
              ),
            );
          }
        });

        if (!found) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Usuario o contraseña incorrectos")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al iniciar sesión: $e")),
      );
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate() && _birthdate != null) {
      try {
        final id = const Uuid().v4();
        final user = User(
          id: id,
          name: _nameController.text.trim(),
          lastname: _lastnameController.text.trim(),
          birthdate: _birthdate!.toIso8601String(),
          addresses: const [],
        );

        // Guardamos en Firebase con correo y contraseña
        await _db.child("users/$id").set({
          ...user.toJson(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        });

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddressScreen(userId: id),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Usuario registrado")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error al registrar: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos")),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? "Iniciar Sesión" : "Registro"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🔹 Campos comunes (correo y contraseña primero)
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Correo"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Campo requerido" : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Contraseña"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 16),

                // 🔹 Campos extra solo si es registro
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                    validator: (value) => value == null || value.isEmpty
                        ? "Campo requerido"
                        : null,
                  ),
                  TextFormField(
                    controller: _lastnameController,
                    decoration: const InputDecoration(labelText: "Apellido"),
                    validator: (value) => value == null || value.isEmpty
                        ? "Campo requerido"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _birthdate == null
                              ? "Selecciona tu fecha de nacimiento"
                              : "Nacimiento: ${_formatDate(_birthdate!)}",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _pickDate,
                        child: const Text("Elegir fecha"),
                      )
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // 🔹 Botón principal
                ElevatedButton(
                  onPressed: _isLogin ? _loginUser : _registerUser,
                  child: Text(_isLogin ? "Ingresar" : "Siguiente"),
                ),
                const SizedBox(height: 10),

                // 🔹 Toggle entre login y registro
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(_isLogin
                      ? "¿No tienes cuenta? Crear una"
                      : "¿Ya tienes cuenta? Inicia sesión"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
