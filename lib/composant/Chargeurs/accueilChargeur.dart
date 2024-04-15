import 'package:flutter/material.dart';
import 'package:ifret/composant/Chargeurs/profilChargeur.dart';

class Chargeur extends StatefulWidget {
  final String name;
  final String profileUrl;
  final String username;

  Chargeur({
    required this.name,
    required this.profileUrl,
    required this.username,
  });

  @override
  State<Chargeur> createState() => _ChargeurState();
}

class _ChargeurState extends State<Chargeur> {
  List<Message> _messages = [];
  TextEditingController _messageController = TextEditingController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*   appBar: AppBar(
        backgroundColor: Color(0xFF553370),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Color(0xFFc199cd),
          ),
        ),
        title: Text(
          widget.name,
          style: TextStyle(
            color: Color(0xFFc199cd),
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
     */
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white, // Couleur de fond blanc
        selectedItemColor:
            Color(0xFFFCCE00), // Couleur de l'élément sélectionné
        unselectedItemColor:
            Colors.black, // Couleur des éléments non sélectionnés
        items: [
          _bottomNavigationBarItem(
            icon: Icons.mail,
            label: 'Messagerie',
            index: 0,
          ),
          _bottomNavigationBarItem(
            icon: Icons.payment,
            label: 'Paiement',
            index: 1,
          ),
          _bottomNavigationBarItem(
            icon: Icons.car_crash,
            label: 'Tracking',
            index: 2,
          ),
          _bottomNavigationBarItem(
            icon: Icons.person,
            label: 'Profil',
            index: 3,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _bottomNavigationBarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
      backgroundColor: Colors.white, // Fond blanc pour tous les éléments
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _getMessages();
      case 1:
        return Paiement();
      case 2:
        return Tracking();
      case 3:
        return ProfilChargeur();
      default:
        return Container(); // Gestion d'un cas par défaut si nécessaire
    }
  }

  Widget _getMessages() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.only(bottom: 90.0, top: 130),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final reversedIndex = _messages.length - 1 - index;
                return chatMessageTile(_messages[reversedIndex]);
              },
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  onSubmitted: (messageText) {
                    sendMessage(messageText);
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Message",
                    hintStyle: TextStyle(color: Colors.black45),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sendMessage(_messageController.text);
                },
                child: Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget chatMessageTile(Message message) {
    return Row(
      mainAxisAlignment:
          message.sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight:
                    message.sendByMe ? Radius.circular(0) : Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft:
                    message.sendByMe ? Radius.circular(24) : Radius.circular(0),
              ),
              color: message.sendByMe
                  ? Color.fromARGB(255, 234, 236, 240)
                  : Color.fromARGB(255, 211, 228, 243),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void sendMessage(String messageText) {
    Message message = Message(text: messageText, sendByMe: true);
    setState(() {
      _messages.add(message);
      _messageController.clear();
    });
  }
}

class Message {
  final String text;
  final bool sendByMe;

  Message({required this.text, required this.sendByMe});
}
/* 
class MesInformations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Informations'),
      ),
      body: Center(
        child: Text('Contenu de Mes Informations'),
      ),
    );
  }
} */

class Paiement extends StatefulWidget {
  @override
  _PaiementState createState() => _PaiementState();
}

class _PaiementState extends State<Paiement> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  appBar: AppBar(
        title: Text('Paiement'),
      ), */
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 20),
          Expanded(
            child: _currentTabIndex == 0
                ? PaiementLocal()
                : PaiementInternational(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 245, 234, 234),
        currentIndex: _currentTabIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border:
                    Border.all(color: const Color.fromARGB(255, 252, 250, 250)),
                color: _currentTabIndex == 0 ? Color(0xFFFCCE00) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_sharp,
                      color:
                          _currentTabIndex == 0 ? Colors.white : Colors.black),
                  SizedBox(width: 8.0),
                  Text(
                    'Paiement Local',
                    style: TextStyle(
                        color: _currentTabIndex == 0
                            ? Colors.white
                            : Colors.black),
                  ),
                ],
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Color.fromARGB(255, 247, 245, 245)),
                color: _currentTabIndex == 1 ? Color(0xFFFCCE00) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_sharp,
                      color:
                          _currentTabIndex == 1 ? Colors.white : Colors.black),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Paiement International',
                      style: TextStyle(
                          color: _currentTabIndex == 1
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/hautPaiement1.jpg', // Chemin de votre image
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
                /*  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Color.fromARGB(255, 248, 134, 3).withOpacity(0.3)
                ],
              ), */
                ),
            child:
                SizedBox.expand(), // Pour étendre le dégradé sur toute l'image
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            child: Image.asset(
              'assets/images/ifret.png', // Chemin de votre image
              width: 70, // Largeur de l'image
              height: 70, // Hauteur de l'image
              fit: BoxFit.cover, // Ajustement de l'image
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 27, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentTabIndex == 0
                        ? 'Paiement Local'
                        : 'Paiement International',
                    style: TextStyle(
                      color: Color(0xFFFCCE00),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'En Ligne',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
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
}

class PaiementLocal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          Center(
            child: Text(
              'Choisissez un moyen de paiement local:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 70.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement local (Fedapay MTN)
                  // Ajoutez le code de traitement pour le paiement local ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/mtn.png', height: 30.0),
                    SizedBox(width: 8.0),
                  ],
                ),
              ),
              /* SizedBox(height: 16.0), */
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement local (Fedapay Moov)
                  // Ajoutez le code de traitement pour le paiement local ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/moov.png', height: 30.0),
                    SizedBox(width: 8.0),
                    /* Text('Moov'), */
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class PaiementInternational extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          Center(
            child: Text(
              'Choisissez un moyen de paiement international:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement international (Visa)
                  // Ajoutez le code de traitement pour le paiement international ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/visa.png', height: 20.0),
                    SizedBox(width: 8.0),
                    /* Text('Visa'), */
                  ],
                ),
              ),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement international (PayPal)
                  // Ajoutez le code de traitement pour le paiement international ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/paypal.png', height: 20.0),
                    SizedBox(width: 8.0),
                    /* Text('PayPal'), */
                  ],
                ),
              ),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement international (MasterCard)
                  // Ajoutez le code de traitement pour le paiement international ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/mastercard-2.png', height: 20.0),
                    SizedBox(width: 8.0),
                    /*  Text('MasterCard'), */
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Tracking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking'),
      ),
      body: Center(
        child: Text('Contenu de Tracking'),
      ),
    );
  }
}
