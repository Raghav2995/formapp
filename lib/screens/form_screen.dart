import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/form_model.dart';
import '../providers/form_provider.dart';

class FormScreen extends StatefulWidget {
  final FormModel? form;
  const FormScreen({super.key, this.form});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController middleNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.form?.firstName ?? '');
    middleNameController = TextEditingController(text: widget.form?.middleName ?? '');
    lastNameController = TextEditingController(text: widget.form?.lastName ?? '');
    phoneController = TextEditingController(text: widget.form?.phone ?? '');
    addressController = TextEditingController(text: widget.form?.address ?? '');
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void saveForm() {
    if (_formKey.currentState!.validate()) {
      final formProvider = Provider.of<FormProvider>(context, listen: false);
      final form = FormModel(
        id: widget.form?.id,
        firstName: firstNameController.text,
        middleName: middleNameController.text,
        lastName: lastNameController.text,
        phone: phoneController.text,
        address: addressController.text,
      );

      if (widget.form == null) {
        formProvider.addForm(form);
      } else {
        formProvider.updateForm(form);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.form == null ? 'Add Form' : 'Edit Form')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) => value!.isEmpty ? 'Enter first name' : null,
              ),
              TextFormField(
                controller: middleNameController,
                decoration: const InputDecoration(labelText: 'Middle Name'),
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) => value!.isEmpty ? 'Enter last name' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
