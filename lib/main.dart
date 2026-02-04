// Written by Tim Hudson and Rafael Margary - Last updated4/2
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_parking/firebase_options.dart';
import 'package:smart_parking/homepage/search_page.dart';
import 'homepage/home_page.dart'; // Import HomePage
import 'homepage/traffic_page.dart'; // Import TrafficPage
import 'homepage/login_page.dart'; // Import LoginPage
import 'homepage/account_page.dart'; // Import AccountPage
import 'homepage/signup_page.dart'; // Import SignUpPage
import 'homepage/predicter.dart'; // Import PredicterPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SmartParking());
}

class SmartParking extends StatelessWidget {
  const SmartParking({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Parking Capstone Demo',
      theme: ThemeData(
        fontFamily: 'SF Pro',
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(255, 255, 255, 1)),
        useMaterial3: true,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: const Color.fromRGBO(255, 255, 255, 1),
          unselectedItemColor: const Color(0xFF2C2C2C),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  Key _pageKey = UniqueKey();

  Widget _getCurrentPage() {
    switch (currentPageIndex) {
      case 0:
        return PredicterPage(key: _pageKey);
      case 1:
        return HomePage(key: _pageKey);
      case 2:
        return TrafficPage(key: _pageKey);
      case 3:
        return SearchPage(key: _pageKey);
      case 4:
        return AccountPage(key: _pageKey);
      default:
        return PredicterPage(key: _pageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: SizedBox(
            height: 76,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.80,
                height: 56,
                decoration: BoxDecoration(
                  // off-white box behind the pill
                  color: const Color.fromRGBO(69, 0, 132, 1),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    navigationBarTheme: NavigationBarThemeData(
                      iconTheme: MaterialStateProperty.all(const IconThemeData(color: Colors.white)),
                      labelTextStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)),
                    ),
                  ),
                  child: NavigationBar(
                    backgroundColor: Colors.transparent,
                    onDestinationSelected: (int index) {
                      setState(() {
                        currentPageIndex = index;
                        _pageKey = UniqueKey(); // Generate new key to force page refresh
                      });
                    },
                    indicatorColor: const Color.fromRGBO(203, 182, 119, 1),
                    selectedIndex: currentPageIndex,
                    destinations: const <NavigationDestination>[
                      NavigationDestination(
                        icon: Icon(Icons.analytics_outlined),
                        label: 'Predicter',
                      ),
                      NavigationDestination(
                        selectedIcon: Icon(Icons.leaderboard),
                        icon: Icon(Icons.leaderboard_outlined),
                        label: 'Live Counter',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.today_outlined),
                        label: 'Today',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.map_outlined),
                        label: 'Map',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.manage_accounts_outlined),
                        label: 'Account',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _getCurrentPage(),
    );
  }
}

class AccountTab extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onAccount;
  final VoidCallback onGuest;

  const AccountTab({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.onAccount,
    required this.onGuest, // Added callback for guest entry
  });

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFB599CE)),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFB599CE),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creating an Account gives you access to the following features:',
                      style: TextStyle(color: Color(0xFF333333), fontSize: 18),
                    ),
                    Text(
                      '- Save a Home Address and Favorite Garage for instant traffic updates',
                      style: TextStyle(color: Color(0xFF333333), fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Account button (only enabled when logged in)
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  onPressed: user != null
                      ? onAccount
                      : null, // Only enable if logged in
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user != null
                        ? const Color(0xFFB599CE) // Purple when logged in
                        : Colors.grey, // Gray when not logged in
                    foregroundColor: const Color(0xFF333333),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('Account'),
                ),
              ),
              const SizedBox(height: 16),
              // "Enter as a Guest" button
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  onPressed: onGuest, // When clicked, navigate as a guest
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB599CE),
                    foregroundColor: const Color(0xFF333333),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('Enter as a Guest'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

              

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF2C2C2C),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MyHomePage(title: 'Home');
        } else {
          return Login(); // Send user to Login page first
        }
      },
    );
  }
}

