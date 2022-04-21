import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  await dotenv.load();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _fb = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Spotify Tinder',
      theme: const CupertinoThemeData(
        primaryColor: Color.fromRGBO(30, 215, 96, 1),
        brightness: Brightness.dark,
        textTheme: CupertinoTextThemeData(primaryColor: Colors.white),
        // splashColor: Colors.transparent,
        scaffoldBackgroundColor: Color.fromRGBO(10, 10, 10, 1),
        barBackgroundColor: Color.fromRGBO(10, 10, 10, 1),
      ),
      // themeMode: ThemeMode.dark,
      home: FutureBuilder(
        future: _fb,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error.toString());
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return const SplashScreen();
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Color.fromRGBO(30, 215, 96, 1)),
            );
          }
        },
      ),
      //   onGenerateRoute: (RouteSettings routeSettings) {
      //     return MaterialPageRoute(
      //       builder: (context) {
      //         if (routeSettings.name!.contains("callback")) {
      //           print('queryParametersAll');
      //           print(Uri.base.queryParametersAll);
      //           String? token = Uri.base.toString().substring(Uri.base.toString().indexOf('token=') + 6);
      //           String? refresh_token = Uri.base.toString().substring(Uri.base.toString().indexOf('refresh_token=') + 14);
      //           print(token);
      //           print(refresh_token);
      //           if (token.isNotEmpty) {
      //             Future.wait(<Future>[SecureStorage.setToken(token), SecureStorage.setRefreshToken(refresh_token)])
      //                 .then((value) async => {print('tokens saved'), Navigator.pushReplacementNamed(context, "/")});
      //           }
      //         }
      //         return Container();
      //       },
      //     );
      //   },
    );
  }
}
