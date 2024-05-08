import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late YoutubePlayerController _controller;
  bool _isControllerDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = YoutubePlayerController(
      initialVideoId: 'u8H652UY-L8',
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeaderRow(),
          _buildVideoRow(),
          _buildButtonRow(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/hautTransport.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(),
            child: SizedBox.expand(),
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            child: Image.asset(
              'assets/images/ifret.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 27, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bienvenue sur I-FRET',
                    style: TextStyle(
                      color: const Color(0xFFFCCE00),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'La plateforme de Gestion de FRET',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoRow() {
    return Expanded(
      child: Center(
        child: _isControllerDisposed
            ? Container() // Retourne un conteneur vide si le contrôleur est disposé
            : YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blueAccent,
                onReady: () {
                  print('La vidéo est prête à être lue');
                },
                onEnded: (data) {
                  print('La vidéo est terminée');
                },
              ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          _disposeController();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            const Color(0xFFFCCE00),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
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
    );
  }

  void _disposeController() {
    if (!_isControllerDisposed) {
      _controller.pause();
      _controller.dispose();
      _isControllerDisposed = true;
    }
  }

  @override
  void dispose() {
    if (!_isControllerDisposed) {
      _disposeController();
    }
    super.dispose();
  }
}
