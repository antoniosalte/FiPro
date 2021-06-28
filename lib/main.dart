import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((SharedPreferences prefs) {
    bool isLightTheme = prefs.getBool('isLightTheme') ?? true;
    runApp(MyApp(isLightTheme: isLightTheme));
  });
}

class MyApp extends StatelessWidget {
  MyApp({this.isLightTheme});

  final bool? isLightTheme;

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(isLightTheme: isLightTheme),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Fipro',
            theme: themeProvider.getThemeData,
            home: FutureBuilder(
              future: _initialization,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SomethingWentWrong();
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  return AuthManager(title: 'Fipro');
                }

                return Loading();
              },
            ),
          );
        },
      ),
    );
  }
}

/// Maneja los estados de la aplicaión.
/// Si un usuario esta autenticado muestra la aplicación y su jugabilidad.
/// Si un usuario no esta autenticado muestra la pantalla para el inicio de sesión.
class AuthManager extends StatelessWidget {
  AuthManager({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: true);

    if (authProvider.isAuthenticated) {
      return HomeScreen();
    } else {
      // return AuthScreen();
      return HomeScreen();
    }
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: CircularProgressIndicator(),
    ));
  }
}

class SomethingWentWrong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text('Error'),
    ));
  }
}
