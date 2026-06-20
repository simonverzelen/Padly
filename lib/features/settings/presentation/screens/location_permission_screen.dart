import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/core/constants.dart';
import 'package:padly/core/route/route_constants.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with WidgetsBindingObserver {
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationStatus().then((_) {
        if (_locationEnabled && mounted) {
          _autoNavigate();
        }
      });
    }
  }

  void _autoNavigate() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, selectLanguageScreenRoute);
    }
  }

  Future<void> _checkLocationStatus() async {
    final status = await Permission.location.status;
    if (mounted) {
      setState(() {
        _locationEnabled = status.isGranted;
      });
    }
  }

  Future<void> _handleToggle(bool value) async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      await openAppSettings();
      return;
    }

    final result = await Permission.location.request();
    await _checkLocationStatus();

    if (result.isGranted && mounted) {
      _autoNavigate();
    } else {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Scaffold(
      appBar: canPop
          ? AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    color: cardBackgroundColor,
                    child: Center(
                      child: const Icon(LucideIcons.mapPin, size: 80, color: primaryColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          "Find matches near you — share your location.",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        const Text(
                          "Allow Padly to use your location to show nearby courts and matches in your area.",
                        ),
                        const SizedBox(height: defaultPadding * 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadious),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.mapPin, size: 24, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Location',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              CupertinoSwitch(
                                onChanged: _handleToggle,
                                activeTrackColor: primaryColor,
                                value: _locationEnabled,
                                thumbColor: primaryMaterialColor.shade900,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!canPop)
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, selectLanguageScreenRoute);
                },
                child: const Text("Continue"),
              ),
            ),
        ],
      ),
    );
  }
}
