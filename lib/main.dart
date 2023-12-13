import 'package:flutter/material.dart';
import 'package:sqllite_query/model/user.dart';
import 'package:sqllite_query/service/db_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  late List<User> userList;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    List<Map<String, dynamic>> users = await dbHelper.getUsers();
    setState(() {
      userList = users.map((user) => User.fromMap(user)).toList();
    });
  }

  Future<void> _addNewUser(String name, String email) async {
    await dbHelper.insertUser(User(name: name, email: email).toMap());
    await _loadUsers();
  }

  Future<void> _editUser(int id, String name, String email) async {
    await dbHelper.updateUser(User(id: id, name: name, email: email).toMap());
    await _loadUsers();
  }

  void _deleteUser(int? userId) async {
    if (userId != null) {
      await dbHelper.deleteUser(userId);
      await _loadUsers(); // Reload the user list after deletion
    } else {
      print("Id cannot be null");
      // Handle the case where userId is null (if needed)
    }
  }

  void _showAddUserModal(BuildContext context,
      {int? id, String? name, String? email}) {
    String newName = name ?? '';
    String newEmail = email ?? '';

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: TextEditingController(text: newName),
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  newName = value;
                },
              ),
              SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: newEmail),
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  newEmail = value;
                },
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (id != null) {
                    _editUser(id, newName, newEmail);
                  } else {
                    _addNewUser(newName, newEmail);
                  }
                  Navigator.pop(
                      context); // Close the modal after adding/editing the user
                },
                child: Text(id != null ? 'Edit User' : 'Add User'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User List ',
                style: TextStyle(color: Colors.cyanAccent, fontSize: 24),
              ),
              Text(
                ' | ',
              ),
              Text('Salauat Erejepov ', style: TextStyle(fontSize: 18))
            ],
          ),
        ),
        body: userList == null
            ? Center(child: CircularProgressIndicator())
            : userList.isEmpty
                ? Center(child: Text('No users found'))
                : ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(userList[index].name),
                        subtitle: Text(userList[index].email),
                        leading: IconButton(
                          onPressed: () => _deleteUser(userList[index].id),
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red.shade700,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () => _showAddUserModal(context,
                              id: userList[index].id,
                              // Replace with the actual user's ID
                              name: userList[index].name,
                              // Replace with the actual user's name
                              email: userList[index].email),
                          icon: Icon(
                            Icons.edit,
                            color: Colors.yellow,
                          ),
                        ),
                      );
                    },
                  ),
        floatingActionButton: IconButton(
            color: Colors.green,
            onPressed: () {
              _showAddUserModal(context);
            },
            icon: Icon(
              Icons.add,
              color: Colors.green,
            )));
  }
}
