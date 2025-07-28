import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'form_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = AuthService();
  final ValueNotifier<bool> isSyncOn = ValueNotifier<bool>(true);

  void _showProfileMenu(BuildContext context, Offset offset, String? email) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(offset, offset),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              const Icon(Icons.email, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  email ?? "No email",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: ValueListenableBuilder<bool>(
            valueListenable: isSyncOn,
            builder: (context, value, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Sync"),
                  Switch(
                    value: value,
                    onChanged: (val) => isSyncOn.value = val,
                  ),
                ],
              );
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              // implement settings page if needed
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_forever),
            title: const Text("Wipe all notes"),
            onTap: () {
              Navigator.pop(context);
              _confirmWipeNotes();
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              auth.signOut();
            },
          ),
        ),
      ],
    );
  }

  void _confirmWipeNotes() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Wipe all notes?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Delete All", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);
              await FirestoreService().wipeAllForms();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All notes deleted.")),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forms'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                _showProfileMenu(context, details.globalPosition, currentUser?.email);
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/profile_placeholder.png'), // add your own logo here
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getFormsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final forms = snapshot.data!.docs;

          if (forms.isEmpty) {
            return const Center(child: Text('No forms found.'));
          }

          return ListView.builder(
            itemCount: forms.length,
            itemBuilder: (context, index) {
              final form = forms[index];
              final data = form.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['firstName'] ?? 'No name'),
                subtitle: Text(data['phone'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormScreen(
                              formId: form.id,
                              initialData: data,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        FirestoreService().deleteForm(form.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
