import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference forms =
      FirebaseFirestore.instance.collection('forms');

  // used internally for one-time fetches
  final CollectionReference _formCollection =
      FirebaseFirestore.instance.collection('forms');

  Future<void> addForm({
    required String firstName,
    required String lastName,
    required String middleName,
    required String phone,
    required String email,
    required String address,
  }) {
    return forms.add({
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'phone': phone,
      'email': email,
      'address': address,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateForm({
    required String formId,
    required String firstName,
    required String lastName,
    required String middleName,
    required String phone,
    required String email,
    required String address,
  }) {
    return forms.doc(formId).update({
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'phone': phone,
      'email': email,
      'address': address,
    });
  }

  Future<void> deleteForm(String formId) {
    return forms.doc(formId).delete();
  }

  Stream<QuerySnapshot> getFormsStream() {
    return forms.orderBy('timestamp', descending: true).snapshots();
  }

  Future<List<QueryDocumentSnapshot>> getFormsOnce() async {
    final snapshot = await _formCollection.get();
    return snapshot.docs;
  }

  Future<void> wipeAllForms() async {
    final snapshot = await _formCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
