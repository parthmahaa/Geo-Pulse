import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geopulse/Backend/authentication.dart';
import 'package:geopulse/Frontend/Admin%20Pages/admin_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geopulse/Frontend/Employee%20Pages/my_home_page.dart';
import 'package:geopulse/Frontend/sign_in_page.dart';
import 'package:geopulse/Frontend/Themes/color_palette.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import './location_provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import './Frontend//Components/my_card.dart';
import './notifications.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeService();
  await NotificationService.initNotification();
  await Permission.location.request();

  runApp(MultiProvider(
    providers: [
      // Theme provider
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => LocationProvider()),
    ],
    child: const MyApp(),
  ));
}

// The onStart function for background service
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Background Location Service",
      content: "Your location is being tracked in the background.",
    );
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // Check permissions before starting location updates
  bool locationEnabled = await Geolocator.isLocationServiceEnabled();
  if (!locationEnabled) {
    print(
        "Location services are not enabled"); // Location services are not enabled
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    print("Location services denied forever");
    return; // Permission denied, exit
  }
  // Start listening for location updates
  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Update when the user moves 10 meters
    ),
  ).listen((Position position) async {
    // Handle the location update and calculate geofencing
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      MyCard.officeLatitude,
      MyCard.officeLongitude,
    );
    print(
        'Latitude:${position.latitude} , Longitude: ${position.longitude} , Distance: $distance ,Time: ${DateTime.now()}');

    if (distance < MyCard.geofenceRadius) {
      await NotificationService.proximityNotification(
          "In Proximity", "You are in the Office proximity");
      print("in sent");
    }
    bool isInProximity = distance <= MyCard.geofenceRadius;

    service.invoke(
      'updateProximity',
      {'isInProximity': isInProximity},
    );
  });
}

// Initialize the background service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId:
          'location_channel', // Ensure this ID matches the created channel
      initialNotificationTitle: 'Monitoring Location',
      initialNotificationContent: 'Tracking location for attendance',
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      autoStart: true,
    ),
  );

  if (Platform.isAndroid) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "location_channel",
      'Location Service',
      playSound: true,
      ledColor: Colors.white,
      description: "This channel is used for location tracking",
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  try {
    await service.startService();
    print("Service Started");
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static String userID = "";
  static String name = "";
  static String email = "";
  static String phone = "";
  static String user = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geopulse',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context, listen: false).themeData,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            // Use FutureBuilder to wait for fetchUserData() to complete
            return FutureBuilder(
              future: fetchUserData(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(strokeWidth: 5));
                }
                if (MyApp.user == "admin") {
                  return const AdminHomePage();
                } else {
                  return HomePage();
                }
              },
            );
          }
          return const MySignIn();
        },
      ),
    );
  }
}
