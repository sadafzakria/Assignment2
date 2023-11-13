import 'package:flutter/material.dart';
import 'database_helper.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Database',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ssnController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isUpdating = false;
  int? updateId;
  List<Map<String, dynamic>> userList = [];

  @override
  void initState() {
    super.initState();
    _refreshUserList();
  }

  void _refreshUserList() async {
    List<Map<String, dynamic>> users = await dbHelper.queryAllRows();
    setState(() {
      userList = users;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 6.0,
        margin: EdgeInsets.symmetric(horizontal: 50.0, vertical: 12),
      ),
    );
  }

  void _insert() async {
    // Row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: nameController.text,
      DatabaseHelper.columnPhone: phoneController.text,
      DatabaseHelper.columnSSN: ssnController.text,
      DatabaseHelper.columnAddress: addressController.text,
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
    _clearAllFields();
    _refreshUserList();
    _showSnackBar('User inserted successfully');
  }

  void _update() async {
    // Row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: updateId,
      DatabaseHelper.columnName: nameController.text,
      DatabaseHelper.columnPhone: phoneController.text,
      DatabaseHelper.columnSSN: ssnController.text,
      DatabaseHelper.columnAddress: addressController.text,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
    _clearAllFields();
    _refreshUserList();
    _showSnackBar('User updated successfully');
  }

  void _delete(int id) async {
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
    _refreshUserList();
    _showSnackBar('User deleted successfully');
  }

  void _clearAllFields() {
    nameController.clear();
    phoneController.clear();
    ssnController.clear();
    addressController.clear();
    setState(() {
      isUpdating = false;
      updateId = null;
    });
  }

  void _editUser(Map<String, dynamic> user) {
    nameController.text = user[DatabaseHelper.columnName];
    phoneController.text = user[DatabaseHelper.columnPhone];
    ssnController.text = user[DatabaseHelper.columnSSN];
    addressController.text = user[DatabaseHelper.columnAddress];
    setState(() {
      isUpdating = true;
      updateId = user[DatabaseHelper.columnId];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ROOM DATABASE'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Contact Phone'),
              ),
              TextField(
                controller: ssnController,
                decoration: InputDecoration(labelText: 'SSN'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      phoneController.text.isEmpty ||
                      ssnController.text.isEmpty ||
                      addressController.text.isEmpty) {
                    _showSnackBar('Do not leave any field empty');
                  } else if (isUpdating) {
                    _update();
                  } else {
                    _insert();
                  }
                },
                child: Text(isUpdating ? 'UPDATE USER' : 'INSERT USER'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // background color
                  onPrimary: Colors.white, // text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 18.0), // Button padding
                ),
              ),
              SizedBox(height: 20,),
              ListView.builder(
                shrinkWrap: true,
                itemCount: userList.length,
                itemBuilder: (BuildContext context, int index) {
                  return UserCard(
                    user: userList[index],
                    onEdit: () => _editUser(userList[index]),
                    onDelete: () => _delete(userList[index][DatabaseHelper.columnId]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  UserCard({required this.user, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.account_circle),
        title: Text(user[DatabaseHelper.columnName]),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user[DatabaseHelper.columnPhone]}'),
            Text('${user[DatabaseHelper.columnSSN]}'),
            Text('${user[DatabaseHelper.columnAddress]}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
