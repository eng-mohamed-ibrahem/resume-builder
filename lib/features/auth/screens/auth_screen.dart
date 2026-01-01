import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resumate/core/services/supabase_service.dart';
import 'package:resumate/features/resume/presentation/cubit/resume_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const AuthScreen({super.key, this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.5),
              colorScheme.surface,
              colorScheme.surface,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -100,
              right: -100,
              child: _buildBlurryCircle(
                color: colorScheme.primary.withValues(alpha: 0.2),
                size: 400,
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _buildBlurryCircle(
                color: colorScheme.tertiary.withValues(alpha: 0.2),
                size: 300,
              ),
            ),

            // Main Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Card(
                        elevation: 0,
                        color: theme.cardTheme.color?.withValues(alpha: 0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Header
                                    _buildHeader(theme),
                                    const SizedBox(height: 32),

                                    // Form Fields
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: Column(
                                        children: [
                                          if (_isSignUp) ...[
                                            _buildTextField(
                                              controller: _fullNameController,
                                              label: 'Full Name',
                                              icon:
                                                  Icons.person_outline_rounded,
                                              validator: (v) =>
                                                  v?.trim().isEmpty == true
                                                  ? 'Required'
                                                  : null,
                                            ),
                                            const SizedBox(height: 16),
                                          ],

                                          _buildTextField(
                                            controller: _emailController,
                                            label: 'Email Address',
                                            icon: Icons.email_outlined,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator: (v) {
                                              if (v == null || v.isEmpty) {
                                                return 'Required';
                                              }
                                              if (!v.contains('@')) {
                                                return 'Invalid email';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),

                                          _buildTextField(
                                            controller: _passwordController,
                                            label: 'Password',
                                            icon: Icons.lock_outline_rounded,
                                            isPassword: true,
                                            obscureText: _obscurePassword,
                                            onToggleVisibility: () => setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            ),
                                            validator: (v) =>
                                                (v?.length ?? 0) < 6
                                                ? 'Min 6 characters'
                                                : null,
                                          ),

                                          if (_isSignUp) ...[
                                            const SizedBox(height: 16),
                                            _buildTextField(
                                              controller:
                                                  _confirmPasswordController,
                                              label: 'Confirm Password',
                                              icon: Icons.lock_outline_rounded,
                                              isPassword: true,
                                              obscureText:
                                                  _obscureConfirmPassword,
                                              onToggleVisibility: () => setState(
                                                () => _obscureConfirmPassword =
                                                    !_obscureConfirmPassword,
                                              ),
                                              validator: (v) =>
                                                  v != _passwordController.text
                                                  ? 'Passwords do not match'
                                                  : null,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Action Button
                                    SizedBox(
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _handleSubmit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme.primary,
                                          foregroundColor:
                                              colorScheme.onPrimary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          elevation: 4,
                                          shadowColor: colorScheme.primary
                                              .withValues(alpha: 0.4),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : Text(
                                                _isSignUp
                                                    ? 'Create Account'
                                                    : 'Sign In',
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Toggle Mode
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isSignUp
                                              ? 'Already have an account? '
                                              : 'New to ResuMate? ',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _isSignUp = !_isSignUp;
                                              _formKey.currentState?.reset();
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            _isSignUp ? 'Sign In' : 'Sign Up',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.description_rounded,
            size: 48,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'ResuMate',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSignUp
              ? 'Start building your professional future'
              : 'Welcome back, ready to iterate?',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 22,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }

  Widget _buildBlurryCircle({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabaseService = SupabaseService();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isSignUp) {
        await supabaseService.signUpWithEmail(
          email,
          password,
          fullName: _fullNameController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Success! Please check your email to verify account.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isSignUp = false;
            _isLoading = false;
          });
        }
      } else {
        final response = await supabaseService.signInWithEmail(email, password);

        if (response.user != null && mounted) {
          if (widget.onLoginSuccess != null) {
            widget.onLoginSuccess!();
          } else {
            // Default behavior: Load data and close screen
            await context.read<ResumeCubit>().loadUserResumes();
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Authentication failed';
        if (e is AuthException) {
          msg = e.message;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
