import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/user_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Llamamos al signIn del userController
      await ref.read(userControllerProvider.notifier)
        .signIn(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
    }
    if (mounted) {
      context.go('/'); // o context.goNamed('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observamos el estado del UserController para manejar loading, error, etc.
    final userState = ref.watch(userControllerProvider);

    final isLoading = userState.isLoading; 
    final hasError = userState.hasError;
    final error = userState.error;

    // Si hay un error (e.g. credenciales inválidas), se podría mostrar en un SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Campo de Email
                CustomTextField(
                  controller: _emailCtrl,
                  label: 'Correo electrónico',
                  hint: 'ejemplo@correo.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su correo';
                    }
                    // Podemos agregar una validación más elaborada
                    if (!value.contains('@')) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo de Contraseña
                CustomTextField(
                  controller: _passwordCtrl,
                  label: 'Contraseña',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botón de Login
                PrimaryButton(
                  text: 'Iniciar Sesión',
                  onPressed: _login,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
