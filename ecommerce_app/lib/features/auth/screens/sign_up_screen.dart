// lib/features/auth/screens/sign_up_screen.dart
import 'package:ecommerce_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Shared obscureText state for the password field
  final RxBool _obscurePassword = true.obs;

  // --- REUSABLE PREMIUM INPUT FIELD ---
  // We centralise the styling here so every field is pixel-perfect consistent.
  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: Colors.white,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF71717A)), // zinc-500
        prefixIcon: Icon(icon, color: const Color(0xFF52525B), size: 20), // zinc-600
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF18181B), // zinc-900
        // Default border — subtle and understated
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF27272A), width: 1), // zinc-800
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF27272A), width: 1),
        ),
        // Focused border — white, crisp
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        // Error border — red accent without breaking the dark feel
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      // We use a SafeArea + scroll so the form stays accessible on smaller
      // devices when the keyboard pushes everything up.
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── TOP NAV ──────────────────────────────────────────────
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF27272A)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ).animate().fade(duration: 300.ms),

                // ── HEADER ───────────────────────────────────────────────
                const SizedBox(height: 48),

                // Subtle label above the main heading — same pattern as
                // many premium SaaS apps: small context → big headline.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF27272A)),
                  ),
                  child: const Text(
                    'NEW ACCOUNT',
                    style: TextStyle(
                      color: Color(0xFF71717A),
                      fontSize: 11,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 20),

                const Text(
                  'Create your\naccount.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    height: 1.15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ).animate().fade(delay: 150.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 10),

                const Text(
                  'Join us and start shopping today.',
                  style: TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),

                // ── FORM FIELDS ──────────────────────────────────────────
                const SizedBox(height: 48),

                _buildField(
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your name';
                    if (v.trim().length < 2) return 'Name is too short';
                    return null;
                  },
                ).animate().fade(delay: 250.ms).slideY(begin: 0.15, end: 0),

                const SizedBox(height: 16),

                _buildField(
                  label: 'Email Address',
                  icon: Icons.mail_outline_rounded,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    // Basic email format check
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ).animate().fade(delay: 300.ms).slideY(begin: 0.15, end: 0),

                const SizedBox(height: 16),

                // Password field with a show/hide toggle.
                // We use Obx here because _obscurePassword is a reactive RxBool.
                Obx(
                  () => _buildField(
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    controller: passwordController,
                    obscure: _obscurePassword.value,
                    suffixIcon: IconButton(
                      onPressed: () => _obscurePassword.toggle(),
                      icon: Icon(
                        _obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF52525B),
                        size: 20,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter a password';
                      if (v.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                ).animate().fade(delay: 350.ms).slideY(begin: 0.15, end: 0),

                // ── TERMS NOTICE ─────────────────────────────────────────
                const SizedBox(height: 24),

                const Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                  style: TextStyle(
                    color: Color(0xFF52525B), // zinc-600
                    fontSize: 12,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 380.ms),

                // ── SUBMIT BUTTON ────────────────────────────────────────
                const SizedBox(height: 32),

                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: authController.isLoading.value
                        ? Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF18181B),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                authController.signup(
                                  nameController.text.trim(),
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );
                              }
                            },
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                  ),
                ).animate().fade(delay: 400.ms).slideY(begin: 0.3, end: 0),

                // ── LOGIN REDIRECT ───────────────────────────────────────
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Color(0xFF71717A), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ).animate().fade(delay: 450.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}