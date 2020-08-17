import 'package:formz/formz.dart';

import 'package:fokus/logic/auth/caregiver/caregiver_auth_cubit_base.dart';
import 'package:fokus/model/ui/auth/email.dart';
import 'package:fokus/model/ui/auth/password.dart';
import 'package:fokus/logic/auth/caregiver/caregiver_auth_state_base.dart';
import 'package:fokus/services/exception/auth_exceptions.dart';

part 'caregiver_sign_in_state.dart';


class CaregiverSignInCubit extends CaregiverAuthCubitBase<CaregiverSignInState> {
  CaregiverSignInCubit() : super(CaregiverSignInState());

	Future<void> logInWithCredentials() async {
		if (!state.status.isValidated) return;
		emit(state.copyWith(status: FormzStatus.submissionInProgress));
		try {
			await authenticationRepository.signInWithEmail(
				email: state.email.value,
				password: state.password.value,
			);
			emit(state.copyWith(status: FormzStatus.submissionSuccess));
		} on EmailSignInFailure catch (e) {
			emit(state.copyWith(status: FormzStatus.submissionFailure, error: e.reason));
		}
	}

  void emailChanged(String value) {
	  final email = Email.dirty(value);
	  emit(state.copyWith(
		  email: email,
		  status: Formz.validate([email, state.password]),
	  ));
  }

  void passwordChanged(String value) {
	  final password = Password.dirty(value, false);
	  emit(state.copyWith(
		  password: password,
		  status: Formz.validate([state.email, password]),
	  ));
  }
}