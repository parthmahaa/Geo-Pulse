import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyCard extends StatefulWidget {
  // Location variables 23.043090, 72.578822

  static const double officeLatitude = 23.043090;
  static const double officeLongitude = 72.578822;
  static const double geofenceRadius = 5;

  // Card variables
  final String title;
  final IconData icon;
  final String index;

  const MyCard({
    super.key,
    required this.index, // Added index field to use the cards separately
    required this.title,
    required this.icon,
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  bool isLoading = false; // Loading state for progress indicator

  @override
  Widget build(BuildContext context) {
    // Card widget is rapped with InkWell widget which will just provide the onTap functionality to the card widget.
    return InkWell(
      // onTap added for check-in functionality
      borderRadius:
          BorderRadius.circular(15.0), // Match the card's border radius
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show a CircularProgressIndicator if loading, otherwise show the icon
              if (isLoading)
                CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.surface)
              else
                Icon(
                  widget.icon,
                  size: 60,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              const SizedBox(height: 10),
              // Show a nothing if loading (circularProgressIndicator is show in above code), otherwise show the icon
              if (!isLoading)
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
