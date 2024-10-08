import 'package:domitory/api_service/service.dart';
import 'package:flutter/material.dart';

class EditBill extends StatefulWidget {
  final int billId;

  const EditBill({required this.billId, Key? key}) : super(key: key);

  @override
  _EditBillState createState() => _EditBillState();
}

class _EditBillState extends State<EditBill> {
  final ApiService _apiService = ApiService();

  final Map<String, int> _paymentStatusMap = {
    'Paid': 2,
    'Unpaid': 0,
    'Pending': 1,
  };

  late int _selectedPaymentStatus;
  late TextEditingController _roomChargeController;
  late TextEditingController _waterChargeController;
  late TextEditingController _electricityChargeController;
  late TextEditingController _garbageChargeController;
  late TextEditingController _otherChargeController;
  late TextEditingController _billUrlController;

  @override
  void initState() {
    super.initState();

    _roomChargeController = TextEditingController();
    _waterChargeController = TextEditingController();
    _electricityChargeController = TextEditingController();
    _garbageChargeController = TextEditingController();
    _otherChargeController = TextEditingController();
    _billUrlController = TextEditingController();

    _loadBillDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bill'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white, // เพิ่มสีให้กับ AppBar
      ),
      body: SingleChildScrollView(
        // ใช้เพื่อให้สามารถเลื่อนหน้าจอได้
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Bill Charges'),
              const SizedBox(height: 10),
              _buildInputField(
                label: 'Room Charge',
                controller: _roomChargeController,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                label: 'Water Charge',
                controller: _waterChargeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                label: 'Electricity Charge',
                controller: _electricityChargeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                label: 'Garbage Charge',
                controller: _garbageChargeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                label: 'Other Charge',
                controller: _otherChargeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                label: 'Bill URL',
                controller: _billUrlController,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Payment Status'),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                value: _selectedPaymentStatus,
                items: _paymentStatusMap.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedPaymentStatus = newValue!;
                  });
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveBillDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // สีของปุ่ม
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white, // เพิ่มสีพื้นหลังให้กับช่องกรอก
        contentPadding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 20), // เพิ่มระยะห่างภายในช่องกรอก
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Future<void> _loadBillDetails() async {
    final billDetails = await _apiService.getBillById(widget.billId);

    setState(() {
      _roomChargeController.text = billDetails['room_charge'].toString();
      _waterChargeController.text = billDetails['water_charge'].toString();
      _electricityChargeController.text =
          billDetails['electricity_charge'].toString();
      _garbageChargeController.text = billDetails['garbage_charge'].toString();
      _otherChargeController.text = billDetails['other_charge'].toString();
      _billUrlController.text = billDetails['bill_url'].toString();
      _selectedPaymentStatus = billDetails['payment_status'].toInt();
    });
  }

  Future<void> _saveBillDetails() async {
    try {
      await _apiService.updateBill(
        widget.billId,
        double.parse(_roomChargeController.text),
        double.parse(_waterChargeController.text),
        double.parse(_electricityChargeController.text),
        double.parse(_garbageChargeController.text),
        double.parse(_otherChargeController.text),
        _billUrlController.text,
        _selectedPaymentStatus,
      );

      Navigator.pop(context);

      // Optionally, show a success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bill details saved successfully')),
      );
    } catch (e) {
      // Log the error or show an error message
      print('Error saving bill details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save bill details')),
      );
    }
  }
}
