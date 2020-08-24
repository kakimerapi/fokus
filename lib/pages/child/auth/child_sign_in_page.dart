import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:smart_select/smart_select.dart';

import 'package:fokus/logic/auth/child/sign_up/child_sign_up_cubit.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_avatar.dart';
import 'package:fokus/widgets/auth/auth_button.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/model/ui/auth/user_code.dart';
import 'package:fokus/model/ui/auth/name.dart';
import 'package:fokus/widgets/auth/auth_widgets.dart';
import 'package:fokus/logic/auth/child/sign_in/child_sign_in_cubit.dart';

class ChildSignInPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.childSignIn';
	
  @override
  Widget build(BuildContext context) {
	  return Scaffold(
		  body: SafeArea(
			  child: ListView(
					padding: EdgeInsets.symmetric(vertical: AppBoxProperties.screenEdgePadding),
					shrinkWrap: true,
					children: [
						_buildSignUpForm(context),
						AuthFloatingButton(
							icon: Icons.arrow_back,
							action: () => Navigator.of(context).pop(),
							text: AppLocales.of(context).translate('page.loginSection.backToLoginPage')
						)
					]
				)
		  ),
	  );
  }

  Widget _buildSignUpForm(BuildContext context) {
	  return AuthGroup(
			title: AppLocales.of(context).translate('$_pageKey.profileAddTitle'),
			hint: AppLocales.of(context).translate('$_pageKey.profileAddHint'),
			content: ListView(
				shrinkWrap: true,
				children: <Widget>[
					AuthenticationInputField<ChildSignInCubit, ChildSignInState>(
						getField: (state) => state.childCode, // temp
						changedAction: (cubit, value) => cubit.childCodeChanged(value), // temp
						labelKey: '$_pageKey.childCode',
						icon: Icons.screen_lock_portrait,
						getErrorKey: (state) => [state.childCode.error.key], // temp
					),
					AuthButton(
						button: UIButton(
							'$_pageKey.addProfile',
							() => context.bloc<ChildSignInCubit>().signInNewChild(),
							Colors.orange
						)
					),
					AuthDivider(),
					AuthenticationInputField<ChildSignUpCubit, ChildSignUpState>(
						getField: (state) => state.caregiverCode,
						changedAction: (cubit, value) => cubit.caregiverCodeChanged(value),
						labelKey: '$_pageKey.caregiverCode',
						icon: Icons.phonelink_lock,
						getErrorKey: (state) => [state.caregiverCode.error.key],
					),
					AuthenticationInputField<ChildSignUpCubit, ChildSignUpState>(
						getField: (state) => state.name,
						changedAction: (cubit, value) => cubit.nameChanged(value),
						labelKey: 'authentication.name',
						icon: Icons.edit,
						getErrorKey: (state) => [state.name.error.key],
					),
					_buildAvatarPicker(context),
					AuthButton(
						button: UIButton(
							'$_pageKey.createNewProfile',
							() => context.bloc<ChildSignUpCubit>().signUpFormSubmitted(),
							Colors.orange
						)
					)
				]
			)
		);
	}

	Widget _buildAvatarPicker(BuildContext context) {
		return BlocBuilder<ChildSignUpCubit, ChildSignUpState>(
			buildWhen: (oldState, newState) => oldState.avatar != newState.avatar || oldState.caregiverCode != newState.caregiverCode,
			cubit: BlocProvider.of<ChildSignUpCubit>(context),
			builder: (context, state) {
				return Padding(
					padding: EdgeInsets.symmetric(vertical: 10.0),
					child: SmartSelect<int>.single(
						title: AppLocales.of(context).translate('authentication.avatar'),
						builder: (context, selectState, callback) {
							bool isInvalid = (state.status == FormzStatus.invalid && state.avatar == null);
							return ListTile(
								leading: SizedBox(
									width: 56.0,
									height: 64.0,
									child: state.avatar != null ? AppAvatar(state.avatar) : AppAvatar.blank()
								),
								title: Text(AppLocales.of(context).translate('authentication.avatar')),
								subtitle: Text(isInvalid ? 
										AppLocales.of(context).translate('authentication.error.avatarEmpty')
										: (state.avatar == null) ?
											AppLocales.of(context).translate('actions.tapToSelect')
											: AppLocales.of(context).translate('actions.selected'),
									style: TextStyle(color: isInvalid ? Theme.of(context).errorColor : Colors.grey),
									overflow: TextOverflow.ellipsis,
									maxLines: 1
								),
								trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
								onTap: () => callback(context)
							);
						},
						value: state.avatar,
						options: List.generate(childAvatars.length, (index) {
							final String name = AppLocales.of(context).translate('$_pageKey.avatarGroups.${childAvatars[index].label.toString().split('.').last}');
							return SmartSelectOption(
								title: name,
								group: name,
								value: index,
								disabled: state.takenAvatars.contains(index)
							);
						}),
						choiceConfig: SmartSelectChoiceConfig(
							glowingOverscrollIndicatorColor: Colors.teal,
							runSpacing: 10.0,
							spacing: 10.0,
							useWrap: true,
							isGrouped: true,
							builder: (item, checked, onChange) {
								return GestureDetector(
									onTap: item.disabled ? null : () => { onChange(item.value, !checked) },
									child: AppAvatar(item.value, checked: checked, disabled: item.disabled)
								);
							}
						),
						modalType: SmartSelectModalType.bottomSheet,
						onChange: (val) {
							FocusManager.instance.primaryFocus.unfocus();
							context.bloc<ChildSignUpCubit>().avatarChanged(val);
						}
					)
				);
			}
		);
	}

}