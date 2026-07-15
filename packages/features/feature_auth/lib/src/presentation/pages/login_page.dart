import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Employee login screen (concept doc §8.1: SSO first, OTP fallback).
/// Visitor guest-session entry is a separate, unauthenticated route —
/// see feature_visitor_management's kiosk check-in page — so this
/// page never needs to branch on "is this a visitor".
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state.status == AuthStatus.failure && state.errorMessage != null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
                  }
                },
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('GateFlow', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Continue with Company SSO',
                        isLoading: state.status == AuthStatus.loading,
                        onPressed: () => context
                            .read<AuthBloc>()
                            .add(const AuthSsoLoginRequested('placeholder-sso-id-token')),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('or', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Sign in with Email OTP',
                        variant: AppButtonVariant.secondary,
                        onPressed: () =>
                            context.read<AuthBloc>().add(const AuthOtpRequested('user@company.com')),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
