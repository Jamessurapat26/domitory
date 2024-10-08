import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String url = 'http://10.0.2.2:3000';

  // Check if username and password are correct
  Future<String> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$url/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['usertype'] == 'user') {
          return 'user';
        } else if (data['usertype'] == 'admin') {
          return 'admin';
        } else {
          return 'unknown user type';
        }
      } else {
        // Handle other status codes
        return 'Failed to login: ${response.statusCode}';
      }
    } catch (e) {
      // Handle any exceptions (e.g. network issues)
      print('Error: $e');
      return 'An error occurred';
    }
  }

  Future<Map<String, dynamic>> roomInformation(String username) async {
    try {
      // ส่งค่า username ผ่าน query parameter
      final response = await http.get(
        Uri.parse('$url/room-information/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      // ตรวจสอบว่า response เป็น 200 หรือไม่
      if (response.statusCode == 200) {
        // แปลง body ที่ได้รับเป็น Map<String, dynamic>
        return jsonDecode(response.body);
      } else {
        // ถ้า status code ไม่ใช่ 200 ให้ throw ข้อผิดพลาด
        throw Exception(
            'Failed to load room information: ${response.statusCode}');
      }
    } catch (e) {
      // จัดการข้อผิดพลาดกรณีมี exception
      throw Exception('Failed to load room information: $e');
    }
  }

  //upload bill link to database
  Future<String> uploadbill(int bill_id, String bill_link) async {
    try {
      final response = await http.post(
        Uri.parse('$url/update_bills'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'bill_id': bill_id.toString(),
          'bill_link': bill_link
        }),
      );

      return response.body;
    } catch (e) {
      throw Exception('Failed to upload bill url: $e');
    }
  }

  Future<List<dynamic>> getRooms() async {
    try {
      final response = await http.get(Uri.parse('$url/getAllRooms'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get rooms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get rooms: $e');
    }
  }

  Future<List<dynamic>> getBillbyRoom(int room_id) async {
    try {
      final response = await http.get(Uri.parse('$url/getBillbyRoom/$room_id'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get rooms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get rooms: $e');
    }
  }

  Future<void> newBill(
      int roomId,
      double roomCharge,
      double waterCharge,
      double electricityCharge,
      double garbageCharge,
      double otherCharge) async {
    try {
      final response = await http.post(
        Uri.parse('$url/newBill'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'room_id': roomId.toString(),
          'room_charge': roomCharge.toString(),
          'water_charge': waterCharge.toString(),
          'electricity_charge': electricityCharge.toString(),
          'garbage_charge': garbageCharge.toString(),
          'other_charge': otherCharge.toString(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add new bill: ${response.statusCode}');
      }
    } on Exception catch (e) {
      throw Exception('Failed to add new bill: $e');
    }
  }

  Future<Map<String, dynamic>> getBillById(int bill_id) async {
    try {
      final response = await http.get(Uri.parse('$url/getBillById/$bill_id'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data[0];
      } else {
        throw Exception('Failed to get bill: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get bill: $e');
    }
  }

  Future<void> updateBill(
      int bill_id,
      double roomCharge,
      double waterCharge,
      double electricityCharge,
      double garbageCharge,
      double otherCharge,
      String billLink,
      int paymentStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$url/update_billbyId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'bill_id': bill_id.toString(),
          'room_charge': roomCharge.toString(),
          'water_charge': waterCharge.toString(),
          'electricity_charge': electricityCharge.toString(),
          'garbage_charge': garbageCharge.toString(),
          'other_charge': otherCharge.toString(),
          'bill_url': billLink,
          'payment_status': paymentStatus.toString(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add new bill: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add new bill: $e');
    }
  }

  Future<void> deleteBill(int bill_id) async {
    try {
      final response =
          await http.delete(Uri.parse('$url/delete_bill/$bill_id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete bill: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete bill: $e');
    }
  }

  Future<String> checkDatabaseConnection() async {
    try {
      final response = await http.get(Uri.parse('$url/check-connection'));

      if (response.statusCode == 200) {
        return 'Database connection successful';
      } else {
        return 'Failed to connect to database: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
