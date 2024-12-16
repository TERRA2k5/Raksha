import 'package:Raksha/Contacts.dart';
import 'package:Raksha/Details.dart';
import 'package:Raksha/HomePage.dart';
import 'package:Raksha/Login.dart';
import 'package:Raksha/repository/FloorRespository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'entity/Model.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  FloorRepository repository = FloorRepository();
  PersonalDetails? personalData;
  List<EmergencyContact>? emergencyContacts;

  @override
  void initState() {
    super.initState();
    _loadPersonalData();
    _getContacts();
  }

  Future<void> _loadPersonalData() async {
    personalData = (await repository.getPerson());
    setState(() {});
  }
  Future<void> _getContacts() async {
    emergencyContacts = await repository.getContacts();
    if(emergencyContacts == null){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Contacts()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raksha'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text(
                                'Details',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                                flex: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Details()));
                                  },
                                ))
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Name : '),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                  personalData?.name.toString() ?? 'Unknown'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Age : '),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                  personalData?.age.toString() ?? 'Unknown'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Date of Birth : '),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                  personalData?.DOB.toString() ?? 'Unknown'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Height : '),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                  personalData?.height.toString() ?? 'Unknown'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Weight : '),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                  personalData?.weight.toString() ?? 'Unknown'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Blood Group : '),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(personalData?.bloodgrp.toString() ??
                                  'Unknown'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Allergies : '),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(personalData?.allergies.toString() ??
                                  'Unknown'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Address : '),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(personalData?.address.toString() ??
                                  'Unknown'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Medicines : '),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(personalData?.medicines.toString() ??
                                  'Unknown'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Medical Notes : '),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                  personalData?.medicalnotes.toString() ??
                                      'Unknown'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Contacts()));
                          },
                          child: const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'Emergency Contacts',
                                style: TextStyle(color: Colors.black , fontSize: 15),
                              )),
                        ))
                  ],
                ),
                SizedBox(height: 10,),
                ElevatedButton(onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  repository.deletePerson(1);
                  for(var contact in emergencyContacts!){
                    repository.deleteContact(contact.id);
                  }
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Login()), (route)=> false);
                }, child: Text('Log Out'))
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.grey[200],
        onTap: (index) {
          if (index != 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
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
}
