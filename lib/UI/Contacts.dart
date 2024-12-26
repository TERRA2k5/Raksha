import 'package:Raksha/entity/Model.dart';
import 'package:Raksha/repository/FloorRespository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../MainContainer.dart';

class Contacts extends StatefulWidget {

  @override
  _ContactSatate createState() => _ContactSatate();
}

class _ContactSatate extends State<Contacts> {

  final repository = FloorRepository();
  List<EmergencyContact> contacts = [];
  EmergencyContact? primaryContact;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _primaryContact();
  }

  Future<void> _loadContacts() async {
    final fetchedContacts = await repository.getContacts();
    if (fetchedContacts != null) {
      setState(() {
        contacts = fetchedContacts;
      });
    }
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    await repository.deleteContact(contact.id);
    _primaryContact();
  }

  Future<void> _primaryContact() async {
    primaryContact =  await repository.getPrimary();
    _loadContacts();
  }

  Future<void> _addContact(String name, String phoneNumber, bool primary) async {
    await repository.insertContact(name, phoneNumber , primary);
    _primaryContact();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Raksha'),),

      body: Padding(padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const Text('Emergency Contacts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
             const SizedBox(height: 50),
             Flexible(
               fit: FlexFit.loose,
               child: ListView.builder(
               itemCount: contacts.length,
               itemBuilder: (context, index) {
                 final contact = contacts[index];
                 return Card(
                   child: ListTile(
                     title: Text(contact.isPrimary ? "${contact.contactName} (Primary)" : contact.contactName , style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                     subtitle: Text(contact.phoneNumber),
                     trailing: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         IconButton(
                           icon: Icon(Icons.delete, color: Colors.red[900]),
                           onPressed: () {
                             if(contact.isPrimary){
                               Fluttertoast.showToast(msg: 'Cannot delete primary contact');
                             }
                             else {
                               _deleteContact(contact);
                             }
                           },
                         ),
                         IconButton(
                           icon: Icon(contact.isPrimary ? Icons.star : Icons.star_border, color: Colors.red[900]),
                           onPressed: () {
                             if(!contact.isPrimary){
                               _addContact(primaryContact!.contactName, primaryContact!.phoneNumber, false);
                               _deleteContact(primaryContact!);
                               _deleteContact(contact);
                               _addContact(contact.contactName, contact.phoneNumber, true);
                             }
                           },
                         ),
                       ],
                     ),
                   ),
                 );
               },
             ),),
              const SizedBox(height: 30,),
              ElevatedButton(onPressed: () async {
                // await Permission.contacts.request();
                PermissionStatus requestPermission = await Permission.contacts.request();
                if (requestPermission.isGranted) {
                  final contact = await FlutterContacts.openExternalPick();
                  if (contact != null) {
                    List<String> numbers = contact.phones.map((e) => e.number).toList();
                    // Fluttertoast.showToast(msg: numbers.length.toString());
                    if(primaryContact == null){
                      for(var phone in numbers){
                        phone = phone.replaceAll("+91", "").replaceAll(" ", "");
                        if(contacts.isEmpty){
                          _addContact(contact.displayName, phone, true);
                        }
                        else{
                          _addContact(contact.displayName, phone, false);
                        }
                      }
                    }
                    else{
                      for(var phone in numbers){
                        phone = phone.replaceAll("+91", "").replaceAll(" ", "");
                        _addContact(contact.displayName, phone, false);
                      }
                    }
                  }
                }
                // _openDialogBox(context);
                // Fluttertoast.showToast(msg: contacts[0].contactName.toString());
              }, child: const Text('Add New')),
              const SizedBox(height: 30,),
              ElevatedButton(onPressed: () {
                if(primaryContact == null){
                  Fluttertoast.showToast(msg: 'You must add a contact');
                }
                else{
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainContainer()), (route) => false ,);
                }
              }, child: const Text('Home'))
            ],
          ),
        ),),
    );
  }

}

