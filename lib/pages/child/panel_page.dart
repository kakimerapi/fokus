import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:fokus/logic/child_plans/child_plans_cubit.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/attribute_chip.dart';
import 'package:fokus/widgets/item_card.dart';
import 'package:fokus/widgets/rounded_button.dart';
import 'package:fokus/widgets/segment.dart';

class ChildPanelPage extends StatefulWidget {
  @override
  _ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
  static const String _pageKey = 'page.childSection.panel';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
	      crossAxisAlignment: CrossAxisAlignment.start,
	      children: [
	        ChildCustomHeader(),
	        CubitBuilder<ChildPlansCubit, ChildPlansState>(
	          cubit: CubitProvider.of<ChildPlansCubit>(context),
	          builder: (context, state) {
	            if (state is ChildPlansInitial)
	              CubitProvider.of<ChildPlansCubit>(context).loadChildPlansForToday();
	            else if (state is ChildPlansLoadSuccess)
	              return AppSegments(segments: _buildPanelSegments(state));
	            return Expanded(child: Center(child: CircularProgressIndicator()));
	          },
	        ),
	        Row(
						mainAxisAlignment: MainAxisAlignment.end,
	          children: <Widget>[
	            RoundedButton(
		            iconData: Icons.calendar_today,
		            text: AppLocales.of(context).translate('$_pageKey.content.futurePlans'),
		            color: AppColors.childButtonColor,
		          ),
	          ],
	        )
	      ],
      ),
      bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 0)
    );
  }

  List<Segment> _buildPanelSegments(ChildPlansLoadSuccess state) {
  	var activePlan = state.plans.firstWhere((plan) => plan.state == PlanInstanceState.active);
  	var taskDescriptionKey = '$_pageKey.content.' + (activePlan.completedTaskCount > 0 ? 'taskProgress' : 'noTaskCompleted');
    return [
			if(activePlan != null)
        Segment(title: '$_pageKey.content.inProgress', elements: <Widget>[
          ItemCard(
            actionButton: ItemCardActionButton(
              icon: Icons.launch,
              color: AppColors.childActionColor,
              onTapped: () => {log("startPlan")},
            ),
            title: activePlan.name,
            subtitle: activePlan.description(context),
            isActive: true,
            //TODO: add progress from DB
            progressPercentage: activePlan.completedTaskCount / activePlan.taskCount,
            chips: <Widget>[
              AttributeChip.withIcon(
                icon: Icons.description,
                color: Colors.lightGreen,
                content: AppLocales.of(context).translate(taskDescriptionKey, {'NUM_TASKS': activePlan.completedTaskCount, 'NUM_ALL_TASKS': activePlan.taskCount})
              )
            ],
          )
        ],
      ),
      Segment(
        title: '$_pageKey.content.' + (activePlan == null ? 'todaysPlans' : 'remainingTodaysPlans'),
        noElementsMessage: '$_pageKey.content.' + (activePlan == null ? 'noPlans' : 'allPlansCompleted'),
        elements: <Widget>[
          for (var plan in state.plans)
	          if (plan.id != activePlan.id)
	            ItemCard(
	              actionButton: ItemCardActionButton(
	                icon: Icons.play_arrow,
	                color: AppColors.childButtonColor,
	                onTapped: () => {log("startPlan")}),
	              title: plan.name,
	              subtitle: plan.description(context),
	              chips: <Widget>[
	                AttributeChip.withIcon(
	                  icon: Icons.description,
	                  color: AppColors.mainBackgroundColor,
	                  content: AppLocales.of(context).translate('$_pageKey.content.tasks', {'NUM_TASKS': plan.taskCount})
	                )
	              ],
	            )
        ],
      ),
    ];
  }
}
