import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_auth/src/domain/usecases/check_registration_email.dart';
import 'package:feature_auth/src/domain/usecases/request_registration_otp.dart';
import 'package:feature_auth/src/domain/usecases/set_password.dart';
import 'package:feature_auth/src/domain/usecases/verify_registration_otp.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCheckRegistrationEmail extends Mock implements CheckRegistrationEmail {}

class _MockRequestRegistrationOtp extends Mock implements RequestRegistrationOtp {}

class _MockVerifyRegistrationOtp extends Mock implements VerifyRegistrationOtp {}

class _MockSetPassword extends Mock implements SetPassword {}

void main() {
  setUpAll(() {
    registerFallbackValue(const VerifyRegistrationOtpParams(email: '', otp: ''));
    registerFallbackValue(const SetPasswordParams(registrationToken: '', password: ''));
  });

  late _MockCheckRegistrationEmail checkRegistrationEmail;
  late _MockRequestRegistrationOtp requestRegistrationOtp;
  late _MockVerifyRegistrationOtp verifyRegistrationOtp;
  late _MockSetPassword setPassword;

  setUp(() {
    checkRegistrationEmail = _MockCheckRegistrationEmail();
    requestRegistrationOtp = _MockRequestRegistrationOtp();
    verifyRegistrationOtp = _MockVerifyRegistrationOtp();
    setPassword = _MockSetPassword();
  });

  RegistrationBloc buildBloc() =>
      RegistrationBloc(checkRegistrationEmail, requestRegistrationOtp, verifyRegistrationOtp, setPassword);

  const user = AppUser(id: '1', name: 'Rupesh', email: 'r@company.com', role: UserRole.employee);

  blocTest<RegistrationBloc, RegistrationState>(
    'moves to the verifyOtp step once the email is eligible and the OTP is sent',
    setUp: () {
      when(() => checkRegistrationEmail(any())).thenAnswer((_) async => const Right(unit));
      when(() => requestRegistrationOtp(any())).thenAnswer((_) async => const Right(unit));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const RegistrationEmailSubmitted('r@company.com')),
    expect: () => [
      const RegistrationState(status: RegistrationStatus.submitting, email: 'r@company.com'),
      const RegistrationState(
        status: RegistrationStatus.idle,
        step: RegistrationStep.verifyOtp,
        email: 'r@company.com',
      ),
    ],
  );

  blocTest<RegistrationBloc, RegistrationState>(
    'fails without requesting an OTP when the email is not eligible',
    setUp: () {
      when(() => checkRegistrationEmail(any()))
          .thenAnswer((_) async => const Left(ValidationFailure('Email not recognized')));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const RegistrationEmailSubmitted('unknown@company.com')),
    expect: () => [
      const RegistrationState(status: RegistrationStatus.submitting, email: 'unknown@company.com'),
      const RegistrationState(
        status: RegistrationStatus.failure,
        email: 'unknown@company.com',
        errorMessage: 'Email not recognized',
      ),
    ],
    verify: (_) {
      verifyNever(() => requestRegistrationOtp(any()));
    },
  );

  blocTest<RegistrationBloc, RegistrationState>(
    'moves to the setPassword step once the OTP is verified',
    seed: () => const RegistrationState(step: RegistrationStep.verifyOtp, email: 'r@company.com'),
    setUp: () {
      when(() => verifyRegistrationOtp(any())).thenAnswer((_) async => const Right('reg-token'));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const RegistrationOtpSubmitted('123456')),
    expect: () => [
      const RegistrationState(
        status: RegistrationStatus.submitting,
        step: RegistrationStep.verifyOtp,
        email: 'r@company.com',
      ),
      const RegistrationState(
        status: RegistrationStatus.idle,
        step: RegistrationStep.setPassword,
        email: 'r@company.com',
        registrationToken: 'reg-token',
      ),
    ],
  );

  blocTest<RegistrationBloc, RegistrationState>(
    'completes the wizard once the password is set',
    seed: () => const RegistrationState(
      step: RegistrationStep.setPassword,
      email: 'r@company.com',
      registrationToken: 'reg-token',
    ),
    setUp: () {
      when(() => setPassword(any())).thenAnswer((_) async => const Right(user));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const RegistrationPasswordSubmitted('s3cret!')),
    expect: () => [
      const RegistrationState(
        status: RegistrationStatus.submitting,
        step: RegistrationStep.setPassword,
        email: 'r@company.com',
        registrationToken: 'reg-token',
      ),
      const RegistrationState(
        status: RegistrationStatus.idle,
        step: RegistrationStep.completed,
        email: 'r@company.com',
        registrationToken: 'reg-token',
      ),
    ],
  );
}
