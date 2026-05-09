import 'package:blogapplictions/Api/FirebaseFCMService.dart';
import 'package:blogapplictions/Api/shared_preference.dart';
import 'package:blogapplictions/screen/auth/LoginScreen/LoginScreen.dart';
import 'package:blogapplictions/screen/auth/LoginScreen/bloc/sigUpBloc/sig_up_bloc.dart';
import 'package:blogapplictions/screen/homepage/Bloc/home_bloc.dart';
import 'package:blogapplictions/screen/widgets/bottomNavBar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blogapplictions/screen/homepage/homepages.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait Mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Shared Preferences
  await Prefs.init();

  // Firebase
  await Firebase.initializeApp();

  // FCM (Run in background to avoid blocking startup)
  getSafeFCMToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SigUpBloc>(create: (context) => SigUpBloc()),
        BlocProvider<HomeBloc>(create: (context) => HomeBloc()..add(FetchPosts())),
      ],
      child: MaterialApp(


        debugShowCheckedModeBanner: false,

        title: 'Blog Application',

        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,

          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
            brightness: Brightness.light,
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            foregroundColor: Colors.black,
          ),
        ),

        home: FirebaseAuth.instance.currentUser != null ? MyHomeScreens() : MyLoginScreen(),

      ),
    );
  }
}