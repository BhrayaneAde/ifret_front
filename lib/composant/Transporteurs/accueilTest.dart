import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Chargeur extends StatefulWidget {
  const Chargeur({Key? key}) : super(key: key);

  @override
  State<Chargeur> createState() => _ChargeurState();
}

class _ChargeurState extends State<Chargeur> {
  var slidelist = ["A", "B", "C", "D"];
  final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFFCCE00),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Container(
          width: 180,
          height: 150,
          child: Image.asset('images/ifret.png'),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFFCCE00),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,

                    backgroundImage: NetworkImage(
                        'assets/images/a.jpeg'), // Avatar de placeholder
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Nom de l\'utilisateur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Completer vos Informations'),
              onTap: () {
                // Action à effectuer lorsque l'élément 1 est tapé
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Action à effectuer lorsque l'élément 2 est tapé
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10.0),
          child: Form(
            child: Align(
              alignment: Alignment.topCenter,
              child: CarouselSlider(
                items: [
                  'assets/images/image.jpg',
                  'assets/images/marche-transport-routier.jpg',
                  'assets/images/transport-terrestre-visuel.jpg',
                  'assets/images/affretement-routier.jpg',
                ].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(i),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (i == 'assets/images/image.jpg')
                              Text(
                                "${slidelist[0]}",
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            if (i ==
                                'assets/images/marche-transport-routier.jpg')
                              Text(
                                "${slidelist[1]}",
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            if (i ==
                                'assets/images/transport-terrestre-visuel.jpg')
                              Text(
                                "${slidelist[2]}",
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            if (i == 'assets/images/affretement-routier.jpg')
                              Text(
                                "${slidelist[3]}",
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  pauseAutoPlayOnTouch: true,
                  aspectRatio: 16 / 9,
                  onPageChanged: (index, reason) {
                    // Gestion de la page changée
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
