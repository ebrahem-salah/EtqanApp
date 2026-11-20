import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/deep_link_service.dart';
import 'providers/auth_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة سحابة Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // 2. تهيئة خدمة الإشعارات اللحظية والمنبهات لنظامي أندرويد وآبل
  await NotificationService().initialize(
    onSelectNotification: (payload) {
      if (payload != null && payload.startsWith('circle_')) {
        final id = int.tryParse(payload.replaceAll('circle_', ''));
        if (id != null) {
          DeepLinkService.instance.handleIncomingUri(Uri.parse('etqan://circle/$id'));
        }
      }
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const EtqanApp(),
    ),
  );
}

class EtqanApp extends StatelessWidget {
  const EtqanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: DeepLinkService.navigatorKey,
      title: 'إتقان',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Arabic RTL Localization
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
