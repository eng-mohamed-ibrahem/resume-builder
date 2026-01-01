import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumate/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/resume/presentation/cubit/resume_cubit.dart';
import 'features/resume/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cufkffvmrynfiryyabgu.supabase.co',
    anonKey: 'sb_publishable_99_ZOPloZCNYS43ZimwMQw_7ULwYl_n',
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResumeCubit(),
      child: MaterialApp(
        title: 'ResuMate - ATS Resume Builder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Use system theme by default
        home: const HomePage(),
      ),
    );
  }
}
