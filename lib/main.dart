import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nextcart/app/app_router.dart';
import 'package:nextcart/core/theme/app_theme.dart';
import 'package:nextcart/core/theme/theme_provider.dart';
import 'package:nextcart/firebase_options.dart';

// Web Client ID dari Google Cloud Console (OAuth 2.0 > Web client)
const _serverClientId =
    '908202737543-gu0e5lv5cj475mrpvd4ookndk8lu32ui.apps.googleusercontent.com';

Future<void> main() async {
  // 1. Inisialisasi binding Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load .env
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("DotEnv loaded successfully");
  } catch (e) {
    debugPrint("CRITICAL: DotEnv loading error: $e");
  }

  // 3. Inisialisasi Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("Firebase initialized successfully");
    } else {
      debugPrint("Firebase already initialized");
    }
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  // 4. Inisialisasi GoogleSignIn v7.x — WAJIB dipanggil sekali sebelum dipakai
  try {
    await GoogleSignIn.instance.initialize(
      serverClientId: _serverClientId,
    );
    debugPrint("GoogleSignIn initialized successfully");
  } catch (e) {
    debugPrint("GoogleSignIn Initialization Error: $e");
  }

  // 5. Jalankan aplikasi
  runApp(
    const ProviderScope(
      child: NextCartApp(),
    ),
  );
}

class NextCartApp extends ConsumerWidget {
  const NextCartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'NextCart',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: router,
        );
      },
    );
  }
}