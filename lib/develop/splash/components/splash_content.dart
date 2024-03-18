import 'package:flutter/material.dart';

class SplashContent extends StatefulWidget {
  const SplashContent({
    Key? key,
    this.image,
  }) : super(key: key);
  final String? image;

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height *
            0.7, // Ajustez la hauteur maximale des images ici
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.image!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
