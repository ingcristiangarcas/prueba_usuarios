import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                          title: Text(user["name"] ?? "Sin nombre"),
                          subtitle: Text(user["email"] ?? "Sin email"),
                          trailing: isCurrentUser
                              ? IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await provider.deleteUser(uId);
                                  },
                                )
                              : null,
                        ),
                        const Text("📍 Direcciones:"),
                        if (addresses.isEmpty)
                          const Text("❌ No hay direcciones registradas"),
                        ...addresses.entries.map((addrEntry) {
                          final addr = Map<String, dynamic>.from(addrEntry.value);
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text("${addr["city"]}, ${addr["department"]}"),
                            subtitle: Text(addr["country"] ?? ""),
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
