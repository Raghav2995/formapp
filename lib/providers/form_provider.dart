import 'package:flutter/material.dart';
import '../models/form_model.dart';
import '../db/form_database.dart';

class FormProvider with ChangeNotifier {
  List<FormModel> _forms = [];

  List<FormModel> get forms => _forms;

  Future<void> loadForms() async {
    _forms = await FormDatabase.instance.getAllForms();
    notifyListeners();
  }

  Future<void> addForm(FormModel form) async {
    final newForm = await FormDatabase.instance.insertForm(form);
    _forms.add(newForm);
    notifyListeners();
  }

  Future<void> updateForm(FormModel form) async {
    await FormDatabase.instance.updateForm(form);
    await loadForms(); // reload to reflect updates
  }

  Future<void> deleteForm(int id) async {
    await FormDatabase.instance.deleteForm(id);
    _forms.removeWhere((f) => f.id == id);
    notifyListeners();
  }
}
