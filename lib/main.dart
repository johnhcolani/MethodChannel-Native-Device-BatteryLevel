import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('samples.flutter.dev/battery');
  final StreamController<double> _batteryLevelController = StreamController<double>();

  @override
  void initState() {
    super.initState();
    _startBatteryLevelStream();
  }

  @override
  void dispose() {
    _batteryLevelController.close();
    super.dispose();
  }

  void _startBatteryLevelStream() {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        final int? result = await platform.invokeMethod<int>('getBatteryLevel');
        double batteryPercentage = (result ?? 0) / 100.0;
        _batteryLevelController.add(batteryPercentage);
      } on PlatformException catch (e) {
        print("Failed to get battery level: '${e.message}'.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: Center(
          child: StreamBuilder<double>(
            stream: _batteryLevelController.stream,
            builder: (context, snapshot) {
              double batteryPercentage = snapshot.data ?? 0.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(10, (index) {
                      int currentLevel = 10 - index;
                      return Container(
                        width: 100,
                        height: 20,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: batteryPercentage * 10 >= currentLevel
                            ? Colors.green
                            : Colors.white,
                      );
                    }),
                  ),
                  SizedBox(height: 10), // Space between containers and text
                  Text(
                    '${(batteryPercentage * 100).round()}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
