import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/locations.dart';
import '../../../domain/entities/address.dart';
import '../../providers/user_provider.dart';
import '../user_detail/user_detail_screen.dart';

class AddressScreen extends StatefulWidget {
  final String userId;
  const AddressScreen({super.key, required this.userId});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  String? _selectedCountry;
  String? _selectedDepartment;
  String? _selectedCity;

  void _saveAddress() async {
    if (_selectedCountry != null &&
        _selectedDepartment != null &&
        _selectedCity != null) {

      final id = const Uuid().v4();
      final address = Address(
        country: _selectedCountry!,
        department: _selectedDepartment!,
        city: _selectedCity!,
      );

      final provider = context.read<UserProvider>();
      final user = provider.users[widget.userId];
      user["addresses"] = user["addresses"] ?? {};
      user["addresses"][id] = address.toJson();
      await provider.updateUser(widget.userId, {"addresses": user["addresses"]});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Dirección guardada")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserDetailScreen(userId: widget.userId)),
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
    final departments = _selectedCountry != null
        ? locations[_selectedCountry!]!.keys.toList()
        : [];
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
