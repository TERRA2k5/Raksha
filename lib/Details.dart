import 'package:Raksha/HomePage.dart';
import 'package:Raksha/entity/DetailsDatabase.dart';
import 'package:Raksha/entity/PersonalDetails.dart';
import 'package:Raksha/repository/FloorRespository.dart';
import 'package:flutter/material.dart';
import 'services/firebase_auth.dart';

class Details extends StatefulWidget {
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Details> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final dobController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final allergiesController = TextEditingController();
  final medicinesController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();
  String? selectedBlood;


  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];

  final FloorRepository repository = FloorRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Personal Details',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 60),
              _buildTextField(
                  controller: nameController,
                  label: 'Name *',
                  prefixIcon: Icons.person,
                  capitalization: TextCapitalization.words),
              const SizedBox(height: 30),
              _buildTextField(
                  controller: ageController,
                  label: 'Age *',
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    dobController.text =
                    "${pickedDate.toLocal()}".split(' ')[0];
                  }
                },
                child: AbsorbPointer(
                  child: _buildTextField(
                      controller: dobController,
                      label: 'Date of Birth *',
                      prefixIcon: Icons.cake),
                ),
              ),
              const SizedBox(height: 30),


              DropdownButtonFormField<String>(
                value: selectedBlood,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: const Text('Select your Blood Type *'),
                items: bloodTypes.map((bloodType) {
                  return DropdownMenuItem(
                      value: bloodType, child: Text(bloodType));}).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedBlood = value;
                  });
                },),

              const SizedBox(height: 30),
              _buildTextField(
                  controller: heightController,
                  label: 'Height (cm) *',
                  prefixIcon: Icons.height,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 30),
              _buildTextField(
                  controller: weightController,
                  label: 'Weight (kg) *',
                  prefixIcon: Icons.monitor_weight,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 30),
              _buildTextField(
                  controller: allergiesController,
                  label: 'Allergies',
                  prefixIcon: Icons.medical_services,
                  capitalization: TextCapitalization.sentences),
              const SizedBox(height: 30),
              _buildTextField(
                  controller: medicinesController,
                  label: 'Medicines',
                  prefixIcon: Icons.medical_information,
                  capitalization: TextCapitalization.sentences),
              const SizedBox(height: 30),
              _buildTextField(
                  controller: addressController,
                  label: 'Address *',
                  prefixIcon: Icons.location_on,
                  capitalization: TextCapitalization.sentences),
              const SizedBox(height: 30),
              _buildTextField(controller: notesController, label: 'Medical Notes' , capitalization: TextCapitalization.sentences),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text;
                  final age = ageController.text;
                  final dob = dobController.text;
                  final height = heightController.text;
                  final weight = weightController.text;
                  final allergies = allergiesController.text;
                  final medicines = medicinesController.text;
                  final address = addressController.text;
                  final bloodgrp = selectedBlood;
                  final medicalnotes = notesController.text;

                  if (name.isEmpty ||
                      age.isEmpty ||
                      dob.isEmpty ||
                      height.isEmpty ||
                      weight.isEmpty ||
                      address.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill required fields')),
                    );
                  } else {
                    repository.insertPerson(name, age, dob, height, weight, address, allergies, medicalnotes, medicines, bloodgrp);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  IconData? prefixIcon,
  TextInputType keyboardType = TextInputType.text,
  TextCapitalization capitalization = TextCapitalization.none,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    textCapitalization: capitalization,
    decoration: InputDecoration(
      label: Text(label),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
