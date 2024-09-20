// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';


class MyCard extends StatelessWidget {
  final double balance;
  final String cardHeader;
  final int cardNumber;
  final int expiryMonth;
  final int expiryYear;
  final Color color;
  final String backgroundImage; // Add image as a variable

  const MyCard({
    super.key,
    required this.balance,
    required this.cardHeader,
    required this.cardNumber,
    required this.color,
    required this.expiryMonth,
    required this.expiryYear,
    required this.backgroundImage, // Required background image
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(1), // Set the color with opacity
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(backgroundImage), // Pass the background image
            fit: BoxFit.cover, // Fit the image to cover the container
            colorFilter: ColorFilter.mode(
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5), // Dull transparency effect
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cardHeader,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "\Kshs$balance",
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cardNumber.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                Text(
                  "$expiryMonth/$expiryYear",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}