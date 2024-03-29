import 'package:custom_mapbox_plugin/flutter_mapbox_navigation.dart';
import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen(this.waypoint, {super.key});

  final List<WayPoint> waypoint;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final bool _isMultipleStop = true;
  MapBoxNavigationViewController? _controller;
  bool cont = true;

  //double? _distanceRemaining, _durationRemaining;
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
  );

  @override
  void dispose() {
    //Restart.restartApp();
    _controller?.dispose();
    super.dispose();
  }
  /*@override
  Future<void> dispose() async {
    if(await _controller?.finishNavigation() == true) {
      _controller?.dispose();
    }
    super.dispose();
  }*/

  @override
  void initState() {
    if (!mounted) {
      Navigator.pop(context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapBoxNavigationView(
            options: opt,
            onRouteEvent: _onEmbeddedRouteEvent,
            onCreated: (MapBoxNavigationViewController controller) async {
              _controller = controller;
              controller.initialize();
              await _controller?.buildRoute(
                  wayPoints: widget.waypoint, options: opt);
            },
          ),
          Visibility(
            visible: !_routeBuilt,
            child: const Placeholder(),
          ),
        ],
      ),
    );
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    //_distanceRemaining = await MapBoxNavigation.instance.getDistanceRemaining();
    //_durationRemaining = await MapBoxNavigation.instance.getDurationRemaining();

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null) {}
        break;
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
          //_controller?.startNavigation(options: opt);
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
        /*if (!_isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          //await _controller?.finishNavigation();
        } else {
          setState(() {
            //_controller?.finishNavigation();
          });
        }*/
        break;
      case MapBoxEvent.navigation_finished:
        /*if (mounted) {
          Future.delayed(const Duration(seconds: 10));
          Navigator.pop(context);
        }*/

        break;
      case MapBoxEvent.navigation_cancelled:
        /*await _controller?.finishNavigation();
        //_controller?.clearRoute();
        if (mounted) {
          Navigator.pop(context);
        }*/
        //await dispose();
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      //case MapBoxEvent.deliver_button_tap:
      //showDialg();
      //break;
      default:
        break;
    }
    setState(() {});
  }


  void showDialg() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Conferma consegna ordine',
          style: TextStyle(
            fontFamily: 'Kulim Park',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0XFF1E1E1E),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Conferma la consegna dell ordine al cliente. \n Puoi lasciare delle note relative all ordine.',
              style: TextStyle(
                fontFamily: 'Kulim Park',
                fontWeight: FontWeight.w300,
                fontSize: 16,
                color: Color(0XFF616161),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0XFFFCFCFC),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(width: 2, color: const Color(0xFFD9D9D9)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  maxLines: 7,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText:
                        'Scrivi qui le note relative all’ordine (opzionale)',
                    hintStyle: TextStyle(
                      fontFamily: 'Kulim Park',
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: Color(0XFFC8C8C8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const SizedBox(
                  width: 130,
                  height: 60,
                  child: Center(
                    child: Text(
                      "Annulla",
                      style: TextStyle(
                        fontFamily: 'Kulim Park',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Color(0XFFFF7575),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 130,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(0, 165, 80, 0.2),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Center(
                    child: Text(
                      "Conferma",
                      style: TextStyle(
                        fontFamily: 'Kulim Park',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0XFF00A550),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
