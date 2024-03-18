import 'package:flutter/material.dart';
import 'package:iltfret/develop/login.dart';

const kAnimationDuration = Duration(milliseconds: 200);

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentPage = 0;
  PageController _pageController = PageController();
  List<String> splashImages = [
    "assets/images/page1.png",
    "assets/images/page2.png",
    "assets/images/page3.png"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                currentPage = value;
              });
            },
            itemCount: splashImages.length,
            itemBuilder: (context, index) => SplashPage(
              image: splashImages[index],
              isLastPage: index == splashImages.length - 1,
              onNextPressed: () {
                _pageController.nextPage(
                  duration: kAnimationDuration,
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: Text("Connectez-vous"),
            ),
          ),
        ],
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  final String image;
  final bool isLastPage;
  final VoidCallback? onNextPressed;

  const SplashPage({
    Key? key,
    required this.image,
    required this.isLastPage,
    this.onNextPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isLastPage)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                ),
                SizedBox(width: 20),
                SizedBox(height: 30),
                IconButton(
                  onPressed: onNextPressed,
                  icon: Icon(Icons.arrow_forward_ios),
                  color: Colors.white,
                ),
              ],
            ),
          if (isLastPage)
            SizedBox(
              width:
                  250, // Pour étendre le bouton sur toute la largeur disponible
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.white,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(120, 48), // Définir la largeur minimale du bouton
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'Se Connecter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
