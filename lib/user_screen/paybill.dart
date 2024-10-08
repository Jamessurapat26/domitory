import 'package:flutter/material.dart';
import 'package:domitory/api_service/service.dart';

class Paybill extends StatelessWidget {
  const Paybill({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService _apiService = ApiService();

    final TextEditingController _linkController = TextEditingController();
    final int bill_id = ModalRoute.of(context)?.settings.arguments as int;

    if (bill_id != null) {
      print("bill_id: $bill_id");
    } else {
      print("bill_id is null");
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Pay Bill',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/images/qrcode.jpg', height: 500, width: 500),
            Container(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  labelText: 'Enter Bill Link',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  print(_linkController.text);
                  ApiService().uploadbill(bill_id, _linkController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upload bill successful')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Send'),
              ),
            )
          ],
        ));
  }
}
