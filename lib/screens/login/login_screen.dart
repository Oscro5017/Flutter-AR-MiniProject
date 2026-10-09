import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.user;
  final TextEditingController _emailController = TextEditingController(text: "user@example.com");
  final TextEditingController _nameController = TextEditingController(text: "User");

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      if (role == UserRole.admin) {
        _emailController.text = "admin@arfurniture.com";
        _nameController.text = "System Admin";
      } else {
        _emailController.text = "user@example.com";
        _nameController.text = "User";
      }
    });
  }

  void _login() {
    context.read<UserProvider>().login(
          name: _nameController.text.trim().isEmpty
              ? (_selectedRole == UserRole.admin ? "System Admin" : "User")
              : _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? (_selectedRole == UserRole.admin ? "admin@arfurniture.com" : "user@example.com")
              : _emailController.text.trim(),
          role: _selectedRole,
        );
    context.go("/home");
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chair_alt_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "AR Furniture",
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Decorate your space in 3D",
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 32),
                  _buildRoleSelector(context),
                  const SizedBox(height: 24),
                  _buildTextField(context, "Email", Icons.email_outlined, controller: _emailController),
                  const SizedBox(height: 16),
                  _buildTextField(context, "Password", Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        _selectedRole == UserRole.admin ? "Sign In as Admin" : "Sign In",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      context.read<UserProvider>().setRole(UserRole.user);
                      context.go("/home");
                    },
                    child: Text(
                      "Continue as Guest",
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _onRoleChanged(UserRole.user),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedRole == UserRole.user ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 18,
                      color: _selectedRole == UserRole.user ? Colors.white : AppColors.getTextSecondary(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "General User",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedRole == UserRole.user ? Colors.white : AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _onRoleChanged(UserRole.admin),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedRole == UserRole.admin ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 18,
                      color: _selectedRole == UserRole.admin ? Colors.white : AppColors.getTextSecondary(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Admin Role",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedRole == UserRole.admin ? Colors.white : AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String hint, IconData icon, {TextEditingController? controller, bool isPassword = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: AppColors.textPrimary(context)),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.getTextSecondary(context), size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
