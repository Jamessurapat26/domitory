import 'package:flutter/material.dart';
import 'package:domitory/api_service/service.dart';

class Roomlist extends StatelessWidget {
  const Roomlist({super.key});

  Future<List<dynamic>> getRooms() async {
    ApiService apiService = ApiService();

    return await apiService.getRooms();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Room List"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final room = data[index]
                              as Map<String, dynamic>; // แปลงข้อมูลเป็น Map
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                room['roomname'] ?? 'No Name', // ตรวจสอบ null
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  Text(room['description'] ?? 'No Description'),
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/roomBill',
                                arguments: room['id'],
                              ),
                            ),
                          );
                        }),
                  )
                ],
              ));
        },
      ),
    );
  }
}
