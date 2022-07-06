import 'package:cloud_firestore/cloud_firestore.dart';

class ImageStore {
  final String? id;
  final String? title;
  final String? date;
  final String? createDate;
  final String? editDate;

  ImageStore({
    this.id,
    this.title,
    this.date,
    this.createDate,
    this.editDate,
  });

  factory ImageStore.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ImageStore(
      id: data?['id'],
      title: data?['title'],
      date: data?['date'],
      createDate: data?['createDate'],
      editDate: data?['editDate'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (title != null) "title": title,
      if (date != null) "date": date,
      if (createDate != null) "createDate": createDate,
      if (editDate != null) "editDate": editDate,
    };
  }
}
