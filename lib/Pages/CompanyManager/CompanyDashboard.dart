import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vehicle/Pages/CompanyManager/GenerateReport.dart';
import 'package:vehicle/Pages/CompanyManager/SystemManagement.dart';
import 'package:vehicle/Pages/CompanyManager/myprofile.dart';

import 'package:vehicle/Pages/CompanyManager/VehicleRegistration.dart';
import '../../Database/HiveAdminDb.dart';
import 'package:vehicle/models/user.dart';
import 'package:vehicle/models/vehicle.dart';
import 'package:vehicle/models/parking_slot.dart'; // Import your models

class CompanyManagerDashboard extends StatefulWidget {
  final String email;

  const CompanyManagerDashboard({super.key, required this.email});

  @override
  _CompanyManagerDashboardState createState() =>
      _CompanyManagerDashboardState();
}

class _CompanyManagerDashboardState extends State<CompanyManagerDashboard> {
  String userName = ''; // Store the user's name
  int totalUsers = 0;
  int totalVehicles = 0;
  int occupiedSlots = 0;
  int totalSlots = 0;
  double pendingPayments = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchUsersData();
    _fetchVehicleData();
    _fetchParkingSlotData();
    _fetchPaymentsData();
  }

  // Method to fetch the user's name
  Future<void> _fetchUserName() async {
    var userBox = await Hive.openBox<User>('users');
    User? user = userBox.get(widget.email);
    if (user != null) {
      setState(() {
        userName = user.name;
      });
    }
  }

  // Method to fetch the total number of registered users
  Future<void> _fetchUsersData() async {
    var userBox = await Hive.openBox<User>('users');
    setState(() {
      totalUsers = userBox.length;
    });
  }

  // Method to fetch the total number of registered vehicles
  Future<void> _fetchVehicleData() async {
    var vehicleBox = await Hive.openBox<Vehicle>('vehicles');
    setState(() {
      totalVehicles = vehicleBox.length;
    });
  }

  // Method to fetch parking slots data (occupied and total)
  Future<void> _fetchParkingSlotData() async {
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    setState(() {
      totalSlots = parkingSlotBox.length;
      occupiedSlots = parkingSlotBox.values
          .where((slot) => slot.isOccupied == true)
          .length;
    });
  }

  // Method to fetch pending payments data (for now, we assume it's pre-calculated)
  Future<void> _fetchPaymentsData() async {
    // Assuming this is some pre-calculated or manually added data in Hive
    setState(() {
      pendingPayments = 500.0; // Placeholder for the example
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $userName'), // Display user's name dynamically
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profilePage');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFFCF6F5), // Bottom background color
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF63D1F6), // Top background color
                ),
                child: Text(
                  'Company Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(email: widget.email)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_pin_sharp),
                title: const Text('System Management'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SystemManagementPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Vehicle Management'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VehicleRegistrationPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Reports'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GenerateReportPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Hive Data Store'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HiveAdminPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview section
              Card(
                color: const Color(0xFF63D1F6), // Background color for overview section
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF585D61), // Text color
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Users Card
                      Card(
                        color: const Color(0xFF63D1F6),
                        elevation: 4,
                        shadowColor: Colors.grey[400],
                        child: ListTile(
                          leading: const Icon(Icons.people, color: Color(0xFF585D61)),
                          title: const Text('Users',
                              style: TextStyle(color: Color(0xFF585D61))),
                          subtitle: Text('Total Registered Users: $totalUsers',
                              style: const TextStyle(color: Color(0xFF585D61))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Vehicles Card
                      Card(
                        color: const Color(0xFF63D1F6),
                        elevation: 4,
                        shadowColor: Colors.grey[400],
                        child: ListTile(
                          leading: const Icon(Icons.directions_car,
                              color: Color(0xFF585D61)),
                          title: const Text('Vehicles',
                              style: TextStyle(color: Color(0xFF585D61))),
                          subtitle: Text(
                              'Total Registered Vehicles: $totalVehicles',
                              style: const TextStyle(color: Color(0xFF585D61))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Parking Slots Card
                      Card(
                        color: const Color(0xFF63D1F6),
                        elevation: 4,
                        shadowColor: Colors.grey[400],
                        child: ListTile(
                          leading: const Icon(Icons.local_parking,
                              color: Color(0xFF585D61)),
                          title: const Text('Parking Slots',
                              style: TextStyle(color: Color(0xFF585D61))),
                          subtitle: Text(
                              'Occupied Slots: $occupiedSlots / $totalSlots',
                              style: const TextStyle(color: Color(0xFF585D61))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Insights section
              Card(
                color: const Color(0xFFDEAF4B), // Background color for insights section
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Insights',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF585D61), // Text color
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Parking Utilization Card
                      Card(
                        color: const Color(0xFFDEAF4B),
                        elevation: 4,
                        shadowColor: Colors.grey[400],
                        child: ListTile(
                          leading:
                              const Icon(Icons.bar_chart, color: Color(0xFF585D61)),
                          title: const Text('Parking Utilization',
                              style: TextStyle(color: Color(0xFF585D61))),
                          subtitle: Text(
                              '${(occupiedSlots / totalSlots * 100).toStringAsFixed(1)}% of parking slots are occupied',
                              style: const TextStyle(color: Color(0xFF585D61))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Payments Card
                      Card(
                        color: const Color(0xFFDEAF4B),
                        elevation: 4,
                        shadowColor: Colors.grey[400],
                        child: ListTile(
                          leading: const Icon(Icons.attach_money,
                              color: Color(0xFF585D61)),
                          title: const Text('Payments',
                              style: TextStyle(color: Color(0xFF585D61))),
                          subtitle: Text('Pending Payments: \$${pendingPayments.toStringAsFixed(2)}',
                              style: const TextStyle(color: Color(0xFF585D61))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}