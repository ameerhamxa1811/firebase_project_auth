import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_project/presentation/home_screen/profile_screen.dart';
import 'package:firebase_project/presentation/home_screen/provider/home_screen_provider.dart';
import 'package:firebase_project/presentation/login_screen/provider/signin_provider.dart';
import 'package:firebase_project/presentation/login_screen/signin_screen.dart';
import 'package:firebase_project/presentation/signup_screen/provider/signup_provider.dart';
import 'package:firebase_project/presentation/signup_screen/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import flutter_screenutil
import 'core/utils/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => SignInProvider()),
        ChangeNotifierProvider(create: (context) => HomeScreenProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 790),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Flex',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const SignInScreen(),
          );
        },
      ),
    );
  }
}
