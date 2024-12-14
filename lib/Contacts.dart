import 'package:Raksha/HomePage.dart';
import 'package:Raksha/entity/Model.dart';
import 'package:Raksha/repository/FloorRespository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
                             _addContact(primaryContact!.contactName, primaryContact!.phoneNumber, false);
                             _deleteContact(primaryContact!);
                             _deleteContact(contact);
                             _addContact(contact.contactName, contact.phoneNumber, true);
                           },
                         ),
                       ],
                     ),
                   ),
                 );
               },
             ),),
              const SizedBox(height: 30,),
              ElevatedButton(onPressed: () {
                _openDialogBox(context);
                // Fluttertoast.showToast(msg: contacts[0].contactName.toString());
              }, child: const Text('Add New')),
              const SizedBox(height: 30,),
              ElevatedButton(onPressed: () {
                if(primaryContact == null){
                  Fluttertoast.showToast(msg: 'You must add a contact');
                }
                else{
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false ,);
                }
              }, child: const Text('Home'))
            ],
          ),
        ),),
    );
  }

  Future<void> _openDialogBox(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    return showDialog(context: context, builder: (context) {
      return AlertDialog(title: const Text('Emergency Contact'),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text;
              final phone = phoneController.text;

              if (name.isNotEmpty && phone.isNotEmpty) {
                if(phone.length == 10){
                  if(primaryContact == null){
                    _addContact(name, phone, true);
                  }
                  else{
                    _addContact(name, phone, false);
                  }
                  Navigator.pop(context);
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter valid phone number.")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      );
    });
  }

}

