import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/user.dart';
import '../../providers/user_provider.dart';
import '../address/address_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _birthdate;

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _birthdate = date);
  }

  void _register() async {
    if (!_formKey.currentState!.validate() || _birthdate == null) return;

    final id = const Uuid().v4();
    final user = User(
      id: id,
      name: _nameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      birthdate: _birthdate!.toIso8601String(),
      addresses: const [],
    );

    try {
      await context
          .read<UserProvider>()
          .addUser(user, _emailController.text.trim(), _passwordController.text.trim());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AddressScreen(userId: id),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Usuario registrado")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al registrar: $e")),
      );
    }
  }

  String _formatDate(DateTime date) =>
      "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Correo"),
                  validator: (v) => v == null || v.isEmpty ? "Campo requerido" : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Contraseña"),
                  validator: (v) => v == null || v.isEmpty ? "Campo requerido" : null,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nombre"),
                  validator: (v) => v == null || v.isEmpty ? "Campo requerido" : null,
                ),
                TextFormField(
                  controller: _lastnameController,
                  decoration: const InputDecoration(labelText: "Apellido"),
                  validator: (v) => v == null || v.isEmpty ? "Campo requerido" : null,
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
                    ElevatedButton(onPressed: _pickDate, child: const Text("Elegir fecha")),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _register, child: const Text("Siguiente")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
