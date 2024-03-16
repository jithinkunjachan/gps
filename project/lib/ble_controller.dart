import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;

  Stream<List<ScanResult>> get scanResults => ble.scanResults;
  StreamController<String> listenOut = StreamController();

  Future scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      if (await Permission.bluetoothConnect.request().isGranted) {
        await ble.startScan(
          scanMode: ScanMode.lowPower,
          timeout: const Duration(seconds: 5),
          allowDuplicates: true,
        );
        ble.stopScan();
      }
    }
  }

  Future<List<BluetoothService>> services(ScanResult scanResult) async {
    List<BluetoothService> services;
    try {
      await scanResult.device.connect();
    } catch (e) {
      rethrow;
    } finally {
      services = await scanResult.device.discoverServices();
    }
    return services;
  }

  Future<BluetoothCharacteristic?> connect(BluetoothDevice device) async {
    await device.disconnect();
    await device.connect(timeout: const Duration(seconds: 10));
    List<BluetoothService> services = await device.discoverServices();
    BluetoothCharacteristic? chars;
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
          chars = c;
          break;
        }
      }
    });
    return Future.value(chars);
  }
}
