import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothDevice? connectedDevice;
  double temperature = 0.0;
  double humidity = 0.0;

  @override
  void initState() {
    super.initState();
    FlutterBlue.instance.scanResults.listen((results) {
      // Discover Bluetooth devices and search for your sensor device
      for (ScanResult result in results) {
        if (result.device.name == "Your Sensor Name") {
          // Replace with actual device name
          connectedDevice = result.device;
          connectDevice();
          break;
        }
      }
    });
  }

  void connectDevice() async {
    try {
      await connectedDevice!.connect();
      listenForData();
    } catch (e) {
      print("Koneksi Gagal: $e");
    }
  }

  void listenForData() async {
    connectedDevice!.services.listen((services) {
      services.forEach((service) {
        // Find the characteristic used for data transmission
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == "your_characteristic_uuid") {
            // Replace with actual characteristic UUID
            characteristic.value.listen((data) {
              // Parse received data (e.g., JSON format) and update UI
              String dataString = String.fromCharCodes(data);
              var jsonData = jsonDecode(dataString);
              setState(() {
                temperature = jsonData["temperature"];
                humidity = jsonData["humidity"];
              }); // Update UI with new readings
            });
            characteristic
                .setNotifyValue(true); // Enable notifications for data updates
          }
        });
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Temp and Humidity"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Temperature: $temperature °C",
              style: TextStyle(fontSize: 24),
            ),
            Text(
              "Humidity: $humidity %",
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
