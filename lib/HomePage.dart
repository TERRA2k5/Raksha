import 'package:Raksha/entity/PersonalDetails.dart';
import 'package:Raksha/repository/FloorRespository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isCrisisAlertEnabled = false;
  final currentUser = FirebaseAuth.instance.currentUser;
  // final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'Guest';
  final repository = FloorRepository();
  PersonalDetails? personalData;

  @override
  void initState(){
    super.initState();
    _loadPersonalData();
  }
  Future<void> _loadPersonalData() async {
    personalData = (await repository..getPerson()) as PersonalDetails;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Raksha"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),

              // Emergency card
              _buildEmergencyCard(context, personalData?.name.toString() ?? 'Unknown' , personalData?.bloodgrp.toString() ?? 'Unknown', personalData?.medicalnotes.toString() ?? 'Unknown'),

              SizedBox(height: 25),

              // Call Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildEmergencyCallCard(context, "Call 100"),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildEmergencyCallCard(context, "Call 112"),
                  ),
                ],
              ),

              SizedBox(height: 25),

              // Emergency Alert Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    "EMERGENCY ALERT",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Information Texts
              _buildInfoText(
                  "• Share your real-time location to your emergency contacts."),
              _buildInfoText("• Send Crisis Alert to people within 5 km."),
              _buildInfoText(
                  "• Call primary emergency contact and send SMS alert."),

              SizedBox(height: 25),

              // Crisis Alert Card with toggle switch
              _buildCrisisAlertCard(),

              SizedBox(height: 25),

              // Share Live Location Card
              _buildLiveLocationCard(),

              SizedBox(height: 60),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.grey[200],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(
      BuildContext context, String userName, String bloodGrp, String notes) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "EMERGENCY CARD",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text("Name: "),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    userName,
                    style:
                    const TextStyle(textBaseline: TextBaseline.alphabetic),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text("Blood Group: "),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    bloodGrp,
                    style:
                    const TextStyle(textBaseline: TextBaseline.alphabetic),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text("Medical Notes: "),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    notes,
                    style:
                    const TextStyle(textBaseline: TextBaseline.alphabetic),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCallCard(BuildContext context, String text) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCrisisAlertCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Crisis Alert",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: isCrisisAlertEnabled,
                  onChanged: (value) {
                    setState(() {
                      isCrisisAlertEnabled = value; // Update the state
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildInfoText("• Uses Background Location."),
            _buildInfoText(
                "• Your device uses its location to find info about crisis affecting your area, even when app is closed or not in use."),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveLocationCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Text(
                    "Share Live Location",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildInfoText("• Uses Background Location."),
            _buildInfoText(
                "• Share your real-time location to your emergency contacts."),
          ],
        ),
      ),
    );
  }
  Future<PersonalDetails?> fetchUser() async {
    return repository.getPerson();
  }
}

