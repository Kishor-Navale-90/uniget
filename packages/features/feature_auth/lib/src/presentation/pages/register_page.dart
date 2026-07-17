import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../bloc/registration/registration_bloc.dart';
import '../bloc/registration/registration_event.dart';
import '../bloc/registration/registration_state.dart';

/// First-time account activation: Super Admin/Department Admin
/// pre-adds an employee's official email, then the employee lands
/// here to claim their account — email → OTP → set password. One
/// route with a client-managed step (mirroring
/// `feature_asset_management`'s multi-step register wizard) rather
/// than three separate routes, so the in-progress email/registration
/// token never needs to survive a route transition.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<RegistrationBloc>(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: BlocConsumer<RegistrationBloc, RegistrationState>(
                  listener: (context, state) {
                    if (state.status == RegistrationStatus.failure && state.errorMessage != null) {
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
                          'Activate your UNIGET account',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        switch (state.step) {
                          RegistrationStep.enterEmail => const _EnterEmailStep(),
                          RegistrationStep.verifyOtp => _VerifyOtpStep(email: state.email ?? ''),
                          RegistrationStep.setPassword => const _SetPasswordStep(),
                          RegistrationStep.completed => const _CompletedStep(),
                        },
                        const SizedBox(height: AppSpacing.sm),
                        if (state.step == RegistrationStep.enterEmail)
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Already activated? Sign in'),
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

class _EnterEmailStep extends StatefulWidget {
  const _EnterEmailStep();

  @override
  State<_EnterEmailStep> createState() => _EnterEmailStepState();
}

class _EnterEmailStepState extends State<_EnterEmailStep> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select((RegistrationBloc bloc) => bloc.state.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Enter the official email your admin registered you with — we'll send you a one-time code.",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Work email'),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Send code',
          isLoading: status == RegistrationStatus.submitting,
          onPressed: () => context
              .read<RegistrationBloc>()
              .add(RegistrationEmailSubmitted(_emailController.text.trim())),
        ),
      ],
    );
  }
}

class _VerifyOtpStep extends StatefulWidget {
  const _VerifyOtpStep({required this.email});
  final String email;

  @override
  State<_VerifyOtpStep> createState() => _VerifyOtpStepState();
}

class _VerifyOtpStepState extends State<_VerifyOtpStep> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select((RegistrationBloc bloc) => bloc.state.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter the code emailed to ${widget.email}.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'One-time code'),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Verify code',
          isLoading: status == RegistrationStatus.submitting,
          onPressed: () =>
              context.read<RegistrationBloc>().add(RegistrationOtpSubmitted(_otpController.text.trim())),
        ),
      ],
    );
  }
}

class _SetPasswordStep extends StatefulWidget {
  const _SetPasswordStep();

  @override
  State<_SetPasswordStep> createState() => _SetPasswordStepState();
}

class _SetPasswordStepState extends State<_SetPasswordStep> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select((RegistrationBloc bloc) => bloc.state.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Set a password for your account.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New password'),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Activate account',
          isLoading: status == RegistrationStatus.submitting,
          onPressed: () => context
              .read<RegistrationBloc>()
              .add(RegistrationPasswordSubmitted(_passwordController.text)),
        ),
      ],
    );
  }
}

class _CompletedStep extends StatelessWidget {
  const _CompletedStep();

  @override
  Widget build(BuildContext context) {
    // The app-shell router redirects away from here automatically the
    // instant SessionManager's session is set (see AuthRepositoryImpl);
    // this is only ever visible for a brief moment.
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
