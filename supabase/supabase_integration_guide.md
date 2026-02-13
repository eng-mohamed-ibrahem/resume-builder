# Supabase Integration Guide for Resume Builder

## 1. Add Dependencies to pubspec.yaml

```yaml
dependencies:
  supabase_flutter: ^2.3.4
  supabase_auth_ui: ^0.3.0
```

## 2. Run `flutter pub get`

## 3. Initialize Supabase in main.dart

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:resumate/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
    authOptions: const AuthOptions(
      autoRefreshToken: true,
      persistSession: true,
    ),
  );
  
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;
```

## 4. Create Supabase Service

Create `lib/core/services/supabase_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Authentication
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail(String email, String password, {String? fullName}) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authState => _client.auth.onAuthStateChange;

  // Resume Operations
  Future<List<Map<String, dynamic>>> getUserResumes() async {
    final response = await _client
        .from('resumes')
        .select()
        .eq('user_id', currentUser!.id)
        .order('updated_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createResume(String title) async {
    final response = await _client
        .from('resumes')
        .insert({
          'user_id': currentUser!.id,
          'title': title,
          'template_name': 'modern',
        })
        .select()
        .single();
    
    return response;
  }

  Future<void> updateResume(String resumeId, Map<String, dynamic> data) async {
    await _client
        .from('resumes')
        .update(data)
        .eq('id', resumeId)
        .eq('user_id', currentUser!.id);
  }

  Future<void> deleteResume(String resumeId) async {
    await _client
        .from('resumes')
        .delete()
        .eq('id', resumeId)
        .eq('user_id', currentUser!.id);
  }

  // Resume Sections Operations
  Future<List<Map<String, dynamic>>> getResumeSections(String resumeId) async {
    final response = await _client
        .from('resume_sections')
        .select()
        .eq('resume_id', resumeId)
        .order('section_order', ascending: true);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createSection(String resumeId, String type, String title, int order) async {
    final response = await _client
        .from('resume_sections')
        .insert({
          'resume_id': resumeId,
          'section_type': type,
          'section_title': title,
          'section_order': order,
        })
        .select()
        .single();
    
    return response;
  }

  // Header Section Operations
  Future<void> updateHeaderSection(String sectionId, Map<String, dynamic> headerData) async {
    await _client
        .from('header_sections')
        .upsert({
          'section_id': sectionId,
          ...headerData,
        },
        onConflict: 'section_id');
  }

  Future<Map<String, dynamic>?> getHeaderSection(String sectionId) async {
    final response = await _client
        .from('header_sections')
        .select()
        .eq('section_id', sectionId)
        .maybeSingle();
    
    return response;
  }

  // Experience Operations
  Future<List<Map<String, dynamic>>> getWorkExperiences(String sectionId) async {
    final response = await _client
        .from('work_experiences')
        .select('*, experience_points(*)')
        .eq('section_id', sectionId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createWorkExperience(String sectionId, Map<String, dynamic> experienceData) async {
    final response = await _client
        .from('work_experiences')
        .insert({
          'section_id': sectionId,
          ...experienceData,
        })
        .select()
        .single();
    
    return response;
  }

  Future<void> updateWorkExperience(String experienceId, Map<String, dynamic> data) async {
    await _client
        .from('work_experiences')
        .update(data)
        .eq('id', experienceId);
  }

  Future<void> deleteWorkExperience(String experienceId) async {
    await _client
        .from('work_experiences')
        .delete()
        .eq('id', experienceId);
  }

  // Experience Points
  Future<void> updateExperiencePoints(String experienceId, List<String> points) async {
    // Delete existing points
    await _client
        .from('experience_points')
        .delete()
        .eq('experience_id', experienceId);

    // Insert new points
    if (points.isNotEmpty) {
      final pointsData = points.asMap().entries.map((entry) => {
        'experience_id': experienceId,
        'point_text': entry.value,
        'point_order': entry.key,
      }).toList();

      await _client
          .from('experience_points')
          .insert(pointsData);
    }
  }

  // Similar methods for other sections (Education, Skills, Projects, etc.)
  // You can implement these following the same pattern

  // Profile Operations
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    await _client
        .from('profiles')
        .update(profileData)
        .eq('id', currentUser!.id);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();
    
    return response;
  }
}
```

## 5. Create Authentication Screens

Create `lib/features/auth/screens/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:resumate/core/services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Sign Up' : 'Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                    ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(_isSignUp ? 'Already have an account? Sign In' : 'Need an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabaseService = SupabaseService();
      
      if (_isSignUp) {
        await supabaseService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful! Please check your email.')),
        );
      } else {
        await supabaseService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

## 6. Update App Structure

Create `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:resumate/features/auth/screens/login_screen.dart';
import 'package:resumate/features/resume/presentation/pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResuMate - ATS Resume Builder',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue.shade800,
        ),
      ),
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final session = snapshot.data?.session;
          if (session != null) {
            return const HomePage();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
```

## 7. Environment Configuration

Create `.env` file in your project root:

```
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Add to `.gitignore`:
```
.env
```

## 8. Setup Instructions

1. **Create Supabase Project**: Go to [supabase.com](https://supabase.com) and create a new project

2. **Run SQL Schema**: Copy the contents of `supabase_schema.sql` and run it in your Supabase SQL Editor

3. **Get Credentials**: From your Supabase project settings, get:
   - Project URL
   - anon/public key

4. **Update Environment**: Fill in your credentials in the `.env` file

5. **Update main.dart**: Replace the placeholder values with your actual Supabase credentials

6. **Test Authentication**: Run the app and test sign up/sign in functionality

## 9. Next Steps

After setting up authentication, you can:

1. Update your existing resume cubit to use SupabaseService instead of local storage
2. Implement CRUD operations for all resume sections
3. Add real-time collaboration features
4. Implement resume sharing functionality
5. Add export/import features with cloud storage

The schema supports all the resume sections you currently have in your app, with proper relationships and security policies.
