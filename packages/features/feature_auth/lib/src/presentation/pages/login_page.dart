import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';

/// Employee sign-in with the account's email + password. There is no
/// SSO and no persistent visitor account here — every employee first
/// activates their account via the `/register` flow (see
/// `RegisterPage`), which is what sets this password in the first
/// place; visitor guest-session entry is a separate, unauthenticated
/// route (see feature_visitor_management's kiosk check-in page).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<LoginBloc>(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: BlocConsumer<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state.status == LoginStatus.failure && state.errorMessage != null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'UNIGET',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Work email'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: 'Sign in',
                          isLoading: state.status == LoginStatus.submitting,
                          onPressed: () => context.read<LoginBloc>().add(
                                LoginSubmitted(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                ),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text("First time here? Activate your account"),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
