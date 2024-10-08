import 'package:domitory/api_service/service.dart';
import 'package:flutter/material.dart';

class AddNewBill extends StatefulWidget {
  const AddNewBill({super.key});

  @override
  _AddNewBillState createState() => _AddNewBillState();
}

class _AddNewBillState extends State<AddNewBill> {
  final _formKey = GlobalKey<FormState>();
  final _roomController = TextEditingController();
  final _waterController = TextEditingController();
  final _electricityController = TextEditingController();
  final _garbageController = TextEditingController();
  final _otherController = TextEditingController();

  double _total = 0.0;

  void _calculateTotal() {
    double room = double.tryParse(_roomController.text) ?? 0.0;
    double water = double.tryParse(_waterController.text) ?? 0.0;
    double electricity = double.tryParse(_electricityController.text) ?? 0.0;
    double garbage = double.tryParse(_garbageController.text) ?? 0.0;
    double other = double.tryParse(_otherController.text) ?? 0.0;

    setState(() {
      _total = room + water + electricity + garbage + other;
    });
  }

  @override
  void initState() {
    super.initState();
    _roomController.addListener(_calculateTotal);
    _waterController.addListener(_calculateTotal);
    _electricityController.addListener(_calculateTotal);
    _garbageController.addListener(_calculateTotal);
    _otherController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _roomController.dispose();
    _waterController.dispose();
    _electricityController.dispose();
    _garbageController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int room_id = ModalRoute.of(context)?.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Bill'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _roomController,
                        decoration: InputDecoration(labelText: 'Room'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the room';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _waterController,
                        decoration: InputDecoration(labelText: 'Water'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the water bill';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _electricityController,
                        decoration: InputDecoration(labelText: 'Electricity'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the electricity bill';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _garbageController,
                        decoration: InputDecoration(labelText: 'Garbage'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the garbage bill';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _otherController,
                        decoration: InputDecoration(labelText: 'Other'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the other bill';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Total: $_total Baht',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final room = _roomController.text;
                      final water = _waterController.text;
                      final electricity = _electricityController.text;
                      final garbage = _garbageController.text;
                      final other = _otherController.text;
                      print("Room: $room");
                      print("Water: $water");
                      print("Electricity: $electricity");
                      print("Garbage: $garbage");
                      print("Other: $other");
                      print("Total: $_total");
                      // Add your logic to save the bill here

                      ApiService apiService = ApiService();
                      apiService.newBill(
                        room_id,
                        double.parse(room),
                        double.parse(water),
                        double.parse(electricity),
                        double.parse(garbage),
                        double.parse(other),
                      );
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Bill added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text('Add Bill'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
