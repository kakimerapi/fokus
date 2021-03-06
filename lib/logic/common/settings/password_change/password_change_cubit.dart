import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/common/formz_state.dart';
import 'package:fokus/model/ui/auth/password.dart';
import 'package:fokus/model/ui/auth/confirmed_password.dart';
import 'package:fokus_auth/fokus_auth.dart';

part 'password_change_state.dart';

class PasswordChangeCubit extends Cubit<PasswordChangeState> {
	final AuthenticationProvider _authenticationProvider = GetIt.I<AuthenticationProvider>();

  PasswordChangeCubit() : super(PasswordChangeState());

  Future changePasswordFormSubmitted() async {
	  var state = _validateFields();
	  if (!state.status.isValidated) {
		  emit(state);
		  return;
	  }
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
	  try {
		  await _authenticationProvider.changePassword(state.currentPassword.value, state.newPassword.value);
		  emit(state.copyWith(status: FormzStatus.submissionSuccess));
	  } on PasswordConfirmFailure catch (e) {
		  emit(state.copyWith(status: FormzStatus.submissionFailure, error: e.reason));
	  } on Exception {
		  emit(state.copyWith(status: FormzStatus.submissionFailure));
	  }
  }

  PasswordChangeState _validateFields() {
	  var state = this.state;
	  state = state.copyWith(currentPassword: Password.dirty(state.currentPassword.value, false));
	  state = state.copyWith(newPassword: Password.dirty(state.newPassword.value));
	  state = state.copyWith(confirmedPassword: state.confirmedPassword.copyDirty(original: state.newPassword));
	  return state.copyWith(status: Formz.validate([state.currentPassword, state.newPassword, state.confirmedPassword, state.confirmedPassword]));
  }

  void currentPasswordChanged(String value) => emit(state.copyWith(currentPassword: Password.pure(value, false), status: FormzStatus.pure));
  void newPasswordChanged(String value) => emit(state.copyWith(newPassword: Password.pure(value), status: FormzStatus.pure));
  void confirmedPasswordChanged(String value) => emit(state.copyWith(confirmedPassword: state.confirmedPassword.copyPure(value: value), status: FormzStatus.pure));
}
