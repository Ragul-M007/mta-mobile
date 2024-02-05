import 'package:flutter/material.dart';

class CircleImageFromNetwork extends StatelessWidget {
  final String imageUrl;
  final String defaultImageUrl;
  final double width;
  final double height;
  final double radius;




  const CircleImageFromNetwork({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.defaultImageUrl,
    required this.radius
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius, // Adjust the radius as needed
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: width, // Adjust the width as needed
          height: height, // Adjust the height as needed
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              defaultImageUrl,
              width: width, // Adjust the width as needed
              height: height, // Adjust the height as needed
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}