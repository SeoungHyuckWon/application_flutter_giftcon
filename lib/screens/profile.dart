import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyProfilePage extends StatelessWidget {
  MyProfilePage({Key? key, required this.MyID}) : super(key: key);
  final String MyID;
  @override
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> streamData;
  late BuildContext _context;
  final storage = new FlutterSecureStorage();
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 40)),
        Text(
          'My Profile',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Divider(color: Colors.lightBlue, thickness: 2.0),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        _buildList(context)
      ])),
    );
  }

  Widget _buildList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          db.collection('account').where('field', isEqualTo: MyID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          Map? k = snapshot.data!.docs.first.data() as Map?;
          var id = k!['id'];
          var createDate = k['createDate'];
          var editDate = k['editDate'];
          return Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Text(
                    'My Account: ' + id,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  Text(
                    'Create Date: ' + createDate,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await storage.deleteAll();
                      // int count = 0;
                      // Navigator.of(context).popUntil((_) => count++ >= 3);
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.add, size: 20),
                    label: Text(
                      "LogOut",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ));
        }
      },
    );
  }
}
