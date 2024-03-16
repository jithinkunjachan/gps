import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:gps/image.dart' as image_convert;
import 'package:gps_example/ble_controller.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TILE"),
      ),
      body: GetBuilder<BleController>(
        builder: (BleController controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: !loading
                          ? () async {
                              setState(() {
                                loading = true;
                              });
                              await controller.scanDevices();
                              setState(() {
                                loading = false;
                              });
                            }
                          : null,
                      child: const Text("SCAN"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final res = await NotificationListenerService
                            .requestPermission();
                        debugPrint("Is enabled: $res");
                      },
                      child: const Text("Open Permissions"),
                    ),
                    ElevatedButton(
                      onPressed: () async {},
                      child: const Text("Read"),
                    ),
                    loading ? const CircularProgressIndicator() : Container(),
                  ],
                ),
                StreamBuilder<List<ScanResult>>(
                  stream: controller.scanResults,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ScanResult>> snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Text(snapshot.data![index].device.name),
                                ElevatedButton(
                                    onPressed: () async {
                                      final blc = await controller.connect(
                                          snapshot.data![index].device);
                                      if (!context.mounted) return;
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BleListenAndServe(blc!),
                                        ),
                                      );
                                    },
                                    child: const Text("connect")),
                              ],
                            );
                          },
                          itemCount: snapshot.data!.length,
                        ),
                      );
                    }
                    return const Text("Error while scanning");
                  },
                ),
              ],
            ),
          );
        },
        init: BleController(),
      ),
    );
  }
}

class BleListenAndServe extends StatelessWidget {
  late Isolate? isolate;
  final ReceivePort port = ReceivePort();

  Uint8List image = Uint8List.fromList([0, 2, 5, 7, 42, 255]);
  BluetoothCharacteristic blc;
  bool started = false;

  BleListenAndServe(this.blc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(blc.deviceId.id),
      ElevatedButton(
          onPressed: () {
            NotificationListenerService.notificationsStream
                .listen((event) async {
              if (event.packageName == "net.osmand") {
                if (started) {
                  debugPrint("sleeping");
                  do {
                    sleep(const Duration(microseconds: 10));
                  } while (!started);
                }
                if (!started) {
                  started = true;
                  final imageEncoded = base64.encode(event.largeIcon!);
                  final input = imageEncoded.toNativeUtf8().cast<Int8>();
                  final sumResult = image_convert.imageConverts(input);
                  image = base64.decode(sumResult.cast<Utf8>().toDartString());
                  await write(image);
                  var title = event.title ?? "";
                  debugPrint(event.toString());
                  final split = title.split("•");
                  title = split[0];
                  debugPrint(title);
                  await write(title.codeUnits);
                  started = false;
                }
              }
            });
          },
          child: const Text("Send Data")),
      ElevatedButton(onPressed: () {}, child: const Text("STOP"))
    ]);
  }

  Future<void> write(List<int> a) async {
    try {
      return await blc.write(a, withoutResponse: false);
    } catch (e) {
      sleep(const Duration(seconds: 1));
      return write(a);
    }
  }
}
