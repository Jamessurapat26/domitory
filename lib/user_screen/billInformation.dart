import 'package:flutter/material.dart';
import 'package:domitory/api_service/service.dart';
import 'package:flutter/widgets.dart';

class Billinformation extends StatelessWidget {
  const Billinformation({super.key});

  Future<Map<String, dynamic>> roomInformation(String username) async {
    ApiService apiService = ApiService();

    return await apiService.roomInformation(username);
  }

  @override
  Widget build(BuildContext context) {
    final String username =
        ModalRoute.of(context)?.settings.arguments as String;

    Icon _iconCheck(int status) {
      if (status == 0) {
        return Icon(
          Icons.circle,
          color: Colors.red,
          size: 30,
        );
      } else if (status == 1) {
        return Icon(
          Icons.circle,
          color: Colors.yellow,
          size: 30,
        );
      } else {
        return Icon(
          Icons.circle,
          color: Colors.green,
          size: 30,
        );
      }
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Room Information',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: roomInformation(username),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150',
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['roomname']}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                        Spacer(),
                        _iconCheck(data['payment_status']),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        buildBillItem('Room charge', '${data['room_charge']}'),
                        buildBillItem(
                            'Water charge', '${data['water_charge']}'),
                        buildBillItem('Electricity charge',
                            '${data['electricity_charge']}'),
                        buildBillItem(
                            'Garbage charge', '${data['garbage_charge']}'),
                        buildBillItem(
                            'Other charge', '${data['other_charge']}'),
                        buildBillItem('Total',
                            '${double.parse(data['room_charge']) + double.parse(data['water_charge']) + double.parse(data['electricity_charge']) + double.parse(data['garbage_charge']) + double.parse(data['other_charge'])}')
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/paybill',
                        arguments: data['bill_id']),
                    child: Text('Pay Now'),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        )),
                  )
                ],
              ),
            );
          },
        ));
  }

  Widget buildBillItem(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
            Text(
              amount,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
