// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usuarios/presentation/screens/address/address_screen.dart';
import '../../providers/user_provider.dart';
import '../login/login_screen.dart';

class UserDetailScreen extends StatelessWidget {
  final String? userId;
  const UserDetailScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final users = provider.users;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuarios y Direcciones"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: users.isEmpty
          ? const Center(child: Text("No hay usuarios registrados"))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: users.entries.map((entry) {
                final uId = entry.key;
                final user = Map<String, dynamic>.from(entry.value);
                final addresses = user["addresses"] != null
                    ? Map<String, dynamic>.from(user["addresses"])
                    : {};
                final isCurrentUser = uId == userId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: const Icon(Icons.person),
                          ),
                          title: Row(
                            children: [
                              Expanded(child: Text(user["name"] ?? "Sin nombre")),
                              if (isCurrentUser)
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.green),
                                  tooltip: "Agregar dirección",
                                  onPressed: () {
                                    // Para agregar nueva dirección
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddressScreen(userId: uId),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                          subtitle: Text(user["email"] ?? "Sin email"),
                        ),
                        const SizedBox(height: 8),
                        const Text("📍 Direcciones:"),
                        if (addresses.isEmpty)
                          const Text("❌ No hay direcciones registradas"),
                        ...addresses.entries.map((addrEntry) {
                          final addrId = addrEntry.key;
                          final addr = Map<String, dynamic>.from(addrEntry.value);

                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text("${addr["city"]}, ${addr["department"]}"),
                            subtitle: Text(addr["country"] ?? ""),
                            trailing: isCurrentUser
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Botón para EDITAR dirección
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        tooltip: "Editar dirección",
                                        onPressed: () {
                                          final countryController = TextEditingController(text: addr["country"]);
                                          final departmentController = TextEditingController(text: addr["department"]);
                                          final cityController = TextEditingController(text: addr["city"]);

                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text("Editar Dirección"),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: countryController,
                                                    decoration: const InputDecoration(labelText: "País"),
                                                  ),
                                                  TextField(
                                                    controller: departmentController,
                                                    decoration: const InputDecoration(labelText: "Departamento"),
                                                  ),
                                                  TextField(
                                                    controller: cityController,
                                                    decoration: const InputDecoration(labelText: "Ciudad"),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx),
                                                  child: const Text("Cancelar"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    addr["country"] = countryController.text;
                                                    addr["department"] = departmentController.text;
                                                    addr["city"] = cityController.text;
                                                    await provider.updateUser(uId, {
                                                      "addresses": user["addresses"]
                                                    });
                                                    Navigator.pop(ctx);
                                                  },
                                                  child: const Text("Guardar"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      // Botón para ELIMINAR dirección
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: "Eliminar dirección",
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text("Confirmar eliminación"),
                                              content: const Text(
                                                  "¿Deseas eliminar esta dirección?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                  child: const Text("Cancelar"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                  child: const Text(
                                                    "Eliminar",
                                                    style:
                                                        TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            user["addresses"].remove(addrId);
                                            await provider.updateUser(uId, {
                                              "addresses": user["addresses"]
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
