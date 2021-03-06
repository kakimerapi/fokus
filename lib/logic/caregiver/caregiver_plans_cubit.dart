import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class CaregiverPlansCubit extends ReloadableCubit {
	final MapEntry<ObjectId, String> _userID;
	final ActiveUserFunction _activeUser;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  CaregiverPlansCubit(this._activeUser, ModalRoute pageRoute, this._userID) : super(pageRoute);

  @override
	doLoadData() async {
    var getDescription = (Plan plan) => _repeatabilityService.buildPlanDescription(plan.repeatability);
    var caregiverId = _userID?.key ?? _activeUser().id;
    var plans = await _dataRepository.getPlans(caregiverId: caregiverId);
		emit(CaregiverPlansLoadSuccess(plans.map((plan) => UIPlan.fromDBModel(plan, getDescription(plan))).toList()));
  }
}

class CaregiverPlansLoadSuccess extends DataLoadSuccess {
	final List<UIPlan> plans;

	CaregiverPlansLoadSuccess(this.plans);

	@override
	List<Object> get props => [plans];
}
