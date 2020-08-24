import 'package:flutter/widgets.dart';
import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/db/user/user_role.dart';

class CaregiverPanelCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  CaregiverPanelCubit(this._activeUser, ModalRoute pageRoute) : super(pageRoute);

  void doLoadData() async {
	  var activeUser = _activeUser();
	  var children = await _dataRepository.getUsers(connected: activeUser.id, role: UserRole.child);
	  List<UIChild> childList = [];
	  for (var child in children) {
		  var plans = await _repeatabilityService.getPlansByDate(child.id, Date.now(), activeOnly: false);
		  childList.add(UIChild.fromDBModel(child, todayPlanCount: plans.length, hasActivePlan: await _dataRepository.getActiveChildPlanInstance(child.id)));
	  }
	  emit(CaregiverPanelLoadSuccess(childList, await _dataRepository.getUserNames((activeUser as UICaregiver).friends)));
  }
}

class CaregiverPanelLoadSuccess extends DataLoadSuccess {
	final List<UIChild> children;
	final Map<ObjectId, String> friends;

	CaregiverPanelLoadSuccess(this.children, this.friends);

	@override
	List<Object> get props => [children, friends];

	@override
	String toString() {
		return 'CaregiverPanelLoadSuccess{children: $children, friends: $friends}';
	}
}