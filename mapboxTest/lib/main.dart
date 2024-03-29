import 'package:custom_mapbox_plugin/flutter_mapbox_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_test/point.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Points points = Points();
  final bool _isMultipleStop = true;
  MapBoxNavigationViewController? _controller;
  bool cont = true;
  bool _routeBuilt = false;
  bool _isNavigating = false;

  MapBoxOptions opt = MapBoxOptions(
    language: "en",
    simulateRoute: true,
    animateBuildRoute: true,
    voiceInstructionsEnabled: true,
    bannerInstructionsEnabled: true,
    units: VoiceUnits.metric,
    mode: MapBoxNavigationMode.drivingWithTraffic,
    isOptimized: true,
    allowsUTurnAtWayPoints: true,
    enableRefresh: true,
    longPressDestinationEnabled: false,
    code: "ABC-abc-12354",
  );

  @override
  void initState() {
    super.initState();
    initialize();
    setPref();
    requestPermission();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> setPrefOK() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("deliverAPI", "OK");
    debugPrint(
        "==========================setPrefOK=================================");
  }

  Future<void> setPref() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("deliverAPI", "PAUSE");
  }

  Future<void> initialize() async {
    if (!mounted) return;
    MapBoxNavigation.instance.registerRouteEventListener(_onEmbeddedRouteEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NavigationScreen(
                      [points.syncroweb, points.gru],
                    ),
                  ),
                );
              },
              child: Text(
                "Mappa 3",
                style: GoogleFonts.kulimPark(
                    textStyle: const TextStyle(color: Colors.blue),),
              ),
            ),
            ElevatedButton(
              child: const Text("Start A to B"),
              onPressed: () async {
                if (await requestPermission()) {
                  await MapBoxNavigation.instance.startNavigation(
                    wayPoints: [points.syncroweb, points.gru],
                    options: opt,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> requestPermission() async {
    const permission = Permission.camera;

    if (await permission.isDenied) {
      await permission.request();
      return false;
    } else {
      return true;
    }
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          await _controller?.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        await _controller?.finishNavigation();
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      case MapBoxEvent.deliver_button_tap:
        debugPrint("=========Button deliver tapped========");
        break;
      case MapBoxEvent.order_delivered:
        debugPrint("========Order delivered=========");
        Future.delayed(const Duration(seconds: 5));
        var a = await MapBoxNavigation.instance.getDeliverNotes();
        debugPrint("Deliver notes: $a");
        setPrefOK();
        break;
      case MapBoxEvent.next_trip_button_tap:
        debugPrint("=======next_trip_button_tap=======");
        break;
      default:
        break;
    }
    setState(() {});
  }
}
