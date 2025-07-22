import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/form_provider.dart';
import '../models/form_model.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<FormProvider>(context, listen: false).loadForms();
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Forms')),
      body: ListView.builder(
        itemCount: formProvider.forms.length,
        itemBuilder: (context, index) {
          final form = formProvider.forms[index];
          return ListTile(
            title: Text('${form.firstName} ${form.lastName}'),
            subtitle: Text(form.phone),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FormScreen(form: form),
                      ),
                    ).then((_) => formProvider.loadForms());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => formProvider.deleteForm(form.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormScreen()),
          ).then((_) => formProvider.loadForms());
        },
      ),
    );
  }
}
