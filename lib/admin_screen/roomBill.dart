import 'package:flutter/material.dart';
import 'package:domitory/api_service/service.dart';
import 'package:intl/intl.dart';
import 'editbill.dart';

class Roombill extends StatelessWidget {
  const Roombill({super.key});

  @override
  Widget build(BuildContext context) {
    final int room_id = ModalRoute.of(context)?.settings.arguments as int;

    Future<List<dynamic>> getBillbyRoom(int room_id) async {
      ApiService apiService = ApiService();

      return await apiService.getBillbyRoom(room_id);
    }

    String convertTime(String time) {
      DateTime dateTime = DateTime.parse(time);
      String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);

      return formattedDate;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Room Bill $room_id'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getBillbyRoom(room_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<dynamic> billList = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: billList.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> bill =
                          billList[index] as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                            title: Text(
                              convertTime(bill['created_at'].toString()),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Room Charge: ${bill['room_charge']}'),
                                Text('Water Charge: ${bill['water_charge']}'),
                                Text(
                                    'Electricity Charge: ${bill['electricity_charge']}'),
                                Text(
                                    'Garbage Charge: ${bill['garbage_charge']}'),
                                Text('Other Charge: ${bill['other_charge']}'),
                                Text(
                                    'Total Charge: ${double.parse(bill['room_charge']) + double.parse(bill['water_charge']) + double.parse(bill['electricity_charge']) + double.parse(bill['garbage_charge']) + double.parse(bill['other_charge'])}'),
                                Text(
                                    'Payment Status: ${bill['payment_status']}'),
                                Text('Bill URL: ${bill['bill_url']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    print("it is a edit button");
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditBill(
                                                billId: bill['bill_id'])));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    ApiService apiService = ApiService();
                                    apiService.deleteBill(bill['bill_id']);

                                    Navigator.pop(context);

                                    // Optionally, show a success message or navigate back
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Bill deleted successfully')),
                                    );
                                  },
                                ),
                              ],
                            )),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("it is a add button");
          Navigator.pushNamed(context, '/addBill', arguments: room_id);
        },
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
