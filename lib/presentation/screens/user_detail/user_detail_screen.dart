import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../login/login_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final String? userId; // id del usuario que ingresó
  const UserDetailScreen({super.key, this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        title: const Text(
          "Usuarios y Direcciones",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Cerrar sesión",
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
      body: StreamBuilder(
        stream: _db.child("users").onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
                child: Text("No hay usuarios registrados.",
                    style: TextStyle(fontSize: 16)));
          }

          final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: data.entries.map((entry) {
              final userId = entry.key;
              final user = Map<String, dynamic>.from(entry.value);

              final addresses = user["addresses"] != null
                  ? Map<String, dynamic>.from(user["addresses"])
                  : {};

              final isCurrentUser = userId == widget.userId;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Usuario
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          radius: 28,
                          child: const Icon(Icons.person,
                              size: 32, color: Colors.blue),
                        ),
                        title: Text(
                          user["name"] ?? "Sin nombre",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          user["email"] ?? "Sin email",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: isCurrentUser
                            ? IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                tooltip: "Eliminar usuario",
                                onPressed: () {
                                  _deleteUser(userId);
                                },
                              )
                            : null,
                      ),

                      const SizedBox(height: 10),

                      // Título direcciones
                      const Text(
                        "📍 Direcciones:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (addresses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("❌ No hay direcciones registradas.",
                              style: TextStyle(color: Colors.grey)),
                        ),

                      // Lista de direcciones
                      ...addresses.entries.map((addrEntry) {
                        final addrId = addrEntry.key;
                        final address =
                            Map<String, dynamic>.from(addrEntry.value);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${address["city"]}, ${address["department"]}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      address["country"] ?? "",
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                              if (isCurrentUser)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        _editAddress(userId, addrId, address);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        _deleteAddress(userId, addrId);
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _editAddress(
      String userId, String addrId, Map<String, dynamic> address) {
    final countryCtrl = TextEditingController(text: address["country"]);
    final deptCtrl = TextEditingController(text: address["department"]);
    final cityCtrl = TextEditingController(text: address["city"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Editar Dirección"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: countryCtrl,
                decoration: const InputDecoration(labelText: "País"),
              ),
              TextField(
                controller: deptCtrl,
                decoration: const InputDecoration(labelText: "Departamento"),
              ),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: "Ciudad"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _db.child("users/$userId/addresses/$addrId").update({
                  "country": countryCtrl.text,
                  "department": deptCtrl.text,
                  "city": cityCtrl.text,
                });
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600),
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _deleteAddress(String userId, String addrId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Eliminar Dirección"),
          content: const Text("¿Seguro que deseas eliminar esta dirección?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _db.child("users/$userId/addresses/$addrId").remove();
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Eliminar Usuario"),
          content: const Text(
              "¿Seguro que deseas eliminar este usuario junto con todas sus direcciones?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _db.child("users/$userId").remove();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }
}
