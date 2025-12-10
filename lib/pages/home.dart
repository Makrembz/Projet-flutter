import 'package:crub_mini_app/pages/employee.dart';
import 'package:crub_mini_app/services/database.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream? EmplyeeStream;

  getontheload() async {
    EmplyeeStream = await DatabaseMethods().getEmployeeDetails();
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget allEmployeeDetails() {
    return StreamBuilder(
      stream: EmplyeeStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            var employee = snapshot.data.docs[index];
            return Container(
              margin: EdgeInsets.only(top: 10),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Name : " + employee["Name"],
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () {
                                  EditEmployeeDetail(employee.id, employee);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteEmployee(employee.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        "Age : " + employee["Age"],
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "Location : " + employee["Location"],
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Employee()),
          );
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Flutter ",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Firebase ",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 20),
        child: Column(
          children: [
            Expanded(child: allEmployeeDetails()),
          ],
        ),
      ),
    );
  }

  Future EditEmployeeDetail(String id, dynamic employee) async {
    TextEditingController nameController =
    TextEditingController(text: employee["Name"]);
    TextEditingController ageController =
    TextEditingController(text: employee["Age"]);
    TextEditingController locationController =
    TextEditingController(text: employee["Location"]);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Employee Details"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: "Location"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Map<String, dynamic> updatedData = {
                "Name": nameController.text,
                "Age": ageController.text,
                "Location": locationController.text,
              };
              DatabaseMethods().updateEmployee(id, updatedData);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  // Delete employee with confirmation
  void deleteEmployee(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this employee?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              DatabaseMethods().deleteEmployee(id);
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }
}
