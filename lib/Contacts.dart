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

  @override
  void initState() {
    super.initState();
    _loadContacts();
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
    _loadContacts();
  }

  Future<void> _addContact(String name, String phoneNumber) async {
    await repository.insertContact(name, phoneNumber);
    _loadContacts();
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
                     title: Text(contact.contactName , style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                     subtitle: Text(contact.phoneNumber),
                     trailing: IconButton(
                       icon: Icon(Icons.delete, color: Colors.red[900]),
                       onPressed: () {
                         _deleteContact(contact);
                       },
                     ),
                   ),
                 );
               },
             ),),
              const SizedBox(height: 30,),
              ElevatedButton(onPressed: () {
                _openDialogBox(context);
                // Fluttertoast.showToast(msg: contacts[0].contactName.toString());
              }, child: const Text('Add New'))
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
                  _addContact(name, phone);
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
            child: Text("Save"),
          ),
        ],
      );
    });
  }

}

