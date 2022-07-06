import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_giftcon/database/db.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyAddPage extends StatefulWidget {
  const MyAddPage({Key? key, required this.MyID}) : super(key: key);
  final String MyID;
  @override
  State<MyAddPage> createState() => _MyAddPageState();
}

class _MyAddPageState extends State<MyAddPage> {
  @override
  PickedFile? _image;
  DateTime? _chosenDateTime;
  String title = '';
  String date = '';

  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      //physics: BouncingScrollPhysics(),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 20)),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: Center(
                child: _image == null
                    ? Text('No image selected.')
                    : Image.file(File(_image!.path))),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: getImageFromCam,
                tooltip: 'Pick Image',
                child: Icon(Icons.add_a_photo),
              ),
              FloatingActionButton(
                onPressed: getImageFromGallery,
                tooltip: 'Pick Image',
                child: Icon(Icons.wallpaper),
              )
            ],
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 30)),
          TextField(
            textAlign: TextAlign.center,
            maxLines: 1,
            onChanged: (String title) {
              this.title = title;
            },
            style: TextStyle(fontSize: 20),
            //obscureText: true,
            decoration: InputDecoration(
              //border: OutlineInputBorder(),
              hintText: 'No title written on it!',
              border: InputBorder.none,
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          TextButton(
            child: Text(
              _chosenDateTime != null
                  ? _chosenDateTime.toString().split(' ')[0]
                  : 'No date time picked!',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () => _showDatePicker(context),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (_image != null &&
                      _chosenDateTime != null &&
                      title != '') {
                    var storedImage = File(_image!.path);
                    saveDB(storedImage);
                    Fluttertoast.showToast(
                      msg: "Success Saving Giftcon",
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Fill the photo and info",
                    );
                  }
                },
                icon: Icon(Icons.add, size: 20),
                label: Text(
                  "Register!!",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 10))
            ],
          )
        ],
      ),
    ));
  }

  Future getImageFromCam() async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image!;
    });
  }

  Future getImageFromGallery() async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image!;
    });
  }

  void _showDatePicker(ctx) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 500,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        //initialDateTime: DateTime.now(),
                        //minimumDate: DateTime.now().subtract(Duration(days: 1)),
                        minimumDate: DateTime.now(),
                        onDateTimeChanged: (val) {
                          setState(() {
                            _chosenDateTime = val;
                            date = val.toString().split(' ')[0];
                          });
                        }),
                  ),

                  // Close the modal
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  )
                ],
              ),
            ));
  }

  Future<void> saveDB(File file) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    // String dir;
    // if (Platform.isAndroid) {
    //   dir = (await getExternalStorageDirectory())!.path;
    // } else if (Platform.isIOS) {
    //   dir = (await getApplicationDocumentsDirectory()).path;
    // } else {
    //   dir = '';
    // }
    var nw = DateTime.now().toString().split(' ')[0];
    // final String fileName = id + '.jpg';
    // final File localImage = await file.copy('$dir/$fileName');
    final storage = FirebaseStorage.instance.ref();
    final docRef = db
        .collection(widget.MyID)
        .withConverter(
          fromFirestore: ImageStore.fromFirestore,
          toFirestore: (ImageStore image, options) => image.toFirestore(),
        )
        .doc();
    var id = docRef.id;
    final imagesRef = storage.child(id);
    await imagesRef.putFile(file);
    final image = ImageStore(
      id: id,
      title: this.title,
      date: this.date,
      createDate: nw,
      editDate: nw,
    );
    await docRef.set(image);
  }
}
