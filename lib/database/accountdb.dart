import 'package:cloud_firestore/cloud_firestore.dart';

class AccountStore {
  final String? field;
  final String? id;
  final String? password;
  final String? createDate;
  final String? editDate;

  AccountStore({
    this.field,
    this.id,
    this.password,
    this.createDate,
    this.editDate,
  });

  factory AccountStore.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return AccountStore(
      field: data?['field'],
      id: data?['id'],
      password: data?['password'],
      createDate: data?['createDate'],
      editDate: data?['editDate'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (field != null) "field": field,
      if (id != null) "id": id,
      if (password != null) "password": password,
      if (createDate != null) "createDate": createDate,
      if (editDate != null) "editDate": editDate,
    };
  }
}
