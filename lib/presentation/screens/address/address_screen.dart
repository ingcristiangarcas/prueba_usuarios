import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/locations.dart';
import '../../../domain/entities/address.dart';
import '../user_detail/user_detail_screen.dart'; // 👈 importa la pantalla 3

class AddressScreen extends StatefulWidget {
  final String userId; // pasamos el id del usuario creado en pantalla 1
  const AddressScreen({super.key, required this.userId});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  String? _selectedCountry;
  String? _selectedDepartment;
  String? _selectedCity;

  Future<void> _saveAddress() async {
    if (_selectedCountry != null &&
        _selectedDepartment != null &&
        _selectedCity != null) {
      final id = const Uuid().v4();
      final address = Address(
        country: _selectedCountry!,
        department: _selectedDepartment!,
        city: _selectedCity!,
      );

      try {
        await _db
            .child("users/${widget.userId}/addresses/$id")
            .set(address.toJson());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Dirección guardada")),
          );

          // 👇 Navegar a la pantalla 3 después de guardar
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailScreen(userId: widget.userId),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona todos los campos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final countries = locations.keys.toList();
    final departments =
        _selectedCountry != null ? locations[_selectedCountry!]!.keys.toList() : [];
    final cities = (_selectedCountry != null && _selectedDepartment != null)
        ? locations[_selectedCountry!]![_selectedDepartment!]!
        : [];

    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Dirección")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              decoration: const InputDecoration(labelText: "País"),
              onChanged: (val) {
                setState(() {
                  _selectedCountry = val;
                  _selectedDepartment = null;
                  _selectedCity = null;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              items: departments
                  .map<DropdownMenuItem<String>>(
                    (d) => DropdownMenuItem<String>(
                      value: d,
                      child: Text(d),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(labelText: "Departamento"),
              onChanged: (val) {
                setState(() {
                  _selectedDepartment = val;
                  _selectedCity = null;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              items: cities
                  .map<DropdownMenuItem<String>>(
                    (m) => DropdownMenuItem<String>(
                      value: m,
                      child: Text(m),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(labelText: "Municipio"),
              onChanged: (val) => setState(() => _selectedCity = val),
            ),
            const Spacer(),
            // 👇 Botón actualizado con Material 3
            FilledButton.icon(
              onPressed: _saveAddress,
              icon: const Icon(Icons.save),
              label: const Text("Guardar y continuar"),
            ),
          ],
        ),
      ),
    );
  }
}
