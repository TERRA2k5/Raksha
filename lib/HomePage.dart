import 'package:Raksha/Contacts.dart';
import 'package:Raksha/Details.dart';
import 'package:Raksha/entity/Model.dart';
import 'package:Raksha/repository/FirebaseRepository.dart';
import 'package:Raksha/repository/FloorRespository.dart';
import 'package:background_sms/background_sms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isCrisisAlertEnabled = false;
  final currentUser = FirebaseAuth.instance.currentUser;
  // final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'Guest';
  final repository = FloorRepository();
  final firebaseRepo = FirebaseRepository();
  PersonalDetails? personalData;
  String? alertSMS;
  String? coordinate;
  EmergencyContact? primaryContact;
  List<EmergencyContact>? emergencyContacts;

  @override
  void initState(){
    super.initState();
    _getContacts();
    _loadPersonalData();
    _primaryContact();
    _requestPermission();
    _getCrisisState();
  }

  // void _buildGeolocatorConfig(bool isOpted) async{
  //   if(isOpted){
  //     bg.BackgroundGeolocation.ready(bg.Config(
  //       desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
  //       distanceFilter: 50,
  //       stopOnTerminate: false,
  //       startOnBoot: true,
  //       enableHeadless: true,
  //       foregroundService: true,
  //       allowIdenticalLocations: false,
  //       logLevel: bg.Config.LOG_LEVEL_VERBOSE,
  //     )).then((bg.State state) {
  //       if (!state.enabled) {
  //         bg.BackgroundGeolocation.start();
  //       }
  //     });
  //   }
  // }

  Future<void> _getCrisisState()async {
    isCrisisAlertEnabled = await firebaseRepo.getFirebaseStatus();
    setState(() {
      isCrisisAlertEnabled;
      // _buildGeolocatorConfig(isCrisisAlertEnabled);
    });
  }

  // void setupLocationListener(String userId) {
  //   bg.BackgroundGeolocation.onLocation((bg.Location location) {
  //     // Extract latitude and longitude
  //     double latitude = location.coords.latitude;
  //     double longitude = location.coords.longitude;
  //
  //     FirebaseDatabase.instance.ref('Locations').child(userId).update({
  //       'location': {'latitude': latitude, 'longitude': longitude},
  //     }).then((_) {
  //       print("Location updated: $latitude, $longitude");
  //     }).catchError((e) {
  //       print("Error updating location: $e");
  //     });
  //   });
  //
  //   bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
  //     print("Motion changed to: ${location.coords}");
  //   });
  // }

  // void startTracking(String userId) {
  //   // Initialize location listener
  //   setupLocationListener(userId);
  //
  //   // Start the background location service
  //   bg.BackgroundGeolocation.start().then((_) {
  //     print("Background location tracking started.");
  //   }).catchError((e) {
  //     print("Error starting location tracking: $e");
  //   });
  // }
  //
  // void stopTracking() {
  //   // Stop background location service
  //   bg.BackgroundGeolocation.stop().then((_) {
  //     print("Background location tracking stopped.");
  //   }).catchError((e) {
  //     print("Error stopping location tracking: $e");
  //   });
  // }


  Future<void> _requestPermission()async {
    await Permission.sms.request();
    await Permission.location.request();
  }
  Future<void> _getContacts() async {
    emergencyContacts = await repository.getContacts();
    if(emergencyContacts.toString() == "[]"){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Contacts()), (route) => false);
    }
  }
  Future<void> _primaryContact() async {
    primaryContact =  await repository.getPrimary();
  }
  Future<void> _loadPersonalData() async {
    personalData = (await repository.getPerson());
    setState((){
      personalData;
    });
    if(personalData == null){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Details()), (route) => false);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try{
      await launchUrl(phoneUri);
    }catch(e){
      Fluttertoast.showToast(msg: 'Error while calling');
    }
  }


  Future<void> sendSms(EmergencyContact contact , String message) async {
    PermissionStatus status = await Permission.sms.request();
    if(status.isGranted){
      SmsStatus result = await BackgroundSms.sendMessage(
          phoneNumber: contact.phoneNumber, message: message);
      if (result == SmsStatus.sent) {
        print("Sent");
        // Fluttertoast.showToast(msg: 'SMS to ${contact.phoneNumber}');
      } else {
        print("Failed");
        Fluttertoast.showToast(msg: 'Failed SMS to ${contact.contactName}');
      }
    }
    else{
      print('permission');
      Fluttertoast.showToast(msg: 'SMS Permission Denied');
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Error fetching location: $e");
      return null;
    }
  }

  Future<void> getCoordinateAndSMS() async{
    PermissionStatus status = await Permission.location.request();
    // Fluttertoast.showToast(msg: status.toString());
    if(status.isGranted){
      Position? position = await _getCurrentLocation();
      if (position == null) {
        print("Unable to fetch location.");
      return;
      }
      String coordinate = "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
      alertSMS = 'This is a automated SMS sent by Raksha,\n${personalData!.name} might be in Emergency.\nLocation: ${coordinate}\nNotes: ${personalData!.medicalnotes}';
      // Fluttertoast.showToast(msg: alertSMS.toString());
      for(var contact in emergencyContacts!){
        sendSms(contact, alertSMS!);
      }
    }
    else{
      print('permission');
      Fluttertoast.showToast(msg: 'Location Permission Denied');
    }
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
              _buildEmergencyCard(context, personalData?.name.toString() ?? 'Unknown' , personalData?.bloodgrp.toString() ?? 'Unknown', personalData?.allergies.toString() ?? 'Unknown', personalData?.medicines.toString() ?? 'Unknown', personalData?.medicalnotes.toString() ?? 'Unknown'),

              SizedBox(height: 25),

              // Call Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildEmergencyCallCard(context, "100"),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildEmergencyCallCard(context, "112"),
                  ),
                ],
              ),

              SizedBox(height: 25),

              // Emergency Alert Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    getCoordinateAndSMS();
                    // Call
                    _makePhoneCall(primaryContact!.phoneNumber);
                  },
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
        onTap: (index){
            if(index != 0){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(
      BuildContext context, String userName, String bloodGrp,String allergies, String medicine, String notes) {
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
                  child: Text("Allergies: "),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    allergies,
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
                  child: Text("Medicines: "),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    medicine,
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

  Widget _buildEmergencyCallCard(BuildContext context, String phone) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () {
          _makePhoneCall(phone);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Call $phone",
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
                    // if(currentUser != null){
                    //   if(value){
                    //     startTracking(currentUser!.uid);
                    //   }
                    //   else{
                    //     stopTracking();
                    //   }
                    // }
                    firebaseRepo.firebaseChangeStatus(value);
                    setState(() {
                      isCrisisAlertEnabled = value;
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
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: (){
          _buildAlertBox(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      "Share Current Location",
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
                  "• Share your current location to your emergency contacts."),
            ],
          ),
        ),
      )
    );
  }

  Future<void> _buildAlertBox(BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text('This will send Emergency SMS to all Emergency Contact.' , style: TextStyle(fontSize: 15),),
        actions: [
          TextButton(onPressed: (){Navigator.pop(context);}, child: const Text('Cancel')),
          TextButton(onPressed: (){
            getCoordinateAndSMS();
            Navigator.pop(context);
          }, child: const Text('Send'))
        ],
      );
    });
  }
}

