import 'package:bson/bson.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/user/ui_user.dart';

class UIChild extends UIUser {
	final int todayPlanCount;
	final bool hasActivePlan;
	final Map<CurrencyType, int> points;

  UIChild(ObjectId id, String name, {this.todayPlanCount = 0, this.hasActivePlan = false, this.points = const {}, int avatar = -1}) :
			  super(id, name, role: UserRole.child, avatar: avatar);
  UIChild.fromDBModel(Child child, {this.todayPlanCount = 0, this.hasActivePlan = false}):
			  points = Map.fromEntries(child.points.map((type) => MapEntry(type.icon, type.quantity))), super.fromDBModel(child);

	@override
	List<Object> get props => super.props..addAll([id, todayPlanCount, hasActivePlan, points]);

	@override
  String toString() => 'UIChild{name: $name, todayPlanCount: $todayPlanCount, hasActivePlan: $hasActivePlan, points: $points}';
}