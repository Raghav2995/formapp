import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'form_screen.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = AuthService();
  bool syncOn = true;
  DateTime? lastSync;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forms'),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(child: Icon(Icons.person)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'email',
                child: Row(
                  children: const [
                    Icon(Icons.email, size: 20),
                    SizedBox(width: 8),
                    Text('Logged in as'),
                  ],
                ),
              ),
              PopupMenuItem(
                enabled: false,
                child: Text(FirebaseAuth.instance.currentUser?.email ?? 'No Email'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'settings',
                child: const Text('Settings'),
              ),
              PopupMenuItem(
                value: 'toggle_sync',
                child: Row(
                  children: [
                    const Text('Sync'),
                    const Spacer(),
                    Switch(
                      value: syncOn,
                      onChanged: (value) {
                        setState(() {
                          syncOn = value;
                          lastSync = DateTime.now();
                        });
                      },
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'wipe',
                child: const Text('Wipe All Notes'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: const Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                auth.signOut();
              } else if (value == 'wipe') {
                _confirmWipeDialog();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDashboard(),
          Expanded(
            child: syncOn
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService().getFormsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('Something went wrong'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final forms = snapshot.data!.docs;
                      lastSync = DateTime.now(); // update last sync time

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
                  )
                : const Center(child: Text('Sync is turned off')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Form'),
      ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.sync, size: 20),
              const SizedBox(width: 8),
              Text(syncOn ? 'Sync is ON' : 'Sync is OFF'),
              const Spacer(),
              Text(
                lastSync != null ? 'Last sync: ${_formatTime(lastSync!)}' : 'Not synced yet',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmWipeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Wipe'),
        content: const Text('Are you sure you want to delete all forms? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final forms = await FirestoreService().getFormsOnce();
              for (var doc in forms) {
                await FirestoreService().deleteForm(doc.id);
              }
            },
            child: const Text('Wipe All'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
