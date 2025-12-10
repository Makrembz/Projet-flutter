import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // Add a new employee
  Future addEmployeeDetails(
      Map<String, dynamic> employeeInfoMap,
      String id,
      ) async {
    return await FirebaseFirestore.instance
        .collection("Employee")
        .doc(id)
        .set(employeeInfoMap);
  }

  // Get all employees as a stream
  Future<Stream<QuerySnapshot>> getEmployeeDetails() async {
    return FirebaseFirestore.instance.collection("Employee").snapshots();
  }

  // Update an existing employee
  Future updateEmployee(String id, Map<String, dynamic> updatedData) async {
    return await FirebaseFirestore.instance
        .collection("Employee")
        .doc(id)
        .update(updatedData);
  }

  // Optionally: Delete an employee
  Future deleteEmployee(String id) async {
    return await FirebaseFirestore.instance
        .collection("Employee")
        .doc(id)
        .delete();
  }
}
