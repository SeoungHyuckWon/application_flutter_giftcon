//import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_application_giftcon/database/db.dart';
// import 'package:path_provider/path_provider.dart';

class MyListPage extends StatefulWidget {
  const MyListPage({Key? key, required this.MyID}) : super(key: key);
  final String MyID;
  @override
  State<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> streamData;
  @override
  late BuildContext _context;
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(body: _buildList(context));
  }

  Widget _buildList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: db.collection(widget.MyID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView(
            padding: EdgeInsets.symmetric(vertical: 30),
            children: snapshot.data!.docs.map((doc) {
              Map? k = doc.data() as Map?;
              var title = k!['title'];
              var date = k['date'];
              var id = k['id'];
              var createData = k['createData'];
              var editData = k['editData'];
              return InkWell(
                  onTap: (() async {
                    // String dir;
                    // if (Platform.isAndroid) {
                    //   dir = (await getExternalStorageDirectory())!.path;
                    // } else if (Platform.isIOS) {
                    //   dir = (await getApplicationDocumentsDirectory()).path;
                    // } else {
                    //   dir = '';
                    // }
                    // final String fileName = id + '.jpg';
                    String url = await FirebaseStorage.instance
                        .ref()
                        .child(id)
                        .getDownloadURL();
                    await showDialog(
                        context: context,
                        builder: (_) => imageDialog(id, title, url, context));
                  }),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.lightBlue),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text(title),
                      subtitle: Text('사용가능날짜: ' + date),
                      trailing: PopupMenuButton(
                          icon: Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Text("사용 완료"),
                                  value: 1,
                                  onTap: () async {
                                    final desertRef = FirebaseStorage.instance
                                        .ref()
                                        .child(id);
                                    await desertRef.delete();
                                    await db
                                        .collection(widget.MyID)
                                        .doc(id)
                                        .delete()
                                        .then(
                                          (doc) => print("Document deleted"),
                                          onError: (e) => print(
                                              "Error updating document $e"),
                                        );
                                  },
                                ),
                                PopupMenuItem(
                                  child: Text("날짜 수정"),
                                  value: 2,
                                )
                              ]),
                    ),
                  ));
            }).toList(),
          );
        }
      },
    );
  }

  Widget imageDialog(id, text, path, context) {
    return Dialog(
      // backgroundColor: Colors.transparent,
      // elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$text',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close_rounded),
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
          Container(
            width: 220,
            height: 500,
            child: Image.network(
              '$path',
              fit: BoxFit.cover,
            ),
            // child: Image.file(
            //   File('$path'),
            //   fit: BoxFit.cover,
            // ),
          ),
        ],
      ),
    );
  }
}
