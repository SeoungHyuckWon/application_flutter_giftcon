import 'package:flutter/material.dart';
import 'package:flutter_application_giftcon/main.dart';
import 'package:flutter_application_giftcon/screens/add.dart';
import 'package:flutter_application_giftcon/screens/list.dart';
import 'package:flutter_application_giftcon/screens/profile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.MyID}) : super(key: key);
  final String MyID;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget build(BuildContext context) {
    const TextStyle optionStyle =
        TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    List<Widget> _widgetOptions = <Widget>[
      MyListPage(MyID: widget.MyID),
      MyAddPage(
        MyID: widget.MyID,
      ),
      MyProfilePage(MyID: widget.MyID),
      // Text(
      //   'Index 3: Settings',
      //   style: optionStyle,
      // ),
    ];

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.crop_original),
            label: 'MyGiftCon',
            backgroundColor: Colors.lightBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.backup),
            label: 'Register',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'MyProfile',
            backgroundColor: Colors.purple,
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.settings),
          //   label: 'Settings',
          //   backgroundColor: Colors.pink,
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
