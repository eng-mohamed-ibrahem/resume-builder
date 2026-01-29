import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumate/core/config/supabase_config.dart';
import 'package:resumate/core/services/supabase_service.dart';
import 'package:resumate/core/theme/app_theme.dart';
import 'package:resumate/core/theme/theme_cubit.dart';
import 'package:resumate/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:resumate/features/landing/presentation/pages/landing_page.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/resume/presentation/cubit/resume_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
  );
  if (kReleaseMode) {
    await SentryFlutter.init((options) {
      options.dsn =
          'https://6222aedddacc3f5bd20cbbaf72172b52@o4508256906379264.ingest.de.sentry.io/4510657822261328';
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 0.1;
      // Configure Session Replay
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
    }, appRunner: () => runApp(SentryWidget(child: const MyApp())));
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ResumeCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'ResuMate - ATS Resume Builder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const AuthAwareHome(),
          );
        },
      ),
    );
  }
}

/// Determines initial screen based on auth state
class AuthAwareHome extends StatelessWidget {
  const AuthAwareHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService().currentUser;

    // Show dashboard for authenticated users, landing page for guests
    if (user != null) {
      return const DashboardPage();
    }
    return const LandingPage();
  }
}
