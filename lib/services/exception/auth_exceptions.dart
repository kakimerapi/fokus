import 'package:fokus_auth/fokus_auth.dart';

extension EmailSignUpErrorTextKey on EmailSignUpError {
	String get key => const {
		EmailSignUpError.emailAlreadyUsed: 'authentication.error.emailAlreadyUsed',
		EmailSignUpError.emailInvalid: 'authentication.error.emailInvalid',
	}[this];
}

extension EmailSignInErrorTextKey on EmailSignInError {
	String get key => const {
		EmailSignInError.wrongPassword: 'authentication.error.incorrectData',
		EmailSignInError.userNotFound: 'authentication.error.incorrectData',
		EmailSignInError.userDisabled: 'authentication.error.userDisabled',
	}[this];
}

extension PasswordChangeErrorCode on PasswordConfirmError {
	String get key => const {
		PasswordConfirmError.wrongPassword: 'authentication.error.incorrectPassword',
	}[this];
}
