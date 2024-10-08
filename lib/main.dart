import 'package:domitory/user_screen/billInformation.dart';
import 'package:flutter/material.dart';
import 'package:domitory/LoginScreen/login.dart';
import 'package:domitory/user_screen/billInformation.dart';
import 'package:domitory/user_screen/paybill.dart';
import 'package:domitory/admin_screen/roomlist.dart';
import 'package:domitory/admin_screen/roomBill.dart';
import 'package:domitory/admin_screen/addNewBill.dart';
import 'package:domitory/admin_screen/editbill.dart';

void main() {
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Domitory',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/user': (context) => const Billinformation(),
        '/admin': (context) => const Roomlist(),
        '/paybill': (context) => const Paybill(),
        '/roomBill': (context) => const Roombill(),
        '/addBill': (context) => const AddNewBill(),
      },
    );
  }
}
