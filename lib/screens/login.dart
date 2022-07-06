import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_giftcon/database/accountdb.dart';
import 'package:flutter_application_giftcon/screens/home.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const users = const {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
  'aaa@a.com': 'aaa'
};

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({Key? key}) : super(key: key);

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  Duration get loginTime => Duration(milliseconds: 1250);
  String myID = '';
  String keyUserName = '';
  String keyPassWord = '';
  String keyMyID = '';
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _storage = new FlutterSecureStorage();
  // final TextEditingController _usernameController =
  //     TextEditingController(text: "");
  // final TextEditingController _passwordController =
  //     TextEditingController(text: "");
  // bool passwordHidden = true;
  // bool _savePassword = true
  // _onFormSubmit() async {
  //   if (_formKey.currentState?.validate() ?? false) {
  //     if (_savePassword) {
  //       await _storage.write(
  //           key: "KEY_USERNAME", value: _usernameController.text);
  //       await _storage.write(
  //           key: "KEY_PASSWORD", value: _usernameController.text);
  //     }
  //   }
  // }

  // Future<void> _readFormStorage() async {
  //   String keyUserName = await _storage.read(key: "KEY_USERNAME") ?? '';
  //   String KeyPassWord = await _storage.read(key: "KEY_PASSWORD") ?? '';
  // }

  // @protected
  // @mustCallSuper
  // Future<void> initState() async {
  //   keyUserName = await _storage.read(key: "KEY_USERNAME") ?? '';
  //   keyPassWord = await _storage.read(key: "KEY_PASSWORD") ?? '';
  // }

  // Future<String> _read() async => await storage.read(key: 'login') ?? '';
  // Future _save(String value) async =>
  //     await storage.write(key: 'login', value: value);

  @override
  void initState() {
    super.initState();

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    //read 함수를 통하여 key값에 맞는 정보를 불러오게 됩니다. 이때 불러오는 결과의 타입은 String 타입임을 기억해야 합니다.
    //(데이터가 없을때는 null을 반환을 합니다.)
    keyUserName = (await _storage.read(key: "KEY_USERNAME"))!;
    keyPassWord = (await _storage.read(key: "KEY_PASSWORD"))!;
    keyMyID = (await _storage.read(key: "KEY_MYID"))!;
    if (keyUserName != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MyHomePage(
          MyID: keyMyID,
        ),
      ));
      setState(() {});
    }
    //user의 정보가 있다면 바로 로그아웃 페이지로 넝어가게 합니다.
  }

  Future<String?> _authUser(LoginData data) async {
    // if (keyUserName != '') {
    //   myID = keyMyID;
    //   return null;
    // }
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async {
      FirebaseFirestore db = FirebaseFirestore.instance;
      final docRef = db.collection("account");
      final docID = docRef.where('id', isEqualTo: data.name);
      final docPass = docID.where('password', isEqualTo: data.password);
      var checkID = await docID.get();
      var checkPass = await docPass.get();
      // Map checkID = (await docID.get()) as Map<>;
      // Map checkPass = (await docPass.get()) as Map;
      if (checkID.docs.isEmpty) {
        return 'User not exists';
      }
      if (checkPass.docs.isEmpty) {
        return 'Password does not match';
      }
      myID = checkID.docs.first.id;
      await _storage.write(key: 'KEY_USERNAME', value: data.name);
      await _storage.write(key: 'KEY_PASSWORD', value: data.password);
      await _storage.write(key: 'KEY_MYID', value: myID);
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return saveDB(data.name.toString(), data.password.toString());
    });
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return null!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      savedEmail: keyUserName,
      savedPassword: keyPassWord,
      title: 'Gift-Con',
      //logo: AssetImage('assets/images/ecorp-lightblue.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MyHomePage(
            MyID: myID,
          ),
        ));
        setState(() {});
      },
      onRecoverPassword: _recoverPassword,
    );
  }

  Future<String?> saveDB(String id, String password) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var docID = db.collection("account").where('id', isEqualTo: id);
    var search = await docID.get();
    if (search.docs.isEmpty) {
      var nw = DateTime.now().toString().split(' ')[0];
      final docRef = db
          .collection("account")
          .withConverter(
            fromFirestore: AccountStore.fromFirestore,
            toFirestore: (AccountStore account, options) =>
                account.toFirestore(),
          )
          .doc();
      //var id = docRef.id;
      final account = AccountStore(
        field: docRef.id,
        id: id,
        password: password,
        createDate: nw,
        editDate: nw,
      );
      await docRef.set(account);
      return null;
    } else {
      return 'The Account is already exist';
    }
  }
}
