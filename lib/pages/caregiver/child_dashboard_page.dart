import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/caregiver/child_dashboard/child_dashboard_cubit.dart';
import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/child_plans_util.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_confirm_button.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/cards/model_cards.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/general/app_alert.dart';
import 'package:fokus/widgets/general/app_loader.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:intl/intl.dart';
import 'package:smart_select/smart_select.dart';

class CaregiverChildDashboardPage extends StatefulWidget {
	final Map<String, dynamic> args;

	CaregiverChildDashboardPage(this.args);

	@override
	_CaregiverChildDashboardPageState createState() => _CaregiverChildDashboardPageState(args);
}

class _CaregiverChildDashboardPageState extends State<CaregiverChildDashboardPage> with TickerProviderStateMixin {
	static const String _pageKey = 'page.caregiverSection.childDashboard';
	TabController _tabController;
	final UIChild _childProfile;
	int _currentIndex;

	_CaregiverChildDashboardPageState(Map<String, dynamic> args) : _currentIndex = args['tab'] ?? 0, _childProfile = args['child'];

	final double customBottomBarHeight = 40.0;
	final Duration bottomBarAnimationDuration = Duration(milliseconds: 400);

	@override
	void initState() {
		super.initState();
		_tabController = TabController(initialIndex: _currentIndex, vsync: this, length: 3);
		_tabController.animation..addListener(() {
			setState(() {
				_currentIndex = (_tabController.animation.value).round();
			});
		});
	}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
		return Scaffold(
	    body: LoadableBlocBuilder<ChildDashboardCubit>(
				builder: (context, state) => _getPage(
					child: (state as ChildDashboardState).child,
	        content: TabBarView(
            controller: _tabController,
            children: [
	            _buildTab(
		            tabState: (state) => state.plansTab,
		            content: _buildPlansTab
	            ),
	            _buildTab(
		            tabState: (state) => state.rewardsTab,
		            content: _buildRewardsTab
	            ),
	            _buildTab(
		            tabState: (state) => state.achievementsTab,
		            content: _buildAchievementsTab
	            ),
            ]
					)
	      ),
		    loadingBuilder: (context, state) => _getPage(
			    child: _childProfile,
			    content: Center(child: AppLoader())
		    ),
	    ),
	    bottomNavigationBar: _buildBottomBar(),
	    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
	    floatingActionButton: _buildFloatingButtonAnimation()
		);
	}

	Column _getPage({UIChild child, Widget content}) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
				verticalDirection: VerticalDirection.up,
			children: [
				Expanded(child: content),
				_buildAppHeader(child),
			]
		);
	}

	CustomContentAppBar _buildAppHeader(UIChild child) {
		var cubit = BlocProvider.of<ChildDashboardCubit>(context);
    return CustomContentAppBar(
      title: '$_pageKey.header.title',
      content: ChildItemCard(child: child),
      popupMenuWidget: PopupMenuList(
        lightTheme: true,
        items: [
          UIButton('$_pageKey.header.childCode',() => showUserCodeDialog(context, '$_pageKey.header.childCode', getCodeFromId(child.id)),
						null, Icons.screen_lock_portrait ),
          UIButton.ofType(ButtonType.edit, () => cubit.onNameDialogClosed(showNameEditDialog(context, _childProfile)),
						null, Icons.edit),
          UIButton.ofType(ButtonType.unpair, () async {
            	if ((await showAccountDeleteDialog(context, _childProfile)) ?? false)
	            	Navigator.of(context).pop();
						}, null, Icons.person_remove)
        ],
      ),
      tabs: TabBar(
	      controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3.0,
        tabs: [
          Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.plans')),
          Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.rewards')),
          Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.achievements'))
        ]
      )
    );
  }

	Widget _buildBottomBar() {
		return AnimatedContainer(
			duration: bottomBarAnimationDuration,
			height: _currentIndex == 1 ? 0 : customBottomBarHeight,
			decoration: AppBoxProperties.elevatedContainer,
			child: SizedBox.shrink()
		);
	}

	Widget _buildFloatingButtonAnimation() {
		return AnimatedSwitcher(
			duration: bottomBarAnimationDuration,
			switchOutCurve: Curves.easeInOut,
			transitionBuilder: (child, animation) {
				return ScaleTransition(
					scale: animation,
					child: FadeTransition(
						opacity: animation,
						child: child
					)
				);
			},
			child: _buildSelectPopup()
		);
	}

	Widget _buildSelectPopup() {
		if (_currentIndex == 1)
			return SizedBox.shrink();
		if (_currentIndex == 0)
			return _buildSelect<UIPlan, ChildDashboardPlansTabState>(
					content: _buildPlanSelect,
					tabState: (state) => state.plansTab,
					model: (tabState) => tabState.availablePlans
			);
		return _buildSelect<UIBadge, ChildDashboardAchievementsTabState>(
				content: _buildBadgeSelect,
				tabState: (state) => state.achievementsTab,
				model: (tabState) => tabState.availableBadges
		);
	}
	
	Widget _buildFloatingButtonPicker<T>({
		String buttonLabel, IconData buttonIcon, String disabledDialogTitle, String disabledDialogText,
		String pickerTitle, List<T> pickedValues, List<T> options,
		Function builder, Function(List<T>) onChange, Function(T) getName
	}) {
		bool buttonDisabled = options.isEmpty;
		return SmartSelect<T>.multiple(
			value: pickedValues,
			title: pickerTitle,
			options: [
				for(T element in options)
					SmartSelectOption(
						title: getName(element),
						value: element
					)
			],
			onChange: (val) => onChange(val),
			modalType: SmartSelectModalType.bottomSheet,
			choiceConfig: SmartSelectChoiceConfig(builder: builder),
			modalConfig: SmartSelectModalConfig(
				useConfirmation: true,
				confirmationBuilder: (context, callback) => ButtonSheetConfirmButton(callback: () => callback)
			),
			builder: (context, state, function) {
				return FloatingActionButton.extended(
					heroTag: null,
					materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
					backgroundColor: buttonDisabled ? Colors.grey : AppColors.formColor,
					elevation: 4.0,
					icon: Icon(buttonIcon),
					label: Text(buttonLabel),
					onPressed: () => buttonDisabled ?
						showBasicDialog(context,
							GeneralDialog.discard(
								title: disabledDialogTitle,
								content: disabledDialogText
							)
						) : function(context)
				);
			}
		);
	}

	Widget _buildSelect<T, State>({Widget Function([List<T>]) content, State Function(ChildDashboardState) tabState, List<T> Function(State) model}) {
		return _wrapWithBuilder<State>(
			tabState: tabState,
			content: (state) => content(model(state)),
			loader: content()
		);
	}

	Widget _buildPlanSelect([List<UIPlan> availablePlans = const []]) {
		return _buildFloatingButtonPicker<UIPlan>(
			buttonLabel: AppLocales.of(context).translate('$_pageKey.header.assignPlanButton'),
			buttonIcon: Icons.description,
			disabledDialogTitle: AppLocales.of(context).translate('$_pageKey.header.assignPlanButton'),
			disabledDialogText: AppLocales.of(context).translate('$_pageKey.content.alerts.noPlansAdded'),
			pickerTitle: AppLocales.of(context).translate('$_pageKey.header.assignPlanTitle'),
			pickedValues: availablePlans.where((element) => element.assignedTo.contains(_childProfile.id)).toList(),
			options: availablePlans,
			onChange: (selected) => BlocProvider.of<ChildDashboardCubit>(context).assignPlans(selected.map((plan) => plan.id).toList()),
			getName: (plan) => plan.name,
			builder: (item, checked, onChange) {
				return Theme(
					data: ThemeData(textTheme: Theme.of(context).textTheme),
					child: ItemCard(
						title: item.title,
						subtitle: AppLocales.of(context).translate(checked ? 'actions.selected' : 'actions.tapToSelect'),
						icon: Padding(
							padding: EdgeInsets.all(6.0).copyWith(right: 0.0),
							child: CircleAvatar(
								backgroundColor: checked ? Colors.green : Colors.grey,
								radius: 16.0,
								child: checked ? Icon(Icons.check, color: Colors.white, size: 20.0) : SizedBox(height: 20)
							)
						),
						onTapped: onChange != null ? () => onChange(item.value, !checked) : null,
						isActive: checked
					)
				);
			}
		);
	}

	Widget _buildBadgeSelect([List<UIBadge> availableBadges = const []]) {
		return _buildFloatingButtonPicker<UIBadge>(
			buttonLabel: AppLocales.of(context).translate('$_pageKey.header.assignBadgeButton'),
			buttonIcon: Icons.star,
			disabledDialogTitle: AppLocales.of(context).translate('$_pageKey.header.assignBadgeButton'),
			disabledDialogText: AppLocales.of(context).translate('$_pageKey.header.noBadgesToAssignText'),
			pickerTitle: AppLocales.of(context).translate('$_pageKey.header.assignBadgeTitle'),
			pickedValues: [],
			options: availableBadges,
			onChange: (selected) => BlocProvider.of<ChildDashboardCubit>(context).assignBadges(selected),
			getName: (badge) => badge.name,
			builder: (item, checked, onChange) {
				return Theme(
					data: ThemeData(textTheme: Theme.of(context).textTheme),
					child: ItemCard(
						title: item.title,
						subtitle: AppLocales.of(context).translate(checked ? 'actions.selected' : 'actions.tapToSelect'),
						graphic: item.value.icon,
						graphicType: AssetType.badges,
						graphicShowCheckmark: checked,
						graphicHeight: 40.0,
						onTapped: onChange != null ? () => onChange(item.value, !checked) : null,
						isActive: checked
					)
				);
			}
		);
	}

	Widget _wrapWithBuilder<State>({State Function(ChildDashboardState) tabState, Widget Function(State) content, Widget loader}) {
		return BlocBuilder<ChildDashboardCubit, LoadableState>(
			buildWhen: (oldState, newState) => newState is ChildDashboardState &&
					(oldState is DataLoadInProgress || tabState(oldState as ChildDashboardState) != tabState(newState)),
			builder: (context, state) {
				if (state is! ChildDashboardState || tabState(state as ChildDashboardState) == null)
					return loader ?? Center(child: AppLoader());
				return content(tabState(state));
			}
		);
	}

	Widget _buildTab<State>({State Function(ChildDashboardState) tabState, List<Widget> Function(State) content}) {
		return _wrapWithBuilder(
			tabState: tabState,
			content: (state) => ListView(
				padding: EdgeInsets.zero,
				physics: BouncingScrollPhysics(),
				children: content(state)
			)
		);
	}

	List<Widget> _buildPlansTab(ChildDashboardPlansTabState state) {
		return [
			if (state.unratedTasks)
				AppAlert(
					text: AppLocales.of(context).translate('$_pageKey.content.alerts.unratedTasksExist'),
					onTap: () => Navigator.of(context).pushNamed(AppPage.caregiverRatingPage.name),
				),
			if (state.noPlansAdded)
				AppAlert(
					text: AppLocales.of(context).translate('$_pageKey.content.alerts.noPlansAdded'),
					onTap: () => Navigator.of(context).pushNamed(AppPage.caregiverPlanForm.name),
				),
			...buildChildPlanSegments(state.childPlans, context),
			SizedBox(height: 30.0)
		];
	}

	List<Widget> _buildRewardsTab(ChildDashboardRewardsTabState state) {
		return [
			if (state.noRewardsAdded)
				AppAlert(
					text: AppLocales.of(context).translate('$_pageKey.content.alerts.noRewardsAdded'),
					onTap: () => Navigator.of(context).pushNamed(AppPage.caregiverRewardForm.name),
				),
			Segment(
				title: '$_pageKey.content.rewardsTitle',
				noElementsMessage: '$_pageKey.content.noRewardsText',
				elements: [
					for (var reward in state.childRewards)
						RewardItemCard(reward: reward),
				]
			)
		];
	}

	List<Widget> _buildAchievementsTab(ChildDashboardAchievementsTabState state) {
		return [
			if (state.availableBadges.isEmpty && state.childBadges.isEmpty)
				AppAlert(
					text: AppLocales.of(context).translate('$_pageKey.content.alerts.noBadgesAdded'),
					onTap: () => Navigator.of(context).pushNamed(AppPage.caregiverBadgeForm.name),
				),
			Segment(
				title: '$_pageKey.content.achievementsTitle',
				noElementsMessage: '$_pageKey.content.noAchievementsText',
				noElementsIcon: Icons.star,
				elements: [
					for (var badge in state.childBadges)
						ItemCard(
							title: badge.name,
							subtitle: AppLocales.of(context).translate('page.childSection.achievements.content.earnedBadgeDate') + ': '
									+ DateFormat.yMd(AppLocales.instance.locale.toString()).format(badge.date),
							graphicType: AssetType.badges,
							graphic: badge.icon,
							graphicHeight: 44.0,
						)
				]
			)
		];
	}

}
