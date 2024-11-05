import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geopulse/Frontend/Components/my_bottom_nav.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../location_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkIn(context);
    });
  }

  Future<void> checkIn(BuildContext context) async {
    if (!mounted) return;
    if (Provider.of<LocationProvider>(context, listen: false).isInProximity) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (
            context,
          ) =>
                  AlertDialog(
                    titleTextStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    ),
                    title: const Text(
                      "In Proximity",
                      style: TextStyle(
                        //----change the font here-----
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "OK",
                            style: TextStyle(fontSize: 22, color: Colors.blue),
                          )),
                    ],
                  )));
    } else {
      AlertDialog(
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        title: const Text(
          "Out of Proximity",
          style: TextStyle(
            //----change the font here-----
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(fontSize: 22, color: Colors.blue),
              )),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isInProximity =
        Provider.of<LocationProvider>(context, listen: false).isInProximity;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkIn(
        context,
      );
    });

    return MyBottomNav();
  }
}
