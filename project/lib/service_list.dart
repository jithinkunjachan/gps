import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:gps_example/ble_controller.dart';

class ServiceList extends StatefulWidget {
  final ScanResult scanResult;

  const ServiceList(this.scanResult, {super.key});

  @override
  State<ServiceList> createState() => _ServiceListState();
}

class _ServiceListState extends State<ServiceList> {
  String result = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Service")),
      body: GetBuilder<BleController>(
        builder: (BleController controller) {
          return Column(
            children: [
              SingleChildScrollView(
                child: FutureBuilder<List<BluetoothService>>(
                  future: controller.services(widget.scanResult),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<BluetoothService>> snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Expanded(
                        flex: 2,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 2,
                                child: ListTile(
                                  title: Text(snapshot
                                      .data![index].characteristics.length
                                      .toString()),
                                  onTap: () {
                                    // controller.listen(snapshot.data![index]);
                                  },
                                ),
                              );
                            }),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              StreamBuilder<String>(
                  stream: controller.listenOut.stream,
                  builder: (context, snapshot) {
                    var result = "";
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      result = snapshot.data.toString();
                    }
                    return Text(result);
                  })
            ],
          );
        },
      ),
    );
  }
}
